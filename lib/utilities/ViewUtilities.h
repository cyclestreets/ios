//
//  ViewUtilities.h
//  CycleStreets
//
//  Created by Neil Edwards on 03/12/2009.
//  Copyright 2009 CycleStreets.. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GlobalUtilities.h"
#import <QuartzCore/QuartzCore.h>

// alignment definitions
#define NONE @"none"
#define LEFT @"left"
#define RIGHT @"right"
#define CENTER @"center"
#define TOP @"top"
#define	BOTTOM @"bottom"
#define HORIZONTAL @"horizontal"
#define	VERTICAL @"vertical"


@interface ViewUtilities : NSObject {

}


+(void)alignView:(UIView*)child withView:(UIView*)view :(LayoutBoxAlignMode)horizontal :(LayoutBoxAlignMode)vertical;
+(void)distributeItems:(NSArray*)items inDirection:(LayoutBoxLayoutMode)direction :(int)dimension :(int)inset;
+(void)removeAllSubViewsForView:(UIView*)view;
+(UIAlertView*)createTextEntryAlertView:(NSString*)title fieldText:(NSString*)fieldText delegate:(id)delegate;

// draws bottom outside edge shadow
+(void)drawUIViewEdgeShadow:(UIView*)view atPosition:(NSString*)position;

// draws top and bottom inset shadow
+(void)drawUIViewInsetShadow:(UIView*)view;

// draws side and top inset shadow
+(void)drawInsertedViewShadow:(UIView*)view;

+ (CAGradientLayer *)shadowAsInverse:(BOOL)inverse :(UIView*)view;


// adds page curl effect to image views
+ (void)renderPaperCurl:(UIView*)imgView;

@end
