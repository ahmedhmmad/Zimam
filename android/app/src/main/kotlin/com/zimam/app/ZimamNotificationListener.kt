package com.zimam.app

import android.content.Intent
import android.os.Bundle
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification

/**
 * Reads notifications on-device and hands them to Flutter.
 *
 * The service does as little as possible on purpose. It extracts the package
 * name, title and text, and forwards them; it does not parse, does not store,
 * does not decide whether something is a transaction, and never touches the
 * network. Everything with judgement in it lives in Dart where it can be
 * tested, and everything sensitive stays on the device.
 *
 * Nothing here runs at all until the user has granted notification access,
 * which Android gates behind its own system screen. The app asks only after
 * showing its own disclosure first.
 */
class ZimamNotificationListener : NotificationListenerService() {

    override fun onListenerConnected() {
        super.onListenerConnected()
        isConnected = true
    }

    override fun onListenerDisconnected() {
        super.onListenerDisconnected()
        isConnected = false
    }

    override fun onNotificationPosted(sbn: StatusBarNotification?) {
        val notification = sbn ?: return

        // Our own notifications would be a feedback loop, and ongoing ones are
        // status displays (music players, downloads) rather than events.
        if (notification.packageName == packageName) return
        if (notification.isOngoing) return

        val extras: Bundle = notification.notification.extras ?: return
        val title = extras.getCharSequence("android.title")?.toString().orEmpty()
        val text = extras.getCharSequence("android.text")?.toString()
            ?: extras.getCharSequence("android.bigText")?.toString()
            ?: ""

        // A notification with no text carries nothing to parse.
        if (title.isEmpty() && text.isEmpty()) return

        CaptureBridge.emit(
            mapOf(
                "package" to notification.packageName,
                "title" to title,
                "body" to text,
                "postedAt" to notification.postTime,
            )
        )
    }

    override fun onBind(intent: Intent?) = super.onBind(intent)

    companion object {
        /**
         * Whether the OS currently has the service bound. Distinct from the
         * permission being granted: a user can revoke access while the app is
         * running, and the UI has to notice and fall back to manual entry.
         */
        @Volatile
        var isConnected: Boolean = false
            private set
    }
}
