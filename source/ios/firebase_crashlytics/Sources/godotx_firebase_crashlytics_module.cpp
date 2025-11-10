#include "godotx_firebase_crashlytics_module.h"
#include "godotx_firebase_crashlytics.h"

#include "core/config/engine.h"
#include "core/object/class_db.h"

GodotxFirebaseCrashlytics *godotx_firebase_crashlytics = nullptr;

void initialize_godotx_firebase_crashlytics_module() {
    godotx_firebase_crashlytics = memnew(GodotxFirebaseCrashlytics);
    Engine::get_singleton()->add_singleton(Engine::Singleton("GodotxFirebaseCrashlytics", godotx_firebase_crashlytics));
}

void uninitialize_godotx_firebase_crashlytics_module() {
    if (godotx_firebase_crashlytics) {
        memdelete(godotx_firebase_crashlytics);
        godotx_firebase_crashlytics = nullptr;
    }
}

