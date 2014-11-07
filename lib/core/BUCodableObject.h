//
//  BUCodableObject.h
//
//  Created by Neil Edwards on 12/02/2014.
//

#import <Foundation/Foundation.h>

@interface BUCodableObject : NSObject<NSCoding>

- (NSArray *)codableProperties;
+ (NSArray *)uncodableProperties;

@end
