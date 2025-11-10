package com.godotx.firebase.crashlytics

import android.util.Log
import com.google.firebase.crashlytics.FirebaseCrashlytics
import org.godotengine.godot.Godot
import org.godotengine.godot.plugin.GodotPlugin
import org.godotengine.godot.plugin.SignalInfo
import org.godotengine.godot.plugin.UsedByGodot

class FirebaseCrashlyticsPlugin(godot: Godot) : GodotPlugin(godot) {

    private var crashlytics: FirebaseCrashlytics? = null

    companion object {
        val TAG = FirebaseCrashlyticsPlugin::class.java.simpleName
    }

    init {
        Log.v(TAG, "Loading Firebase Crashlytics plugin...")
        try {
            crashlytics = FirebaseCrashlytics.getInstance()
            Log.v(TAG, "Firebase Crashlytics initialized")
        } catch (e: Exception) {
            Log.e(TAG, "Firebase Crashlytics init failed", e)
        }
    }

    override fun getPluginName(): String {
        return "GodotxFirebaseCrashlytics"
    }

    override fun getPluginSignals(): Set<SignalInfo> {
        return setOf(
            SignalInfo("error",
                String::class.java
            )
        )
    }

    @UsedByGodot
    fun crash() {
        Log.d(TAG, "Forcing crash for testing...")
        val crash: String? = null
        crash!!.length
    }

    @UsedByGodot
    fun log_message(message: String) {
        val crashlyticsInstance = crashlytics
        if (crashlyticsInstance == null) {
            Log.e(TAG, "Firebase Crashlytics not initialized")
            emitSignal("error", "crashlytics_not_initialized")
            return
        }

        try {
            crashlyticsInstance.log(message)
            Log.d(TAG, "Logged message to Crashlytics: $message")
        } catch (e: Exception) {
            Log.e(TAG, "Failed to log message", e)
            emitSignal("error", e.message ?: "log_error")
        }
    }

    @UsedByGodot
    fun set_user_id(user_id: String) {
        val crashlyticsInstance = crashlytics
        if (crashlyticsInstance == null) {
            Log.e(TAG, "Firebase Crashlytics not initialized")
            emitSignal("error", "crashlytics_not_initialized")
            return
        }

        try {
            crashlyticsInstance.setUserId(user_id)
            Log.d(TAG, "Set user ID: $user_id")
        } catch (e: Exception) {
            Log.e(TAG, "Failed to set user ID", e)
            emitSignal("error", e.message ?: "set_user_error")
        }
    }
}

