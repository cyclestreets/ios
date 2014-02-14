//
//  PXOffsets.h
//  Pixate
//
//  Created by Kevin Lindsey on 12/17/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PXOffsets : NSObject

@property (nonatomic, readonly) CGFloat top;
@property (nonatomic, readonly) CGFloat right;
@property (nonatomic, readonly) CGFloat bottom;
@property (nonatomic, readonly) CGFloat left;

@property (nonatomic, readonly) BOOL hasOffset;

- (id)initWithTop:(CGFloat)top right:(CGFloat)right bottom:(CGFloat)bottom left:(CGFloat)left;

@end
