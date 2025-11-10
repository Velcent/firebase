#import "godotx_apn_delegate.h"
#include "godotx_firebase_messaging.h"
#import "drivers/apple_embedded/godot_app_delegate.h"

@import Firebase;

// Auto-register the delegate when the plugin loads
struct APNDelegateInitializer {
    APNDelegateInitializer() {
        [GDTApplicationDelegate addService:[GodotxAPNDelegate shared]];
        NSLog(@"[GodotxAPNDelegate] Registered with Godot application delegate");
    }
};

static APNDelegateInitializer initializer;

@implementation GodotxAPNDelegate

- (instancetype)init {
    self = [super init];
    if (self) {
        NSLog(@"[GodotxAPNDelegate] Initialized");
    }
    return self;
}

+ (instancetype)shared {
    static GodotxAPNDelegate *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[GodotxAPNDelegate alloc] init];
    });
    return sharedInstance;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"[GodotxAPNDelegate] Received APN device token");
    
    // Set APNs token in Firebase Messaging (in case swizzling is disabled or as fallback)
    [FIRMessaging messaging].APNSToken = deviceToken;
    
    // Convert device token to hex string
    const unsigned char *data = (const unsigned char *)[deviceToken bytes];
    NSMutableString *token = [NSMutableString string];
    
    for (NSUInteger i = 0; i < [deviceToken length]; i++) {
        [token appendFormat:@"%02.2hhX", data[i]];
    }
    
    NSLog(@"[GodotxAPNDelegate] APN Token: %@", token);
    
    // Notify Godot about the APN token
    dispatch_async(dispatch_get_main_queue(), ^{
        if (GodotxFirebaseMessaging::instance) {
            GodotxFirebaseMessaging::instance->emit_signal("apn_token_received", String([token UTF8String]));
        }
    });
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"[GodotxAPNDelegate] Failed to register for remote notifications: %@", error.localizedDescription);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (GodotxFirebaseMessaging::instance) {
            String error_msg = String("Failed to register for APNs: ") + String([error.localizedDescription UTF8String]);
            GodotxFirebaseMessaging::instance->emit_signal("error", error_msg);
        }
    });
}

@end

