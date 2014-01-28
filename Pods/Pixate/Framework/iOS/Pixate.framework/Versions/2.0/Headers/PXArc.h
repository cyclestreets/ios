//
//  PXArc.h
//  Pixate
//
//  Created by Kevin Lindsey on 9/4/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PXShape.h"

/**
 *  A PXShape subclass used to render arcs
 */
@interface PXArc : PXShape

/**
 *  A point indicating the location of the center of this arc.
 */
@property (nonatomic) CGPoint center;

/**
 *  A value indicating the size of the radius of this arc.
 *
 *  This value may be negative, but it will be normalized to a positive value.
 */
@property (nonatomic) CGFloat radius;

/**
 *  A value indicating the starting angle for this arc
 */
@property (nonatomic) CGFloat startingAngle;

/**
 *  A value indicating the ending angle for this arc
 */
@property (nonatomic) CGFloat endingAngle;

@end
