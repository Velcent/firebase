#import "godotx_firebase_analytics.h"
#import <Foundation/Foundation.h>

@import FirebaseAnalytics;

#include "core/object/class_db.h"

GodotxFirebaseAnalytics* GodotxFirebaseAnalytics::instance = nullptr;

void GodotxFirebaseAnalytics::_bind_methods() {
    ClassDB::bind_method(D_METHOD("log_event", "event_name", "params"), &GodotxFirebaseAnalytics::log_event);
    
    ADD_SIGNAL(MethodInfo("event_logged", PropertyInfo(Variant::STRING, "event_name")));
    ADD_SIGNAL(MethodInfo("error", PropertyInfo(Variant::STRING, "message")));
}

static NSDictionary* dictionary_to_nsdict(const Dictionary& dict) {
    NSMutableDictionary* nsDict = [NSMutableDictionary dictionary];
    Array keys = dict.keys();
    
    for (int i = 0; i < keys.size(); i++) {
        String key = keys[i];
        Variant value = dict[key];
        
        NSString* nsKey = [NSString stringWithUTF8String:key.utf8().get_data()];
        
        if (value.get_type() == Variant::STRING) {
            nsDict[nsKey] = [NSString stringWithUTF8String:String(value).utf8().get_data()];
        } else if (value.get_type() == Variant::INT) {
            nsDict[nsKey] = @((int64_t)value);
        } else if (value.get_type() == Variant::FLOAT) {
            nsDict[nsKey] = @((double)value);
        } else if (value.get_type() == Variant::BOOL) {
            nsDict[nsKey] = @((bool)value);
        }
    }
    
    return nsDict;
}

GodotxFirebaseAnalytics* GodotxFirebaseAnalytics::get_singleton() { 
    return instance; 
}

void GodotxFirebaseAnalytics::log_event(String event_name, Dictionary params) {
    NSLog(@"[GodotxFirebaseAnalytics] log_event: %s", event_name.utf8().get_data());
    
    @try {
        NSString* nsEventName = [NSString stringWithUTF8String:event_name.utf8().get_data()];
        NSDictionary* nsParams = dictionary_to_nsdict(params);
        
        [FIRAnalytics logEventWithName:nsEventName parameters:nsParams];
        
        emit_signal("event_logged", event_name);
    }
    @catch (NSException *exception) {
        NSLog(@"[GodotxFirebaseAnalytics] Failed to log event: %@", exception.reason);
        emit_signal("error", String([exception.reason UTF8String]));
    }
}

GodotxFirebaseAnalytics::GodotxFirebaseAnalytics() {
    ERR_FAIL_COND(instance != NULL);
    instance = this;
    NSLog(@"[GodotxFirebaseAnalytics] Created");
}

GodotxFirebaseAnalytics::~GodotxFirebaseAnalytics() {
    if (instance == this) {
        instance = nullptr;
    }
}

