//
//  NSString-URLEncoding.m
//
//
//  Created by Neil Edwards on 13/10/2010.
//  Copyright 2010 Buffer. All rights reserved.
//

#import "NSString-URLEncoding.h"

@implementation NSString (URLEncoding)
-(NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding {
	return (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
															   (__bridge CFStringRef)self,
															   NULL,
															   (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
															   CFStringConvertNSStringEncodingToEncoding(encoding));
}


@end
