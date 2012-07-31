//
//  StyleManager.h
//
//
//  Created by neil on 25/11/2009.
//  Copyright 2009 Buffer. All rights reserved.
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
	NSMutableDictionary *uiimages;
    NSDictionary *test;
	
	id<StyleManagerDelegate> __unsafe_unretained delegate;
	
}
@property (nonatomic, strong) NSDictionary *styleDict;
@property (nonatomic, strong) NSDictionary *colors;
@property (nonatomic, strong) NSDictionary *fonts;
@property (nonatomic, strong) NSMutableDictionary *uiimages;
@property (nonatomic, unsafe_unretained) id<StyleManagerDelegate> delegate;

SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(StyleManager);
//
-(UIFont*)fontForType:(NSString*)type;
-(UIColor*)colorForType:(NSString*)type;
-(UIImage*)imageForType:(NSString*)type;

-(void)initialise;

@end
