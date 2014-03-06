//
//  BUCodableObject.h
//  RacingUKiPad
//
//  Created by Neil Edwards on 12/02/2014.
//  Copyright (c) 2014 racinguk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BUCodableObject : NSObject<NSCoding>

- (NSArray *)codableProperties;
+ (NSArray *)uncodableProperties;

@end
