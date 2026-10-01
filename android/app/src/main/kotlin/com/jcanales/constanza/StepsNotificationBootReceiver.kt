package com.jcanales.constanza

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

/** Tras reiniciar el móvil, vuelve a levantar los pasos en directo si estaban activos. */
class StepsNotificationBootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        when (intent.action) {
            Intent.ACTION_BOOT_COMPLETED,
            Intent.ACTION_MY_PACKAGE_REPLACED,
            "android.intent.action.QUICKBOOT_POWERON",
            -> StepsNotificationService.restoreIfEnabled(context)
        }
    }
}
