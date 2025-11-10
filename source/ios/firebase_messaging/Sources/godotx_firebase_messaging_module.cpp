#include "godotx_firebase_messaging_module.h"
#include "godotx_firebase_messaging.h"

#include "core/config/engine.h"
#include "core/object/class_db.h"

GodotxFirebaseMessaging *godotx_firebase_messaging = nullptr;

void initialize_godotx_firebase_messaging_module() {
    godotx_firebase_messaging = memnew(GodotxFirebaseMessaging);
    Engine::get_singleton()->add_singleton(Engine::Singleton("GodotxFirebaseMessaging", godotx_firebase_messaging));
}

void uninitialize_godotx_firebase_messaging_module() {
    if (godotx_firebase_messaging) {
        memdelete(godotx_firebase_messaging);
        godotx_firebase_messaging = nullptr;
    }
}

