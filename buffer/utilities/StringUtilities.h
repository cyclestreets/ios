//
//  StringUtilities.h
//  RacingUK
//
//  Created by Neil Edwards on 09/12/2009.
//  Copyright 2009 Chroma. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface StringUtilities : NSObject {

}
+(NSString*)returnPlaceNumberString:(int)position;
+(NSString*)ordinalFromIndex:(int)position;
+(NSString*)fileNameFromURL:(NSString*)url :(NSString*)delimiter;
+(NSMutableString*)urlFromParameters:(va_list)args url:(NSMutableString*)url;
+(NSMutableString*)urlFromParameterArray:(NSMutableArray*)args url:(NSMutableString*)url;
+(NSString*)currencyFromCommaSeparatedString:(NSString*)str;
+(NSString*)currencyFromDecimalString:(NSString*)str;
+ (NSString*) newEncodedString:(NSData*)data;
+ (NSString*) stringWithUUID;
+(NSString*)pathFromURL:(NSString*)url :(NSString*)delimiter;
@end
