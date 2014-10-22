//
//  StringUtilities.h
//
//
//  Created by Neil Edwards on 09/12/2009.
//  Copyright 2009 Buffer. All rights reserved.
//

#import <Foundation/Foundation.h>

#define UUID_USER_DEFAULTS_KEY @"UUID"


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
+(NSString*)pathFromURL:(NSString*)url :(NSString*)delimiter; // extracts my.jpg from http://www.utl.com/images/my.jog
+(NSString*)pathStringFromURL:(NSString*)url :(NSString*)delimiter;  // extracts 3456 from http://www.utl.com/api/3456/

+(NSURL*)validateURL:(NSString*)urlstring;
+(BOOL)validateEmail:(NSString*)emailstring;
+(BOOL)validateQueryString:(NSString*)querystring;

+(NSString*)removeHTMLTag:(NSString*)tagname fromHTMLString:(NSString*)html;

+ (NSString*)base64forData:(NSData*)theData;
+(NSString *)Base64Encode:(NSData *)data;


+(NSString *) urlencode: (NSString *) unencodedString;
+ (NSString *)stringByDecodingXMLEntities:(NSString*)str;
+(NSDictionary*)conformDBFormatString:(NSString*)dateString;
+(NSString*)conformDateString:(NSString*)datestring toFormat:(NSString*)format;
+(BOOL)validateUnixDate:(NSString*)datestring;
+(NSString*)extractDayStringFromDate:(NSString*)date;

+(NSString*)urlFromGETURL:(NSString*)url;
+(NSString*)createCurrencyStringForValue:(NSString*)strvalue useSystemCurrency:(BOOL)useSystem usingSymbol:(NSString*)symbol useCurrencyScale:(NSInteger)currencyScale useGrouping:(BOOL)useGrouping;
+(NSString*)scaledCurrencyValue:(double)value;
+(NSString*)convertCurrencyIdentifierToSymbol:(NSString*)identifier;
+(NSString*)formattedCreditCardNumber:(NSString*)cardnumber;
+(NSString*)convertDayDurationToDateString:(int)duration;
+(NSString*)convertImageFilenameToRetina:(NSString*)filename;

+(NSString*)createAppUUID;


+(UIImage*)imageFromString:(NSString*)str;
+(NSString *)convertToKilometres:(NSString *)stringMiles;
@end
