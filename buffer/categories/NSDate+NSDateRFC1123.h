//
//  NSDate+RFC1123.h
//  BlytheCon
//
//  Created by Neil Edwards on 02/09/2010.
//  Copyright 2010 buffer. All rights reserved.
//

#import <Foundation/Foundation.h>


/** Category on NSDate to support rfc1123 formatted date strings.
 http://blog.mro.name/2009/08/nsdateformatter-http-header/ and
 http://www.w3.org/Protocols/rfc2616/rfc2616-sec3.html#sec3.3.1
 */
@interface NSDate (NSDateRFC1123)

/**
 Convert a RFC1123 'Full-Date' string
 (http://www.w3.org/Protocols/rfc2616/rfc2616-sec3.html#sec3.3.1)
 into NSDate.
 */
+(NSDate*)dateFromRFC1123:(NSString*)value_;

/**
 Convert NSDate into a RFC1123 'Full-Date' string
 (http://www.w3.org/Protocols/rfc2616/rfc2616-sec3.html#sec3.3.1).
 */
-(NSString*)rfc1123String;

@end
