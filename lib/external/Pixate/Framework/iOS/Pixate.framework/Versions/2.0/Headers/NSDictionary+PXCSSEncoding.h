//
//  NSDictionary+PXCSSEncoding.h
//  Pixate
//
//  Created by Paul Colton on 12/18/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (PXCSSEncoding)

- (NSString *)toCSS;
- (NSString *)toCSSWithKeys:(NSArray *)keys;

@end
