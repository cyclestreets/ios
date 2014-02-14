//
//  PXBoundable.h
//  Pixate
//
//  Created by Kevin Lindsey on 12/19/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  The PXBoundable interface indicates that a class conforming to this protcol can have its bounds set and retrieved
 */
@protocol PXBoundable <NSObject>

/**
 *  The bounds of this rectangle
 */
@property (nonatomic) CGRect bounds;

@end
