//
//  PXShadow.h
//  Pixate
//
//  Created by Kevin Lindsey on 8/31/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PXShadowPaint.h"

/**
 *  PXShadow is used to capture all settings needed to render a box shadow.
 */
@interface PXShadow : NSObject <PXShadowPaint>

/**
 *  A flag indicating whether the shadow should be applied inside or outside of the contour being shadowed
 */
@property (nonatomic) BOOL inset;

/**
 *  The x-displacement for the shadow
 */
@property (nonatomic) CGFloat horizontalOffset;

/**
 *  The y-displacment for the shadow
 */
@property (nonatomic) CGFloat verticalOffset;

/**
 *  The blur amount for the shadow
 */
@property (nonatomic) CGFloat blurDistance;

/**
 *  The spread amount of the blur
 */
@property (nonatomic) CGFloat spreadDistance;

/**
 *  The color of the shadow
 */
@property (nonatomic, strong) UIColor *color;

/**
 *  The blend mode to use when applying this shadow
 */
@property (nonatomic) CGBlendMode blendMode;

@end
