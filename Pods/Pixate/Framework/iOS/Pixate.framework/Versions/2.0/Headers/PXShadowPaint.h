//
//  PXShadowPaint.h
//  Pixate
//
//  Created by Kevin Lindsey on 12/7/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  The PXShadowPaint protocol specifies the properties and methods required for a class to be used for shadowing of a
 *  contour
 */
@protocol PXShadowPaint <NSObject>

/**
 *  Apply an outer shadow to the specified path
 *
 *  @param path A path used to generate a shadow
 *  @param context The context into which to render the shadow
 */
- (void)applyOutsetToPath:(CGPathRef)path withContext:(CGContextRef)context;

/**
 *  Apply an inner shadow to the specified path
 *
 *  @param path A path used to generate a shadow
 *  @param context The context into which to render the shadow
 */
- (void)applyInsetToPath:(CGPathRef)path withContext:(CGContextRef)context;

@end
