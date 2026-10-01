package com.jcanales.constanza

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.widget.RemoteViews
import androidx.core.app.NotificationCompat
import androidx.core.content.ContextCompat
import org.json.JSONObject
import java.text.NumberFormat
import java.time.LocalDate
import java.time.ZoneId
import java.time.ZonedDateTime
import java.util.Locale
import java.util.concurrent.CopyOnWriteArraySet

/**
 * Notificación fija con los pasos de hoy ("pasos en directo").
 *
 * Es un servicio en primer plano porque es la única forma en Android de
 * seguir leyendo el sensor y refrescar la notificación con la app cerrada.
 * Mientras está activo es el ÚNICO que convierte el contador acumulado en
 * pasos del día: escribe el mismo "libro" (`pedometer_ledger_<uid>`) que usa
 * Dart, en las preferencias de Flutter, y la app recibe de él el total del
 * día ya calculado (ver `MainActivity`). Así no se cuenta nada dos veces.
 *
 * Además apunta el total de cada día que termina, para que la app rellene el
 * histórico de los días en los que no se abrió (`query` del canal).
 */
class StepsNotificationService : Service(), SensorEventListener {
    private val sensorManager by lazy { getSystemService(Context.SENSOR_SERVICE) as SensorManager }
    private val handler = Handler(Looper.getMainLooper())
    // Android instantiates a Service before attaching its base Context, so
    // anything that reads preferences must wait until the lifecycle starts.
    private lateinit var config: Config
    private var ledger = Ledger()
    private var midnightRollover: Runnable? = null

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        config = Config.load(this)
        running = true
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (!isEnabled(this) || !hasActivityPermission(this)) {
            // Sin permiso de actividad no hay nada que contar: se apaga el
            // interruptor para que la app no lo dé por activo.
            stop(this)
            return START_NOT_STICKY
        }
        config = Config.load(this)
        createChannel()
        ledger = Ledger.load(this, config.userId)
        publish()
        startInForeground()
        subscribe()
        scheduleMidnightRollover()
        return START_STICKY
    }

    override fun onDestroy() {
        sensorManager.unregisterListener(this)
        midnightRollover?.let(handler::removeCallbacks)
        running = false
        super.onDestroy()
    }

    // ------------------------------------------------------------ sensor

    private fun subscribe() {
        sensorManager.unregisterListener(this)
        val sensor = sensorManager.getDefaultSensor(Sensor.TYPE_STEP_COUNTER) ?: return
        sensorManager.registerListener(this, sensor, SensorManager.SENSOR_DELAY_NORMAL)
    }

    override fun onSensorChanged(event: SensorEvent) {
        val counter = event.values[0].toLong()
        applyCounter(counter)
    }

    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {}

    @Synchronized
    private fun applyCounter(counter: Long) {
        val today = todayKey()
        val previous = ledger
        ledger = ledger.apply(counter, today)
        if (previous.dayKey != null && previous.dayKey != today) {
            // Día cerrado: su total queda apuntado para el histórico.
            History.record(this, config.userId, previous.dayKey, previous.todaySteps)
        }
        ledger.save(this, config.userId)
        History.record(this, config.userId, today, ledger.todaySteps)
        publish()
        refreshNotification()
    }

    /** A medianoche la notificación vuelve a cero aunque nadie camine. */
    private fun scheduleMidnightRollover() {
        midnightRollover?.let(handler::removeCallbacks)
        val zone = zone()
        val now = ZonedDateTime.now(zone)
        val nextMidnight = now.toLocalDate().plusDays(1).atStartOfDay(zone)
        val delay = nextMidnight.toInstant().toEpochMilli() - now.toInstant().toEpochMilli()
        val runnable = Runnable {
            synchronized(this) {
                val today = todayKey()
                if (ledger.dayKey != today) {
                    ledger.dayKey?.let { History.record(this, config.userId, it, ledger.todaySteps) }
                    ledger = Ledger(lastCounter = ledger.lastCounter, dayKey = today, todaySteps = 0)
                    ledger.save(this, config.userId)
                    publish()
                    refreshNotification()
                }
            }
            scheduleMidnightRollover()
        }
        midnightRollover = runnable
        handler.postDelayed(runnable, delay.coerceAtLeast(1000L))
    }

    private fun zone(): ZoneId = try {
        ZoneId.of(config.timezone)
    } catch (_: Exception) {
        ZoneId.systemDefault()
    }

    private fun todayKey(): String = LocalDate.now(zone()).toString()

    private fun publish() {
        todaySteps = ledger.todaySteps
        todayKeyPublished = ledger.dayKey ?: todayKey()
        val at = System.currentTimeMillis()
        for (listener in listeners) listener(ledger.todaySteps, at)
    }

    // ------------------------------------------------------ notificación

    private fun createChannel() {
        val manager = getSystemService(NotificationManager::class.java)
        val channel = NotificationChannel(
            CHANNEL_ID,
            config.labels.channelName,
            NotificationManager.IMPORTANCE_LOW,
        ).apply {
            description = config.labels.channelDescription
            setShowBadge(false)
        }
        manager.createNotificationChannel(channel)
    }

    private fun startInForeground() {
        val notification = buildNotification()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            startForeground(NOTIFICATION_ID, notification, ServiceInfo.FOREGROUND_SERVICE_TYPE_HEALTH)
        } else {
            startForeground(NOTIFICATION_ID, notification)
        }
    }

    private fun refreshNotification() {
        getSystemService(NotificationManager::class.java).notify(NOTIFICATION_ID, buildNotification())
    }

    private fun buildNotification(): Notification {
        val steps = ledger.todaySteps
        val goal = config.goal.coerceAtLeast(1)
        val locale = config.locale
        val integers = NumberFormat.getIntegerInstance(locale)
        val distanceMeters = (steps * config.strideMeters)
        val kcal = Math.round(distanceMeters / 1000.0 * config.weightKg * 0.57)
        val km = String.format(locale, "%.1f", distanceMeters / 1000.0)
        val goalText = if (steps >= goal) {
            config.labels.goalReached
        } else {
            config.labels.goal.replace("{n}", integers.format(goal))
        }
        val stepsText = integers.format(steps)
        val kcalText = "🔥 " + config.labels.kcal.replace("{n}", integers.format(kcal))
        val kmText = config.labels.km.replace("{n}", km)
        // La plantilla «{n} pasos» se parte: el número va aparte y en grande.
        val stepsLabel = config.labels.title.replace("{n}", "").trim()
        val text = "$kcalText · $kmText · $goalText"
        val open = PendingIntent.getActivity(
            this,
            0,
            packageManager.getLaunchIntentForPackage(packageName)
                ?: Intent(this, MainActivity::class.java),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
        // Tarjeta propia: el gato a color, el número en grande y la barra.
        // Las vistas plegada y desplegada comparten ids.
        val collapsed = RemoteViews(packageName, R.layout.notification_steps_collapsed).apply {
            setTextViewText(R.id.steps_value, stepsText)
            setTextViewText(R.id.steps_label, stepsLabel)
            setTextViewText(R.id.steps_kcal, kcalText)
            setProgressBar(R.id.steps_progress, goal, steps.coerceAtMost(goal), false)
        }
        val expanded = RemoteViews(packageName, R.layout.notification_steps_expanded).apply {
            setTextViewText(R.id.steps_value, stepsText)
            setTextViewText(R.id.steps_label, stepsLabel)
            setTextViewText(R.id.steps_detail, "$kcalText · $kmText")
            setTextViewText(R.id.steps_goal, goalText)
            setProgressBar(R.id.steps_progress, goal, steps.coerceAtMost(goal), false)
        }
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_stat_constanza)
            .setColor(BRAND_COLOR)
            // Título y texto siguen puestos: los usan los relojes y los
            // sistemas que no pintan vistas propias.
            .setContentTitle(config.labels.title.replace("{n}", stepsText))
            .setContentText(text)
            .setStyle(NotificationCompat.DecoratedCustomViewStyle())
            .setCustomContentView(collapsed)
            .setCustomBigContentView(expanded)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setSilent(true)
            .setShowWhen(false)
            .setCategory(NotificationCompat.CATEGORY_STATUS)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .setContentIntent(open)
            .setForegroundServiceBehavior(NotificationCompat.FOREGROUND_SERVICE_IMMEDIATE)
            .build()
    }

    // --------------------------------------------------------- modelos

    /** Misma regla que `StepLedger` en Dart: una copia, un formato. */
    data class Ledger(
        val lastCounter: Long? = null,
        val dayKey: String? = null,
        val todaySteps: Int = 0,
    ) {
        fun apply(counter: Long, today: String): Ledger {
            val last = lastCounter
                ?: return Ledger(
                    lastCounter = counter,
                    dayKey = today,
                    todaySteps = if (dayKey == today) todaySteps else 0,
                )
            val delta = if (counter < last) counter else counter - last
            val sameDay = dayKey == today
            return Ledger(
                lastCounter = counter,
                dayKey = today,
                todaySteps = (if (sameDay) todaySteps else 0) + delta.toInt(),
            )
        }

        fun save(context: Context, userId: String) {
            val json = JSONObject()
                .put("lastCounter", lastCounter ?: JSONObject.NULL)
                .put("dayKey", dayKey ?: JSONObject.NULL)
                .put("todaySteps", todaySteps)
            flutterPreferences(context).edit().putString(ledgerKey(userId), json.toString()).apply()
        }

        companion object {
            fun load(context: Context, userId: String): Ledger {
                val raw = flutterPreferences(context).getString(ledgerKey(userId), null) ?: return Ledger()
                return try {
                    val json = JSONObject(raw)
                    Ledger(
                        lastCounter = if (json.isNull("lastCounter")) null else json.getLong("lastCounter"),
                        dayKey = if (json.isNull("dayKey")) null else json.getString("dayKey"),
                        todaySteps = json.optInt("todaySteps", 0),
                    )
                } catch (_: Exception) {
                    Ledger()
                }
            }

            /** Clave tal y como la guarda `shared_preferences` desde Dart. */
            private fun ledgerKey(userId: String) = "flutter.pedometer_ledger_$userId"
        }
    }

    class Labels(
        val title: String,
        val kcal: String,
        val km: String,
        val goal: String,
        val goalReached: String,
        val channelName: String,
        val channelDescription: String,
    )

    class Config(
        val userId: String,
        val goal: Int,
        val strideMeters: Double,
        val weightKg: Double,
        val timezone: String,
        val locale: Locale,
        val labels: Labels,
    ) {
        companion object {
            fun load(context: Context): Config = fromJson(
                context.getSharedPreferences(PREFERENCES, Context.MODE_PRIVATE).getString(KEY_CONFIG, null),
            )

            fun fromJson(raw: String?): Config {
                val json = try {
                    JSONObject(raw ?: "{}")
                } catch (_: Exception) {
                    JSONObject()
                }
                val labels = json.optJSONObject("labels") ?: JSONObject()
                return Config(
                    userId = json.optString("userId", "anonymous"),
                    goal = json.optInt("goal", 8000),
                    strideMeters = json.optDouble("strideMeters", 0.74),
                    weightKg = json.optDouble("weightKg", 70.0),
                    timezone = json.optString("timezone", ZoneId.systemDefault().id),
                    locale = Locale.forLanguageTag(json.optString("locale", "es")),
                    labels = Labels(
                        title = labels.optString("title", "{n} pasos"),
                        kcal = labels.optString("kcal", "{n} kcal"),
                        km = labels.optString("km", "{n} km"),
                        goal = labels.optString("goal", "Objetivo {n}"),
                        goalReached = labels.optString("goalReached", "¡Objetivo conseguido!"),
                        channelName = labels.optString("channelName", "Pasos en directo"),
                        channelDescription = labels.optString("channelDescription", ""),
                    ),
                )
            }
        }
    }

    /** Totales por día apuntados por el servicio, para rellenar el histórico. */
    object History {
        private const val KEEP_DAYS = 14

        fun record(context: Context, userId: String, dayKey: String, steps: Int) {
            val preferences = context.getSharedPreferences(PREFERENCES, Context.MODE_PRIVATE)
            val json = try {
                JSONObject(preferences.getString(key(userId), null) ?: "{}")
            } catch (_: Exception) {
                JSONObject()
            }
            val previous = json.optInt(dayKey, 0)
            json.put(dayKey, maxOf(previous, steps))
            // Solo se conservan los últimos días: la cuenta guarda el resto.
            val keys = json.keys().asSequence().toList().sorted()
            for (old in keys.dropLast(KEEP_DAYS)) json.remove(old)
            preferences.edit().putString(key(userId), json.toString()).apply()
        }

        private fun key(userId: String) = "days_$userId"
    }

    companion object {
        const val CHANNEL_ID = "steps_live"
        const val NOTIFICATION_ID = 7302
        private const val PREFERENCES = "steps_notification"
        private const val KEY_ENABLED = "enabled"
        private const val KEY_CONFIG = "config"
        private const val BRAND_COLOR = 0xFF7C5CE0.toInt()

        @Volatile var running = false
            private set

        /** Último total publicado (pasos de hoy y su día), para la app. */
        @Volatile var todaySteps = 0
            private set

        @Volatile var todayKeyPublished: String? = null
            private set

        private val listeners = CopyOnWriteArraySet<(Int, Long) -> Unit>()

        fun addListener(listener: (Int, Long) -> Unit) {
            listeners.add(listener)
        }

        fun removeListener(listener: (Int, Long) -> Unit) {
            listeners.remove(listener)
        }

        fun flutterPreferences(context: Context) =
            context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)

        fun isEnabled(context: Context): Boolean =
            context.getSharedPreferences(PREFERENCES, Context.MODE_PRIVATE).getBoolean(KEY_ENABLED, false)

        fun hasActivityPermission(context: Context): Boolean =
            Build.VERSION.SDK_INT < Build.VERSION_CODES.Q ||
                ContextCompat.checkSelfPermission(
                    context,
                    android.Manifest.permission.ACTIVITY_RECOGNITION,
                ) == android.content.pm.PackageManager.PERMISSION_GRANTED

        /** Guarda la configuración y arranca (o reconfigura) el servicio. */
        fun start(context: Context, configJson: String) {
            context.getSharedPreferences(PREFERENCES, Context.MODE_PRIVATE)
                .edit()
                .putBoolean(KEY_ENABLED, true)
                .putString(KEY_CONFIG, configJson)
                .apply()
            ContextCompat.startForegroundService(
                context,
                Intent(context, StepsNotificationService::class.java),
            )
        }

        /** Vuelve a arrancar tras un reinicio, si estaba activo. */
        fun restoreIfEnabled(context: Context) {
            if (!isEnabled(context)) return
            try {
                ContextCompat.startForegroundService(
                    context,
                    Intent(context, StepsNotificationService::class.java),
                )
            } catch (_: Exception) {
                // Sin permiso para arrancar en segundo plano: la app lo
                // volverá a lanzar en cuanto se abra.
            }
        }

        fun stop(context: Context) {
            context.getSharedPreferences(PREFERENCES, Context.MODE_PRIVATE)
                .edit()
                .putBoolean(KEY_ENABLED, false)
                .apply()
            context.stopService(Intent(context, StepsNotificationService::class.java))
        }

        /** Pasos apuntados para el día que contiene [instantMs] en la zona configurada. */
        fun historySteps(context: Context, instantMs: Long): Int? {
            val config = Config.load(context)
            val zone = try {
                ZoneId.of(config.timezone)
            } catch (_: Exception) {
                ZoneId.systemDefault()
            }
            val dayKey = java.time.Instant.ofEpochMilli(instantMs).atZone(zone).toLocalDate().toString()
            val preferences = context.getSharedPreferences(PREFERENCES, Context.MODE_PRIVATE)
            val json = try {
                JSONObject(preferences.getString("days_${config.userId}", null) ?: return null)
            } catch (_: Exception) {
                return null
            }
            return if (json.has(dayKey)) json.getInt(dayKey) else null
        }
    }
}
