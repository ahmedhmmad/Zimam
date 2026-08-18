package com.zimam.app

import android.content.Context
import android.content.Intent
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

/**
 * The single seam between the notification listener and Flutter.
 *
 * Two channels, deliberately separated: a method channel for permission state
 * and the system settings hand-off, and an event channel for the stream of
 * captured notifications. Nothing crosses here except what the listener
 * extracted; no storage, no parsing, no network.
 */
object CaptureBridge {

    private const val METHOD_CHANNEL = "com.zimam.app/capture"
    private const val EVENT_CHANNEL = "com.zimam.app/capture/events"

    private var events: EventChannel.EventSink? = null
    private val main = Handler(Looper.getMainLooper())

    fun register(engine: FlutterEngine, context: Context) {
        MethodChannel(engine.dartExecutor.binaryMessenger, METHOD_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    // Whether the user has granted notification access. Read
                    // fresh every time rather than cached: it can be revoked
                    // from system settings while the app is running.
                    "isPermissionGranted" ->
                        result.success(isPermissionGranted(context))

                    // Whether the OS has actually bound the service. Granted
                    // but unbound happens after an update or a force-stop.
                    "isListenerConnected" ->
                        result.success(ZimamNotificationListener.isConnected)

                    // Opens the system screen. The app cannot grant this
                    // itself, and does not try — the user makes the choice in
                    // Android's own UI, having already seen ours.
                    "openPermissionSettings" -> {
                        context.startActivity(
                            Intent(SETTINGS_ACTION).apply {
                                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            }
                        )
                        result.success(null)
                    }

                    else -> result.notImplemented()
                }
            }

        EventChannel(engine.dartExecutor.binaryMessenger, EVENT_CHANNEL)
            .setStreamHandler(
                object : EventChannel.StreamHandler {
                    override fun onListen(args: Any?, sink: EventChannel.EventSink?) {
                        events = sink
                    }

                    override fun onCancel(args: Any?) {
                        events = null
                    }
                }
            )
    }

    /**
     * Forwards one captured notification.
     *
     * Dropped silently when Flutter is not listening. A queue here would mean
     * holding other people's financial messages in memory for an unbounded
     * time, and a missed notification simply means the user enters that
     * balance by hand — which is the fallback the whole feature degrades to
     * anyway.
     */
    fun emit(payload: Map<String, Any?>) {
        val sink = events ?: return
        main.post { sink.success(payload) }
    }

    private const val SETTINGS_ACTION =
        Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS

    /**
     * Reads the OS's own list of enabled listeners.
     *
     * Checked against the system setting rather than remembered locally: the
     * user can revoke access at any time without the app being told, and a
     * remembered "yes" would leave the UI claiming capture is on while nothing
     * arrives.
     */
    fun isPermissionGranted(context: Context): Boolean {
        val enabled = Settings.Secure.getString(
            context.contentResolver,
            "enabled_notification_listeners",
        ) ?: return false
        return enabled.split(":").any { it.contains(context.packageName) }
    }
}
