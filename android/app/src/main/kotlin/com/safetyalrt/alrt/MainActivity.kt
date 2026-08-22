package com.safetyalrt.alrt

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Intent
import android.content.Context
import android.os.Build
import android.os.Bundle
import android.telephony.TelephonyManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private companion object {
        const val CHANNEL = "com.safetyalrt.alrt/widget_pinning"
        const val SIM_CHANNEL = "com.safetyalrt.alrt/sim"
        const val EXTRA_PIN_WIDGET = "pin_widget"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "isPinSupported" -> result.success(isPinSupported())
                    "requestPinWidget" -> {
                        val kind = call.argument<String>("widget") ?: "alerts"
                        result.success(requestPinWidget(kind))
                    }
                    else -> result.notImplemented()
                }
            }

        // The SIM's country, for picking the local emergency number. It is
        // the only signal that follows the ground rather than the owner:
        // an Australian phone in Spain should offer 112, not 000.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SIM_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getSimCountryIso" -> result.success(simCountryIso())
                    else -> result.notImplemented()
                }
            }
    }

    /**
     * The SIM's ISO country, or null when there is no SIM, the device has
     * no telephony, or the platform declines. Needs no permission.
     * Never throws: a failure here must not cost someone the fallback.
     */
    private fun simCountryIso(): String? {
        return try {
            val telephony =
                getSystemService(Context.TELEPHONY_SERVICE) as? TelephonyManager
            telephony?.simCountryIso?.takeIf { it.isNotBlank() }?.uppercase()
        } catch (e: Exception) {
            null
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        handlePinExtra(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handlePinExtra(intent)
    }

    /** App-icon shortcut taps land here with a pin_widget extra. */
    private fun handlePinExtra(intent: Intent?) {
        val kind = intent?.getStringExtra(EXTRA_PIN_WIDGET) ?: return
        intent.removeExtra(EXTRA_PIN_WIDGET)
        requestPinWidget(kind)
    }

    private fun isPinSupported(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return false
        return try {
            AppWidgetManager.getInstance(this).isRequestPinAppWidgetSupported
        } catch (e: Exception) {
            false
        }
    }

    /** Shows the launcher's pin-widget dialog; returns whether it was shown. */
    private fun requestPinWidget(kind: String): Boolean {
        if (!isPinSupported()) return false
        val providerClass = when (kind) {
            "family" -> AlrtFamilyWidgetProvider::class.java
            else -> AlrtAlertsWidgetProvider::class.java
        }
        return try {
            AppWidgetManager.getInstance(this).requestPinAppWidget(
                ComponentName(this, providerClass),
                null,
                null as PendingIntent?,
            )
        } catch (e: Exception) {
            false
        }
    }
}
