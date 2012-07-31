//
//  NSDate+NSDateRFC3339.h
//  RacingUK
//
//  Created by Neil Edwards on 14/12/2011.
//  Copyright (c) 2011 Chroma. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (NSDateRFC3339)

// convert 2011-12-14T12:40:00+0000 style string to valid NSDate objects

+(NSDate*)dateFromRFC3339:(NSString *)dateString;

-(NSString*)RFC3339String;

@end
