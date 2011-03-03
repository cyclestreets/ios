//
//  StringManager.h
//  RacingUK
//
//  Created by Neil Edwards on 19/02/2010.
//  Copyright 2010 Chroma. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SynthesizeSingleton.h"

@protocol StringManagerDelegate<NSObject>

@optional
-(void)startupComplete;
-(void)startupFailedWithError:(NSString*)error;

@end


@interface StringManager : NSObject {
	
	NSDictionary *stringsDict;
	
	id<StringManagerDelegate> delegate;
	

}
@property(nonatomic,retain)NSDictionary *stringsDict;
@property(nonatomic,assign)id<StringManagerDelegate> delegate;

SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(StringManager);

-(void)initialise;
-(NSString*)stringForSection:(NSString*)section andType:(NSString*)type;
@end
