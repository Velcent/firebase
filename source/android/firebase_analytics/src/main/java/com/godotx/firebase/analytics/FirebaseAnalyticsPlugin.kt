package com.godotx.firebase.analytics

import android.os.Bundle
import android.util.Log
import com.google.firebase.analytics.FirebaseAnalytics
import org.godotengine.godot.Godot
import org.godotengine.godot.plugin.GodotPlugin
import org.godotengine.godot.plugin.SignalInfo
import org.godotengine.godot.plugin.UsedByGodot
import org.json.JSONObject

class FirebaseAnalyticsPlugin(godot: Godot) : GodotPlugin(godot) {

    private var firebaseAnalytics: FirebaseAnalytics? = null

    companion object {
        val TAG = FirebaseAnalyticsPlugin::class.java.simpleName
    }

    init {
        Log.v(TAG, "Firebase Analytics plugin loaded")
    }

    override fun getPluginName(): String {
        return "GodotxFirebaseAnalytics"
    }

    override fun getPluginSignals(): Set<SignalInfo> {
        return setOf(
            SignalInfo("analytics_initialized",
                Boolean::class.javaObjectType
            ),
            SignalInfo("analytics_event_logged",
                String::class.java
            ),
            SignalInfo("analytics_error",
                String::class.java
            )
        )
    }

    @UsedByGodot
    fun initialize() {
        try {
            val ctx = activity
            if (ctx == null) {
                Log.e(TAG, "Activity is null")
                emitSignal("analytics_initialized", false)
                emitSignal("analytics_error", "activity_null")
                return
            }
            firebaseAnalytics = FirebaseAnalytics.getInstance(ctx)
            Log.d(TAG, "Firebase Analytics initialized")
            emitSignal("analytics_initialized", true)
        } catch (e: Exception) {
            Log.e(TAG, "Firebase Analytics init failed", e)
            emitSignal("analytics_initialized", false)
            emitSignal("analytics_error", e.message ?: "init_error")
        }
    }

    @UsedByGodot
    fun log_event(event_name: String, params_json: String) {
        val analytics = firebaseAnalytics
        if (analytics == null) {
            Log.e(TAG, "Firebase Analytics not initialized")
            emitSignal("analytics_error", "analytics_not_initialized")
            return
        }

        try {
            val params = if (params_json.isNotEmpty()) JSONObject(params_json) else JSONObject()
            val bundle = Bundle()

            val keys = params.keys()
            while (keys.hasNext()) {
                val key = keys.next()
                val value = params.get(key)
                when (value) {
                    is Int -> bundle.putInt(key, value)
                    is Long -> bundle.putLong(key, value)
                    is Double -> bundle.putDouble(key, value)
                    is Boolean -> bundle.putBoolean(key, value)
                    else -> bundle.putString(key, value.toString())
                }
            }

            analytics.logEvent(event_name, bundle)
            Log.d(TAG, "Event logged: $event_name")
            emitSignal("analytics_event_logged", event_name)
        } catch (e: Exception) {
            Log.e(TAG, "Failed to log event", e)
            emitSignal("analytics_error", e.message ?: "event_log_error")
        }
    }
}

