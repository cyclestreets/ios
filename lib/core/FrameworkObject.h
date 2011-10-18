//
//  FrameworkObject.h
//
//
//  Created by Neil Edwards on 04/11/2010.
//  Copyright 2010 Chroma. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FrameworkObject : NSObject {
	NSMutableArray						*notifications;
	NSMutableDictionary					*requestIDs;
}
@property (nonatomic, retain) NSMutableArray *notifications;
@property (nonatomic, retain) NSMutableDictionary *requestIDs;

-(void)listNotificationInterests;
-(void)didReceiveNotification:(NSNotification*)notification;
-(void)addNotifications;

-(void)addRequestID:(NSString*)request;
-(BOOL)removeRequestID:(NSString*)request;
-(BOOL)isRegisteredForRequest:(NSString*)request;

@end
