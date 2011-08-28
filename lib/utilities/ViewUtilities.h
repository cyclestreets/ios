//
//  ViewUtilities.h
//  RacingUK
//
//  Created by Neil Edwards on 03/12/2009.
//  Copyright 2009 Chroma. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GlobalUtilities.h"

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
@end
