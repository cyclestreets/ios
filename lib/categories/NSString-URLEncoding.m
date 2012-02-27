//
//  NSString-URLEncoding.m
//  CycleStreets
//
//  Created by Neil Edwards on 13/10/2010.
//  Copyright 2010 CycleStreets.. All rights reserved.
//

#import "NSString-URLEncoding.h"

@implementation NSString (URLEncoding)
-(NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding {
	return (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
															   (CFStringRef)self,
															   NULL,
															   (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
															   CFStringConvertNSStringEncodingToEncoding(encoding));
}
@end
