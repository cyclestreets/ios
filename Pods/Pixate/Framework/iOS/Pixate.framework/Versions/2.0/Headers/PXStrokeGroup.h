//
//  PXStrokeGroup.h
//  Pixate
//
//  Created by Kevin Lindsey on 7/2/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PXStroke.h"

/**
 *  PXStrokeGroup allows a collection of PXStrokeRenderers to be treated as a single stroke. This is particularly useful
 *  when more than one stroke needs to be drawn for a given contour. Without this class, clones of the contour would
 *  have to be generated, one for each stroke to apply
 */
@interface PXStrokeGroup : NSObject <PXStrokeRenderer>

/**
 *  Add the specified stroke to this instance's list of strokes
 *
 *  @param stroke The stroke to add to this group
 */
- (void)addStroke:(id<PXStrokeRenderer>)stroke;

@end
