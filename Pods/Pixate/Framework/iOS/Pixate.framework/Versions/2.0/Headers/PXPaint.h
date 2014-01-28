//
//  PXPaint.h
//  Pixate
//
//  Created by Kevin Lindsey on 6/7/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  The PXPaint protocol specifies the properties and methods required for a class to be used for filling of a contour
 */
@protocol PXPaint <NSObject>

/**
 *  The blend mode to use when applying this fill
 */
@property (nonatomic) CGBlendMode blendMode;

/**
 *  Determine if this paint requires rendering with alpha
 */
@property (readonly, nonatomic, getter=isOpaque) BOOL opaque;

/**
 *  A method used to apply the implementations fill to the specified CGPath in the given CGContext
 *
 *  @param path The path to which the fill is to be applied
 *  @param context The context within which the fill is to be rendered
 */
- (void)applyFillToPath:(CGPathRef)path withContext:(CGContextRef)context;

/**
 *  Create a copy of this paint with colors lightened by the specified percent
 *
 *  @param percent A float between 0 and 100 inclusive
 */
- (id<PXPaint>)lightenByPercent:(CGFloat)percent;

/**
 *  Create a copy of this paint with colors darkened by the specified percent
 *
 *  @param percent A float between 0 and 100 inclusive
 */
- (id<PXPaint>)darkenByPercent:(CGFloat)percent;

@end
