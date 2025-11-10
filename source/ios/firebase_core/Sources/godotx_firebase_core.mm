#import "godotx_firebase_core.h"
#import <Foundation/Foundation.h>

@import Firebase;

#include "core/object/class_db.h"

GodotxFirebaseCore* GodotxFirebaseCore::instance = nullptr;

void GodotxFirebaseCore::_bind_methods() {
    ClassDB::bind_method(D_METHOD("initialize"), &GodotxFirebaseCore::initialize);
    ClassDB::bind_method(D_METHOD("is_ready"), &GodotxFirebaseCore::is_ready);
    
    ADD_SIGNAL(MethodInfo("initialized", PropertyInfo(Variant::BOOL, "success")));
    ADD_SIGNAL(MethodInfo("error", PropertyInfo(Variant::STRING, "message")));
}

GodotxFirebaseCore* GodotxFirebaseCore::get_singleton() { 
    return instance; 
}

void GodotxFirebaseCore::initialize() {
    NSLog(@"[GodotxFirebaseCore] initialize() called");
    
    if (is_initialized) {
        NSLog(@"[GodotxFirebaseCore] Already initialized");
        emit_signal("initialized", true);
        return;
    }
    
    @try {
        if ([FIRApp defaultApp] == nil) {
            [FIRApp configure];
            NSLog(@"[GodotxFirebaseCore] Firebase configured");
        }
        
        is_initialized = true;
        emit_signal("initialized", true);
    }
    @catch (NSException *exception) {
        NSLog(@"[GodotxFirebaseCore] Firebase initialization failed: %@", exception.reason);
        emit_signal("initialized", false);
        emit_signal("error", String([exception.reason UTF8String]));
    }
}

bool GodotxFirebaseCore::is_ready() const {
    return is_initialized;
}

GodotxFirebaseCore::GodotxFirebaseCore() {
    ERR_FAIL_COND(instance != NULL);
    instance = this;
    is_initialized = false;
    NSLog(@"[GodotxFirebaseCore] Created");
}

GodotxFirebaseCore::~GodotxFirebaseCore() {
    if (instance == this) {
        instance = nullptr;
    }
}

