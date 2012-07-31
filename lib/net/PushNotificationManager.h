//
//  PushNotificationManager.h
//
//
//  Created by Neil Edwards on 12/01/2011.
//  Copyright 2011 buffer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SynthesizeSingleton.h"
#import "FrameworkObject.h"
#import "UAirship.h"


@interface PushNotificationManager : FrameworkObject <UARegistrationObserver> {
	
	NSData					*deviceToken;
	NSString				*deviceTokenString;
	NSString				*deviceAlias;
	BOOL					isRegistered;
	
	NSString				*message;
	
	

}
@property (nonatomic, strong) NSData *deviceToken;
@property (nonatomic, strong) NSString *deviceTokenString;
@property (nonatomic, strong) NSString *deviceAlias;
@property (nonatomic) BOOL isRegistered;
@property (nonatomic, strong) NSString *message;

SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(PushNotificationManager);

-(void)didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)data;
-(void)didReceiveRemoteNotification:(NSDictionary*)userInfo;
-(void)removeDeviceFromNotificationSystem;
-(void)registerDeviceWithNotificationSystem;
@end
