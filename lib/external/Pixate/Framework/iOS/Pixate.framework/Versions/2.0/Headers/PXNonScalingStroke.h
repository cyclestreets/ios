//
//  PXNonScalingStroke.h
//  Pixate
//
//  Created by Kevin Lindsey on 7/26/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PXStroke.h"

/**
 *  PXNonScalingStroke is a special stroke implementation that tries its best to preserve its stroke width, in screen
 *  coordinates, regardless of the current transform being applied to the shape using this stroke
 */
@interface PXNonScalingStroke : PXStroke

@end
