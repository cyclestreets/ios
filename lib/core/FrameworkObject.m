//
//  FrameworkObject.m
//
//
//  Created by Neil Edwards on 04/11/2010.
//  Copyright 2010 CycleStreets.. All rights reserved.
//

#import "FrameworkObject.h"


@implementation FrameworkObject
@synthesize notifications;
@synthesize requestIDs;

/***********************************************************/
// dealloc
/***********************************************************/
- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    [notifications release], notifications = nil;
    [requestIDs release], requestIDs = nil;
	
    [super dealloc];
}




/***********************************************************/
// - (id)init
//
/***********************************************************/
- (id)init
{
    self = [super init];
    if (self) {
        NSMutableArray *arr=[[NSMutableArray alloc]init];
        self.notifications=arr;
        [arr release];
        NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
		self.requestIDs=dict;
        [dict release];
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
