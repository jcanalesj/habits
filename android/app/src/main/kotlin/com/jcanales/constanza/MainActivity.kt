package com.jcanales.constanza

import android.Manifest
import android.content.ComponentName
import android.content.Context
import android.content.pm.PackageManager
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import android.os.Bundle
import androidx.core.app.ActivityCompat
import androidx.core.app.NotificationManagerCompat
import org.json.JSONObject
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    /// Icono de Dart → alias del manifest que lo muestra en el launcher.
    private val aliases = mapOf(
        "classic" to "LauncherClassic",
        "crown" to "LauncherCrown",
        "yarn" to "LauncherYarn",
    )

    private val preferences by lazy {
        getSharedPreferences("app_icon", Context.MODE_PRIVATE)
    }

    // ------------------------------------------------------------ Pasos
    // Contador de pasos nativo: TYPE_STEP_COUNTER es acumulado desde el
    // último arranque y el hardware lo actualiza aunque la app esté cerrada.
    // Dart guarda el último valor leído y reparte la diferencia por días.
    private val sensorManager by lazy { getSystemService(Context.SENSOR_SERVICE) as SensorManager }
    private val stepSensor by lazy { sensorManager.getDefaultSensor(Sensor.TYPE_STEP_COUNTER) }
    private var stepListener: SensorEventListener? = null
    private var permissionRequest: MethodChannel.Result? = null

    /// Oyente abierto por Dart (`constanza/pedometer/updates`), si lo hay.
    private var pedometerSink: EventChannel.EventSink? = null
    private var serviceListener: ((Int, Long) -> Unit)? = null

    private fun pedometerPermissionStatus(): String {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) return "granted"
        val granted = ContextCompat.checkSelfPermission(
            this, Manifest.permission.ACTIVITY_RECOGNITION,
        ) == PackageManager.PERMISSION_GRANTED
        if (granted) return "granted"
        val asked = preferences.getBoolean(PEDOMETER_ASKED_KEY, false)
        return if (asked) "denied" else "notDetermined"
    }

    private fun registerPedometerChannels(flutterEngine: FlutterEngine) {
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "constanza/pedometer")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "isAvailable" -> result.success(stepSensor != null)
                    "permissionStatus" -> result.success(pedometerPermissionStatus())
                    "requestPermission" -> {
                        if (pedometerPermissionStatus() == "granted") {
                            result.success("granted")
                        } else {
                            permissionRequest?.success("denied")
                            permissionRequest = result
                            preferences.edit().putBoolean(PEDOMETER_ASKED_KEY, true).apply()
                            ActivityCompat.requestPermissions(
                                this,
                                arrayOf(Manifest.permission.ACTIVITY_RECOGNITION),
                                PEDOMETER_PERMISSION_CODE,
                            )
                        }
                    }
                    // Historial apuntado por el servicio de pasos en directo
                    // (días en los que la app no se abrió). Null si no hay.
                    "query" -> {
                        val fromMs = call.argument<Number>("fromMs")?.toLong()
                        val steps = fromMs?.let { StepsNotificationService.historySteps(this, it) }
                        result.success(
                            steps?.let { mapOf("steps" to it, "atMs" to System.currentTimeMillis()) },
                        )
                    }
                    else -> result.notImplemented()
                }
            }
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, "constanza/pedometer/updates")
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    if (stepSensor == null || events == null) {
                        events?.error("unavailable", "Sin sensor de pasos", null)
                        return
                    }
                    pedometerSink = events
                    attachPedometer()
                }

                override fun onCancel(arguments: Any?) {
                    detachPedometer()
                    pedometerSink = null
                }
            })
    }

    /// Conecta al oyente de Dart con la fuente que toque: con los pasos en
    /// directo activos, el servicio ya ha convertido el contador en pasos
    /// del día y se le pasa ese total (lectura absoluta, como en iOS); si
    /// no, el sensor en bruto y Dart lleva la cuenta.
    private fun attachPedometer() {
        val events = pedometerSink ?: return
        detachPedometer()
        if (StepsNotificationService.running) {
            val listener: (Int, Long) -> Unit = { steps, atMs ->
                runOnUiThread { events.success(mapOf("steps" to steps, "atMs" to atMs)) }
            }
            serviceListener = listener
            StepsNotificationService.addListener(listener)
            events.success(
                mapOf(
                    "steps" to StepsNotificationService.todaySteps,
                    "atMs" to System.currentTimeMillis(),
                ),
            )
            return
        }
        val sensor = stepSensor ?: return
        val listener = object : SensorEventListener {
            override fun onSensorChanged(event: SensorEvent) {
                events.success(
                    mapOf(
                        "counter" to event.values[0].toLong(),
                        "atMs" to System.currentTimeMillis(),
                    ),
                )
            }

            override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {}
        }
        stepListener = listener
        sensorManager.registerListener(listener, sensor, SensorManager.SENSOR_DELAY_NORMAL)
    }

    private fun detachPedometer() {
        stepListener?.let { sensorManager.unregisterListener(it) }
        stepListener = null
        serviceListener?.let { StepsNotificationService.removeListener(it) }
        serviceListener = null
    }

    // ------------------------------------------------- Pasos en directo
    private fun registerStepsNotificationChannel(flutterEngine: FlutterEngine) {
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "constanza/steps_notification")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "isSupported" -> result.success(stepSensor != null)
                    "isEnabled" -> result.success(StepsNotificationService.isEnabled(this))
                    "start", "update" -> {
                        val config = JSONObject(call.arguments as Map<*, *>).toString()
                        when {
                            !StepsNotificationService.hasActivityPermission(this) ->
                                result.success("activity_denied")
                            !NotificationManagerCompat.from(this).areNotificationsEnabled() ->
                                result.success("notifications_denied")
                            call.method == "update" && !StepsNotificationService.isEnabled(this) ->
                                result.success("stopped")
                            else -> {
                                StepsNotificationService.start(this, config)
                                // El servicio tarda un instante en arrancar:
                                // se reconecta a Dart en cuanto publica.
                                window.decorView.postDelayed({ attachPedometer() }, 400)
                                result.success("started")
                            }
                        }
                    }
                    "stop" -> {
                        StepsNotificationService.stop(this)
                        window.decorView.postDelayed({ attachPedometer() }, 200)
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun registerHapticsChannel(flutterEngine: FlutterEngine) {
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "constanza/haptics")
            .setMethodCallHandler { call, result ->
                if (call.method != "habitCompleted" && call.method != "stepsGoalCompleted") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }
                val vibrator = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                    getSystemService(VibratorManager::class.java).defaultVibrator
                } else {
                    @Suppress("DEPRECATION")
                    getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
                }
                val duration = if (call.method == "stepsGoalCompleted") 500L else 45L
                val amplitude = if (call.method == "stepsGoalCompleted") {
                    VibrationEffect.DEFAULT_AMPLITUDE
                } else {
                    110
                }
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    vibrator.vibrate(VibrationEffect.createOneShot(duration, amplitude))
                } else {
                    @Suppress("DEPRECATION")
                    vibrator.vibrate(duration)
                }
                result.success(null)
            }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode != PEDOMETER_PERMISSION_CODE) return
        val granted = grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED
        permissionRequest?.success(if (granted) "granted" else "denied")
        permissionRequest = null
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Si el sistema mató el servicio de pasos en directo, al abrir la app
        // se levanta de nuevo.
        StepsNotificationService.restoreIfEnabled(this)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        registerPedometerChannels(flutterEngine)
        registerStepsNotificationChannel(flutterEngine)
        registerHapticsChannel(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "constanza/app_icon")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "current" -> result.success(desiredIcon())
                    "set" -> {
                        val id = call.argument<String>("id")
                        if (id == null || id !in aliases) {
                            result.error("unknown_icon", "Icono desconocido: $id", null)
                        } else {
                            // Solo se guarda: cambiar el alias con la app en
                            // pantalla hace que Android cierre la tarea.
                            preferences.edit().putString(PENDING_KEY, id).apply()
                            result.success(null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }

    override fun onStop() {
        super.onStop()
        // Al pasar a segundo plano (también al abrir recientes para matar la
        // app) ya se puede cambiar el alias sin cerrar nada visible.
        if (!isChangingConfigurations) applyPendingIcon()
    }

    private fun component(alias: String) = ComponentName(packageName, "$packageName.$alias")

    private fun desiredIcon(): String =
        preferences.getString(PENDING_KEY, null)?.takeIf { it in aliases } ?: activeIcon()

    private fun activeIcon(): String {
        for ((id, alias) in aliases) {
            val state = packageManager.getComponentEnabledSetting(component(alias))
            val enabled = state == PackageManager.COMPONENT_ENABLED_STATE_ENABLED ||
                (state == PackageManager.COMPONENT_ENABLED_STATE_DEFAULT && id == "classic")
            if (enabled) return id
        }
        return "classic"
    }

    private fun applyPendingIcon() {
        val id = preferences.getString(PENDING_KEY, null)?.takeIf { it in aliases } ?: return
        if (id != activeIcon()) {
            // Primero se activa el nuevo y luego se apagan los demás: así
            // nunca queda la app sin ninguna entrada en el launcher.
            packageManager.setComponentEnabledSetting(
                component(aliases.getValue(id)),
                PackageManager.COMPONENT_ENABLED_STATE_ENABLED,
                PackageManager.DONT_KILL_APP,
            )
            for ((other, alias) in aliases) {
                if (other == id) continue
                packageManager.setComponentEnabledSetting(
                    component(alias),
                    PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
                    PackageManager.DONT_KILL_APP,
                )
            }
        }
        preferences.edit().remove(PENDING_KEY).apply()
    }

    private companion object {
        const val PENDING_KEY = "pending_icon"
        const val PEDOMETER_ASKED_KEY = "pedometer_permission_asked"
        const val PEDOMETER_PERMISSION_CODE = 7301
    }
}
