//
//  PXSolidPaint.h
//  Pixate
//
//  Created by Kevin Lindsey on 6/7/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PXPaint.h"

/**
 *  PXSolidPaint is used to fill a contour with a solid color
 */
@interface PXSolidPaint : NSObject <PXPaint>

/**
 *  The color used when filling a specified contour
 */
@property (nonatomic, strong) UIColor *color;

/**
 *  Allocate and initialize a new solid paint with the specified color
 *
 *  @param color The color of this paint
 */
+ (id)paintWithColor:(UIColor *)color;

/**
 *  Initialize a new solid paint with the specified color
 *
 *  @param color The color of this paint
 */
- (id)initWithColor:(UIColor *)color;

@end
