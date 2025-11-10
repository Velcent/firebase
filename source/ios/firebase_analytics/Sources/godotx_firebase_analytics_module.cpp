#include "godotx_firebase_analytics_module.h"
#include "godotx_firebase_analytics.h"

#include "core/config/engine.h"
#include "core/object/class_db.h"

GodotxFirebaseAnalytics *godotx_firebase_analytics = nullptr;

void initialize_godotx_firebase_analytics_module() {
    godotx_firebase_analytics = memnew(GodotxFirebaseAnalytics);
    Engine::get_singleton()->add_singleton(Engine::Singleton("GodotxFirebaseAnalytics", godotx_firebase_analytics));
}

void uninitialize_godotx_firebase_analytics_module() {
    if (godotx_firebase_analytics) {
        memdelete(godotx_firebase_analytics);
        godotx_firebase_analytics = nullptr;
    }
}

