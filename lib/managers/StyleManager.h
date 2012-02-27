//
//  StyleManager.h
//  CycleStreets
//
//  Created by neil on 25/11/2009.
//  Copyright 2009 CycleStreets.. All rights reserved.
//
// manager class for UI styles, loads style plist and returns styles for consistent ui

#import <Foundation/Foundation.h>
#import "SynthesizeSingleton.h"

@protocol StyleManagerDelegate<NSObject>

@optional
-(void)startupFailedWithError:(NSString*)errorString;
-(void)startupComplete;


@end



@interface StyleManager : NSObject {
	
	// data
	NSDictionary *styleDict;
	NSDictionary *colors;
	NSDictionary *fonts;
	NSDictionary *uiimages;
	
	id<StyleManagerDelegate> delegate;
	
}
@property(nonatomic,retain)NSDictionary *styleDict;
@property(nonatomic,retain)NSDictionary *colors;
@property(nonatomic,retain)NSDictionary *fonts;
@property(nonatomic,retain)NSDictionary *uiimages;
@property(nonatomic,retain)id<StyleManagerDelegate> delegate;

SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(StyleManager);
//
-(UIFont*)fontForType:(NSString*)type;
-(UIColor*)colorForType:(NSString*)type;
-(UIImage*)imageForType:(NSString*)type;

-(void)initialise;

@end
