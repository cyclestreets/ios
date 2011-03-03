//
//  ConnectionValidator.h
//  RacingUK
//
//  Created by Neil Edwards on 18/07/2009.
//  Copyright 2009 buffer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SynthesizeSingleton.h"

@protocol ConnectionValidatorDelegate <NSObject>

-(void)connectionIsAvailable;
-(void)connectionIsUnavailble;


@end



@interface ConnectionValidator : NSObject {
	BOOL networkAvailable;
	NSURLConnection *myConnection;
	
	id<ConnectionValidatorDelegate> delegate;
}
@property (nonatomic) BOOL networkAvailable;
@property (nonatomic,retain) NSURLConnection *myConnection;
@property (nonatomic,assign) id<ConnectionValidatorDelegate>  delegate;
SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(ConnectionValidator);
-(void)isNetworkAvailable;
@end
