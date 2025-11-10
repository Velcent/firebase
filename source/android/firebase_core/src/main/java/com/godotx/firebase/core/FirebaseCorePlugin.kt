package com.godotx.firebase.core

import android.util.Log
import com.google.firebase.FirebaseApp
import org.godotengine.godot.Godot
import org.godotengine.godot.plugin.GodotPlugin
import org.godotengine.godot.plugin.SignalInfo
import org.godotengine.godot.plugin.UsedByGodot

class FirebaseCorePlugin(godot: Godot) : GodotPlugin(godot) {

    companion object {
        val TAG = FirebaseCorePlugin::class.java.simpleName
    }

    init {
        Log.v(TAG, "Loading Firebase Core plugin...")
    }

    override fun getPluginName(): String {
        return "GodotxFirebaseCore"
    }

    override fun getPluginSignals(): Set<SignalInfo> {
        return setOf(
            SignalInfo("initialized",
                Boolean::class.javaObjectType
            ),
            SignalInfo("error",
                String::class.java
            )
        )
    }

    @UsedByGodot
    fun initialize() {
        try {
            val ctx = activity ?: return
            if (FirebaseApp.getApps(ctx).isEmpty()) {
                FirebaseApp.initializeApp(ctx)
                Log.d(TAG, "Firebase initialized successfully")
            } else {
                Log.d(TAG, "Firebase already initialized")
            }
            emitSignal("initialized", true)
        } catch (e: Exception) {
            Log.e(TAG, "Firebase initialization failed", e)
            emitSignal("initialized", false)
            emitSignal("error", e.message ?: "unknown_error")
        }
    }
}

