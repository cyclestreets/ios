//
//  PXClassUtils.h
//  Pixate
//
//  Created by Kevin Lindsey on 1/4/13.
//  Copyright (c) 2013 Pixate, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PXClassUtils : NSObject

+ (NSString *)classDescriptionForObject:(id)object;
+ (NSString *)classDescription:(Class)c;

@end
