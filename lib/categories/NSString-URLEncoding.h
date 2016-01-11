//
//  NSString-URLEncoding.h
//
//
//  Created by Neil Edwards on 13/10/2010.
//  Copyright 2010 Buffer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (URLEncoding)
-(NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding;

-(NSDictionary*)queryDictionary;


@end
