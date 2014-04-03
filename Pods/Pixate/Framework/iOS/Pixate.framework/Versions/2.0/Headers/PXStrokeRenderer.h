//
//  PXStrokeRenderer.h
//  Pixate
//
//  Created by Kevin Lindsey on 7/2/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  The PXStrokeRenderer protocol specifies a method that a class must implement if it is to be used to render a stroke
 *  on a contour.
 */
@protocol PXStrokeRenderer <NSObject>

/**
 *  Determine if this strokes requires rendering with alpha
 */
@property (readonly, nonatomic, getter=isOpaque) BOOL opaque;

/**
 *  This method takes in a contour defined by a CGPath and applies whatever stroke effect it implements within the
 *  specified context
 *
 *  @param path The path contour onto which the stroke is to be applied
 *  @param context The context into which this stroke is to be rendered
 */
- (void)applyStrokeToPath:(CGPathRef)path withContext:(CGContextRef)context;

@end
