//
//  NSString-URLEncoding.m
//
//
//  Created by Neil Edwards on 13/10/2010.
//  Copyright 2010 Buffer. All rights reserved.
//

#import "NSString-URLEncoding.h"
#import "StringUtilities.h"

@implementation NSString (URLEncoding)
-(NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding {
	return (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
															   (__bridge CFStringRef)self,
															   NULL,
															   (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
															   CFStringConvertNSStringEncodingToEncoding(encoding));
}


-(NSDictionary*)queryDictionary{
	
	NSMutableDictionary *dict=[NSMutableDictionary dictionary];
	
	NSArray *componentsArray=[self componentsSeparatedByString:@"&"];
	for (NSString *part in componentsArray){
		
		NSArray *parts=[part componentsSeparatedByString:@"="];
		if(parts.count<2){
			return nil;
		}
		
		NSString *key=(NSString*)parts.firstObject;
		key=key.stringByRemovingPercentEncoding;
		
		NSString *value=(NSString*)parts.lastObject;
		value=value.stringByRemovingPercentEncoding;
		
		dict[key]=value;
		
	}
	
	return [NSDictionary dictionaryWithDictionary:dict];
	
	
}


@end
