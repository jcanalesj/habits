package com.jcanales.constanza

import android.content.ComponentName
import android.content.Context
import android.content.pm.PackageManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
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

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
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
    }
}
