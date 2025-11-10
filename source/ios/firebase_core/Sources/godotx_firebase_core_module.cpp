#include "godotx_firebase_core_module.h"
#include "godotx_firebase_core.h"

#include "core/config/engine.h"
#include "core/object/class_db.h"

GodotxFirebaseCore *godotx_firebase_core = nullptr;

void initialize_godotx_firebase_core_module() {
    godotx_firebase_core = memnew(GodotxFirebaseCore);
    Engine::get_singleton()->add_singleton(Engine::Singleton("GodotxFirebaseCore", godotx_firebase_core));
}

void uninitialize_godotx_firebase_core_module() {
    if (godotx_firebase_core) {
        memdelete(godotx_firebase_core);
        godotx_firebase_core = nullptr;
    }
}
