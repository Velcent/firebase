#import "godotx_apn_delegate.h"
#include "godotx_firebase_messaging.h"
#import "drivers/apple_embedded/godot_app_delegate.h"

@import Firebase;

static NSString *APNSTokenToString(NSData *token) {
    const unsigned char *data = (const unsigned char *)[token bytes];
    NSMutableString *tokenString = [NSMutableString string];

    for (NSUInteger i = 0; i < [token length]; i++) {
        [tokenString appendFormat:@"%02.2hhX", data[i]];
    }

    return tokenString;
}

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

    // Set APNs token in Firebase Messaging
    [FIRMessaging messaging].APNSToken = deviceToken;

#if DEBUG
    [FIRMessaging messaging].APNSTokenType = FIRMessagingAPNSTokenTypeSandbox;
    NSLog(@"[GodotxAPNDelegate] APNs token type set to Sandbox");
#else
    [FIRMessaging messaging].APNSTokenType = FIRMessagingAPNSTokenTypeProd;
    NSLog(@"[GodotxAPNDelegate] APNs token type set to Production");
#endif

    NSString *token = APNSTokenToString(deviceToken);
    NSLog(@"[GodotxAPNDelegate] APN Token: %@", token);

    dispatch_async(dispatch_get_main_queue(), ^{
        if (GodotxFirebaseMessaging::instance) {
            GodotxFirebaseMessaging::instance->emit_signal("messaging_apn_token_received", String([token UTF8String]));
        }
    });
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"[GodotxAPNDelegate] Failed to register for remote notifications: %@", error.localizedDescription);

    dispatch_async(dispatch_get_main_queue(), ^{
        if (GodotxFirebaseMessaging::instance) {
            String error_msg = String("Failed to register for APNs: ") + String([error.localizedDescription UTF8String]);
            GodotxFirebaseMessaging::instance->emit_signal("messaging_error", error_msg);
        }
    });
}

- (void)registerAsNotificationCenterDelegate {
    [UNUserNotificationCenter currentNotificationCenter].delegate = self;
    NSLog(@"[GodotxAPNDelegate] Registered as UNUserNotificationCenter delegate");
}

#pragma mark - UNUserNotificationCenterDelegate

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {

    NSDictionary *userInfo = notification.request.content.userInfo;
    NSLog(@"[GodotxAPNDelegate] Received notification in foreground: %@", userInfo);

    NSString *title = notification.request.content.title ?: @"";
    NSString *body = notification.request.content.body ?: @"";

    dispatch_async(dispatch_get_main_queue(), ^{
        if (GodotxFirebaseMessaging::instance) {
            GodotxFirebaseMessaging::instance->emit_signal("messaging_message_received",
                String([title UTF8String]),
                String([body UTF8String]));
        }
    });

    if (@available(iOS 14.0, *)) {
        completionHandler(UNNotificationPresentationOptionBanner | UNNotificationPresentationOptionSound | UNNotificationPresentationOptionBadge);
    } else {
        completionHandler(UNNotificationPresentationOptionAlert | UNNotificationPresentationOptionSound | UNNotificationPresentationOptionBadge);
    }
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
didReceiveNotificationResponse:(UNNotificationResponse *)response
         withCompletionHandler:(void (^)(void))completionHandler {

    NSDictionary *userInfo = response.notification.request.content.userInfo;
    NSLog(@"[GodotxAPNDelegate] User tapped notification: %@", userInfo);

    NSString *title = response.notification.request.content.title ?: @"";
    NSString *body = response.notification.request.content.body ?: @"";

    dispatch_async(dispatch_get_main_queue(), ^{
        if (GodotxFirebaseMessaging::instance) {
            GodotxFirebaseMessaging::instance->emit_signal("messaging_message_received",
                String([title UTF8String]),
                String([body UTF8String]));
        }
    });

    completionHandler();
}

@end

