//
//  FrameworkObject.m
//
//
//  Created by Neil Edwards on 04/11/2010.
//  Copyright 2010 Buffer. All rights reserved.
//

#import "FrameworkObject.h"


@implementation FrameworkObject
@synthesize notifications;
@synthesize requestIDs;






/***********************************************************/
// - (id)init
//
/***********************************************************/
- (id)init
{
    self = [super init];
    if (self) {
        self.notifications=[[NSMutableArray alloc]init];
		self.requestIDs=[[NSMutableDictionary alloc]init];
		[self listNotificationInterests];
    }
    return self;
}



//
/***********************************************
 * @description			SYSTEM NOTIFICATION SUPPORT
 ***********************************************/
//

-(void)listNotificationInterests{
	
	[self addNotifications];
}


-(void)addNotifications{
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	for (int i=0; i<[notifications count]; i++) {
		
		[[NSNotificationCenter defaultCenter]
		 addObserver:self
		 selector:@selector(didReceiveNotification:)
		 name:[notifications objectAtIndex:i]
		 object:nil];
		
	}
	
}

-(void)didReceiveNotification:(NSNotification*)notification{
	
	
	
	
}


//
/***********************************************
 * @description			DATA REQUEST SUPPORT
 ***********************************************/
//

-(void)addRequestID:(NSString*)request{
	if([requestIDs objectForKey:request]==nil){
		[requestIDs setObject:request forKey:request];
	}
}

-(BOOL)removeRequestID:(NSString*)request{
	
	if([requestIDs objectForKey:request]!=nil){
		[requestIDs removeObjectForKey:request];
		return YES;
	}
	return NO;
}

-(BOOL)isRegisteredForRequest:(NSString*)request{
	return [requestIDs objectForKey:request]!=nil;
}


@end
