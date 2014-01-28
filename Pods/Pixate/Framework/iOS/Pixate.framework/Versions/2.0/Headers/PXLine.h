//
//  PXLine.h
//  Pixate
//
//  Created by Kevin Lindsey on 6/6/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PXShape.h"

/**
 *  A PXShape sub-class used to render lines
 */
@interface PXLine : PXShape

/**
 *  A point indicating the location of the start of this line.
 */
@property (nonatomic) CGPoint p1;

/**
 *  A point indicating the location of the end of this line.
 */
@property (nonatomic) CGPoint p2;

/**
 *  Initializes a newly allocated line using the specified x and y locations
 *
 *  @param x1 The x coordinate of the start of the line
 *  @param y1 The y coordinate of the start of the line
 *  @param x2 The x coordinate of the end of the line
 *  @param y2 The y coordinate of the end of the line
 */
- (id)initX1:(CGFloat)x1 y1:(CGFloat)y1 x2:(CGFloat)x2 y2:(CGFloat)y2;

@end
