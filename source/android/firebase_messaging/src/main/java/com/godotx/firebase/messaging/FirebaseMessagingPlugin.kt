package com.godotx.firebase.messaging

import android.Manifest
import android.content.pm.PackageManager
import android.os.Build
import android.util.Log
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.google.firebase.messaging.FirebaseMessaging
import org.godotengine.godot.Godot
import org.godotengine.godot.plugin.GodotPlugin
import org.godotengine.godot.plugin.SignalInfo
import org.godotengine.godot.plugin.UsedByGodot

class FirebaseMessagingPlugin(godot: Godot) : GodotPlugin(godot) {

    companion object {
        val TAG = FirebaseMessagingPlugin::class.java.simpleName
        const val PERMISSION_REQUEST_CODE = 1001
    }

    init {
        Log.v(TAG, "Firebase Messaging plugin loaded")
    }

    override fun getPluginName(): String {
        return "GodotxFirebaseMessaging"
    }

    override fun getPluginSignals(): Set<SignalInfo> {
        return setOf(
            SignalInfo("messaging_permission_granted"),
            SignalInfo("messaging_permission_denied"),
            SignalInfo("messaging_token_received",
                String::class.java
            ),
            SignalInfo("messaging_message_received",
                String::class.java,
                String::class.java
            ),
            SignalInfo("messaging_error",
                String::class.java
            )
        )
    }

    override fun onMainRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>?,
        grantResults: IntArray?
    ) {
        if (requestCode == PERMISSION_REQUEST_CODE) {
            if (grantResults != null && grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                Log.d(TAG, "Notification permission granted")
                emitSignal("messaging_permission_granted")
            } else {
                Log.d(TAG, "Notification permission denied")
                emitSignal("messaging_permission_denied")
            }
        }
    }

    @UsedByGodot
    fun request_permission() {
        val ctx = activity
        if (ctx == null) {
            Log.e(TAG, "Activity is null")
            emitSignal("messaging_error", "activity_null")
            return
        }

        // For Android 13 (API 33) and above, need to request POST_NOTIFICATIONS permission
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            if (ContextCompat.checkSelfPermission(ctx, Manifest.permission.POST_NOTIFICATIONS) != PackageManager.PERMISSION_GRANTED) {
                ActivityCompat.requestPermissions(
                    ctx,
                    arrayOf(Manifest.permission.POST_NOTIFICATIONS),
                    PERMISSION_REQUEST_CODE
                )
            } else {
                // Permission already granted
                Log.d(TAG, "Notification permission already granted")
                emitSignal("messaging_permission_granted")
            }
        } else {
            // For Android < 13, permission not required
            Log.d(TAG, "Notification permission not required (Android < 13)")
            emitSignal("messaging_permission_granted")
        }
    }

    @UsedByGodot
    fun get_token() {
        try {
            FirebaseMessaging.getInstance().token.addOnCompleteListener { task ->
                if (!task.isSuccessful) {
                    Log.e(TAG, "Failed to get FCM token", task.exception)
                    emitSignal("messaging_error", task.exception?.message ?: "token_fetch_failed")
                    return@addOnCompleteListener
                }

                val token = task.result
                Log.d(TAG, "FCM token: $token")
                emitSignal("messaging_token_received", token)
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error getting token", e)
            emitSignal("messaging_error", e.message ?: "token_error")
        }
    }

    @UsedByGodot
    fun subscribe_to_topic(topic: String) {
        try {
            FirebaseMessaging.getInstance().subscribeToTopic(topic)
                .addOnCompleteListener { task ->
                    if (task.isSuccessful) {
                        Log.d(TAG, "Subscribed to topic: $topic")
                    } else {
                        Log.e(TAG, "Failed to subscribe to topic", task.exception)
                        emitSignal("messaging_error", task.exception?.message ?: "subscribe_failed")
                    }
                }
        } catch (e: Exception) {
            Log.e(TAG, "Error subscribing to topic", e)
            emitSignal("messaging_error", e.message ?: "subscribe_error")
        }
    }

    @UsedByGodot
    fun unsubscribe_from_topic(topic: String) {
        try {
            FirebaseMessaging.getInstance().unsubscribeFromTopic(topic)
                .addOnCompleteListener { task ->
                    if (task.isSuccessful) {
                        Log.d(TAG, "Unsubscribed from topic: $topic")
                    } else {
                        Log.e(TAG, "Failed to unsubscribe from topic", task.exception)
                        emitSignal("messaging_error", task.exception?.message ?: "unsubscribe_failed")
                    }
                }
        } catch (e: Exception) {
            Log.e(TAG, "Error unsubscribing from topic", e)
            emitSignal("messaging_error", e.message ?: "unsubscribe_error")
        }
    }
}

