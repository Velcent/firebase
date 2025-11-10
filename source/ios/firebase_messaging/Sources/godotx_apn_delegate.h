#ifndef GODOTX_APN_DELEGATE_H
#define GODOTX_APN_DELEGATE_H

#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>

@interface GodotxAPNDelegate : NSObject <UIApplicationDelegate>

+ (instancetype)shared;

@end

#endif // GODOTX_APN_DELEGATE_H

