//
//  PXShadowGroup.h
//  Pixate
//
//  Created by Kevin Lindsey on 12/7/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PXShadowPaint.h"

/**
 *  A PXShadowGroup serves as a collection of PXShadowPaints
 */
@interface PXShadowGroup : NSObject <PXShadowPaint>

/**
 *  Returns the number of PXShadowPaints in this group
 */
@property (nonatomic, readonly) NSUInteger count;

/**
 *  The list of PXShadowPaints associated with this shadow group
 */
@property (nonatomic, readonly) NSArray *shadows;

/**
 *  Add a PXShapowPaint to this shadow group
 *
 *  @param shadow The PXShadowPaint to add
 */
- (void)addShadowPaint:(id<PXShadowPaint>)shadow;

@end
