//
//  PushNotificationManager.m
//
//
//  Created by Neil Edwards on 12/01/2011.
//  Copyright 2011 buffer. All rights reserved.
//

#import "PushNotificationManager.h"
#import "StringUtilities.h"
#import "GlobalUtilities.h"
#import "AppConstants.h"


@implementation PushNotificationManager
SYNTHESIZE_SINGLETON_FOR_CLASS(PushNotificationManager);
@synthesize deviceToken;
@synthesize deviceTokenString;
@synthesize deviceAlias;
@synthesize isRegistered;
@synthesize message;


-(id)init{
	
	if (self = [super init])
	{
		isRegistered=NO;
		self.deviceTokenString=nil;
		self.deviceAlias=[[UIDevice currentDevice] name];
	}
	return self;
	
}


//
/***********************************************
 * @description			call from AppDelegate
 ***********************************************/
//
-(void)didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)data{
	
	BetterLog(@"");
		
	self.deviceToken = data;
	
	self.deviceTokenString=[[[[data description]
							stringByReplacingOccurrencesOfString: @"<" withString: @""] 
							stringByReplacingOccurrencesOfString: @">" withString: @""] 
							stringByReplacingOccurrencesOfString: @" " withString: @""];
	
	
	[self registerDeviceWithNotificationSystem];
	
	
}


-(void)removeDeviceFromNotificationSystem{
	
	if(deviceToken!=nil){
		
		[[UAirship shared] unRegisterDeviceToken];
		isRegistered=NO;
		
	}
}

- (void)registerDeviceTokenSucceeded{
	
	BetterLog(@"");
	
	isRegistered=YES;
	
	[[NSNotificationCenter defaultCenter] postNotificationName:PUSHNOTIFICATIONTOKENAVAILABLE object:nil];
}


- (void)registerDeviceTokenFailed:(UA_ASIHTTPRequest *)request{
	BetterLog(@"Unable to register Device Token %@ with UA",deviceToken);
}


-(void)registerDeviceWithNotificationSystem{
	
	if(deviceToken!=nil){		
		if(isRegistered==NO){						
			[[UAirship shared] registerDeviceToken:deviceToken withAlias:deviceAlias];			 
		}		
	}
}

//
/***********************************************
 * @description			Notification comes through during app opearation
 ***********************************************/
//
-(void)didReceiveRemoteNotification:(NSDictionary*)userInfo{
	
	BetterLog(@"Notification Received: %@",[userInfo description]);
	
	if ([[userInfo allKeys] containsObject:@"aps"]) { 
		
		if([[[userInfo objectForKey:@"aps"] allKeys] containsObject:@"alert"]) {
			
			NSDictionary *alertDict = [userInfo objectForKey:@"aps"];
			
			if ([[alertDict objectForKey:@"alert"] isKindOfClass:[NSString class]]) {
				// The alert is a single string message so we can display it
				message = [alertDict valueForKey:@"alert"];
				
			} else {
				// The alert is a a dictionary with more details, let's just get the message without localization
				// This should be customized to fit your message details or usage scenario
				message = [[alertDict valueForKey:@"alert"] valueForKey:@"body"];
				
			}
			
		} else {
			// There was no Alert content - there may be badge, sound or other info
			message = @"No Alert content";
		}
		
	} else {
		// There was no Apple Push content - there may be custom JSON	
		message = @"No APS content";
	}
	
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Remote Notification" 
                                                    message: message
                                                   delegate: nil
                                          cancelButtonTitle: @"OK"
                                          otherButtonTitles: nil];
	[alert show];
	
}

@end
