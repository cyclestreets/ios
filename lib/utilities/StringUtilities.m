//
//  StringUtilities.m
//
//
//  Created by Neil Edwards on 09/12/2009.
//  Copyright 2009 Chroma. All rights reserved.
//

#import "StringUtilities.h"
#import "RegexKitLite.h"
#import "NSDate+Helper.h"
#import "GlobalUtilities.h"
#import "NSDataAdditions.h"

@implementation StringUtilities



+(NSString*)ordinalFromIndex:(int)position{
	
	NSString *ordinal;
	
	switch (position % 100)
	{
		case 0:
			ordinal=@"";
			break;
		case 11:
		case 12:
		case 13:
			ordinal= @"th";
			break;
		default:
			switch (position % 10)
		{
			case 1:
				ordinal= @"st";
				break;
			case 2:
				ordinal= @"nd";
				break;
			case 3:
				ordinal= @"rd";
				break;
			default:
				ordinal= @"th";
		}
	}
	
	return ordinal;
	
	
}

+(NSString*)returnPlaceNumberString:(int)position{
	
	return [NSString stringWithFormat:@"%i%@",position,[StringUtilities ordinalFromIndex:position]];
	
}


+(NSString*)fileNameFromURL:(NSString*)url :(NSString*)delimiter{
	NSArray *path=[url componentsSeparatedByString:delimiter];
	return [path objectAtIndex:[path count]-1];
}

+(NSString*)pathFromURL:(NSString*)url :(NSString*)delimiter{
	NSMutableArray *path=[NSMutableArray arrayWithArray:[url componentsSeparatedByString:delimiter]];
	if([path count]>0){
		[path removeLastObject];
	}
	return [path componentsJoinedByString:@"/"];
}

+(NSMutableString*)urlFromParameters:(va_list)args url:(NSMutableString*)url{
	id param;
	
	while ((param = va_arg(args, NSString*)))
		[url appendFormat:@"%@/",param];
	
	return url;
	
}

+(NSMutableString*)urlFromParameterArray:(NSMutableArray*)args url:(NSMutableString*)url{
	
	for (int i=0; i<[args count]; i++) {
		[url appendFormat:@"%@/",[args objectAtIndex:i]];
	}
	
	return url;
	
}

+(NSString*)currencyFromDecimalString:(NSString*)str{
	
	NSNumberFormatter *currencyformatter=[[NSNumberFormatter alloc]init];
	[currencyformatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	[currencyformatter setCurrencySymbol:@"£"];
	[currencyformatter setMaximumFractionDigits:2];
	str=[currencyformatter stringFromNumber:[NSNumber numberWithFloat:[str floatValue]] ];
	[currencyformatter release];
	return str;
	
}

+(NSString*)currencyFromCommaSeparatedString:(NSString*)str{
	
	NSString *result=[str stringByReplacingOccurrencesOfString:@"," withString:@""];
	
	NSNumberFormatter *currencyformatter=[[NSNumberFormatter alloc]init];
	[currencyformatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	[currencyformatter setCurrencyGroupingSeparator:@","];
	[currencyformatter setCurrencySymbol:@"£"];
	[currencyformatter setMaximumFractionDigits:0];
	result=[currencyformatter stringFromNumber:[NSNumber numberWithFloat:[result floatValue]] ];
	[currencyformatter release];
	
	return result;
}


+ (NSString*) newEncodedString:(NSData*)data
{
    static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
	
    const int size = ((data.length + 2)/3)*4;
    uint8_t output[size];
	
    const uint8_t* input = (const uint8_t*)[data bytes];
    for (int i = 0; i < data.length; i += 3)
    {
        int value = 0;
        for (int j = i; j < (i + 3); j++)
        {
            value <<= 8;
            if (j < data.length)
                value |= (0xFF & input[j]);
        }
		
        const int index = (i / 3) * 4;
        output[index + 0] =  table[(value >> 18) & 0x3F];
        output[index + 1] =  table[(value >> 12) & 0x3F];
        output[index + 2] = (i + 1) < data.length ? table[(value >> 6)  & 0x3F] : '=';
        output[index + 3] = (i + 2) < data.length ? table[(value >> 0)  & 0x3F] : '=';
    }   
	
	
    return  [[NSString alloc] initWithBytes:output length:size encoding:NSASCIIStringEncoding];
}


+ (NSString*) stringWithUUID {
	CFUUIDRef	uuidObj = CFUUIDCreate(nil);//create a new UUID
	//get the string representation of the UUID
	NSString	*uuidString = (NSString*)CFUUIDCreateString(nil, uuidObj);
	CFRelease(uuidObj);
	return [uuidString autorelease];
}



+(NSURL*)validateURL:(NSString*)urlstring{
	
	NSString *regexString=@"([A-Za-z][A-Za-z0-9+.-]{1,120}:[A-Za-z0-9/](([A-Za-z0-9$_.+!*,;/?:@&~=-])|%[A-Fa-f0-9]{2}){1,333}(#([a-zA-Z0-9][a-zA-Z0-9$_.+!*,;/?:@&~=%-]{0,1000}))?)";
	
	BOOL validated = [urlstring isMatchedByRegex:regexString];
	
    if(validated==YES) {
		NSURL *testurl = [NSURL URLWithString: urlstring];
        NSString *scheme = [testurl scheme];
        if( scheme == nil ) {
            urlstring = [@"http://" stringByAppendingString: urlstring];
            testurl = [NSURL URLWithString: urlstring];
        }
        return testurl;
    }
    return nil;
	
}

+(BOOL)validateEmail:(NSString*)emailstring{
	
	NSString *regexString=@"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
	BOOL validated = [emailstring isMatchedByRegex:regexString];
	
	return validated;
	
}


// From: http://www.cocoadev.com/index.pl?BaseSixtyFour
+ (NSString*)base64forData:(NSData*)theData {
    const uint8_t* input = (const uint8_t*)[theData bytes];
    NSInteger length = [theData length];
    
    static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
    
    NSMutableData* data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t* output = (uint8_t*)data.mutableBytes;
    
    NSInteger i;
    for (i=0; i < length; i += 3) {
        NSInteger value = 0;
        NSInteger j;
        for (j = i; j < (i + 3); j++) {
            value <<= 8;
            
            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }
        
        NSInteger theIndex = (i / 3) * 4;
        output[theIndex + 0] =                    table[(value >> 18) & 0x3F];
        output[theIndex + 1] =                    table[(value >> 12) & 0x3F];
        output[theIndex + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F] : '=';
        output[theIndex + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F] : '=';
    }
    
    return [[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding] autorelease];
}

+(NSString *) urlencode: (NSString *) unencodedString
{
    NSString * encodedString = (NSString *)CFURLCreateStringByAddingPercentEscapes(
																				   NULL,
																				   (CFStringRef)unencodedString,
																				   NULL,
																				   (CFStringRef)@"!*'();:@&=+$,/?%#[]",
																				   kCFStringEncodingUTF8 );
	return [encodedString autorelease];
}

+ (NSString *)stringByDecodingXMLEntities:(NSString*)str {
    NSUInteger myLength = [str length];
    NSUInteger ampIndex = [str rangeOfString:@"&" options:NSLiteralSearch].location;
	
    // Short-circuit if there are no ampersands.
    if (ampIndex == NSNotFound) {
        return str;
    }
    // Make result string with some extra capacity.
    NSMutableString *result = [NSMutableString stringWithCapacity:(myLength * 1.25)];
	
    // First iteration doesn't need to scan to & since we did that already, but for code simplicity's sake we'll do it again with the scanner.
    NSScanner *scanner = [NSScanner scannerWithString:str];
	
    [scanner setCharactersToBeSkipped:nil];
	
    NSCharacterSet *boundaryCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@" \t\n\r;"];
	
    do {
        // Scan up to the next entity or the end of the string.
        NSString *nonEntityString;
        if ([scanner scanUpToString:@"&" intoString:&nonEntityString]) {
            [result appendString:nonEntityString];
        }
        if ([scanner isAtEnd]) {
            goto finish;
        }
        // Scan either a HTML or numeric character entity reference.
        if ([scanner scanString:@"&amp;" intoString:NULL])
            [result appendString:@"&"];
        else if ([scanner scanString:@"&apos;" intoString:NULL])
            [result appendString:@"'"];
        else if ([scanner scanString:@"&quot;" intoString:NULL])
            [result appendString:@"\""];
        else if ([scanner scanString:@"&lt;" intoString:NULL])
            [result appendString:@"<"];
        else if ([scanner scanString:@"&gt;" intoString:NULL])
            [result appendString:@">"];
        else if ([scanner scanString:@"&#" intoString:NULL]) {
            BOOL gotNumber;
            unsigned charCode;
            NSString *xForHex = @"";
			
            // Is it hex or decimal?
            if ([scanner scanString:@"x" intoString:&xForHex]) {
                gotNumber = [scanner scanHexInt:&charCode];
            }
            else {
                gotNumber = [scanner scanInt:(int*)&charCode];
            }
			
            if (gotNumber) {
                [result appendFormat:@"%C", charCode];
				
				[scanner scanString:@";" intoString:NULL];
            }
            else {
                NSString *unknownEntity = @"";
				
				[scanner scanUpToCharactersFromSet:boundaryCharacterSet intoString:&unknownEntity];
				
				
				[result appendFormat:@"&#%@%@", xForHex, unknownEntity];
				
                //[scanner scanUpToString:@";" intoString:&unknownEntity];
                //[result appendFormat:@"&#%@%@;", xForHex, unknownEntity];
                NSLog(@"Expected numeric character entity but got &#%@%@;", xForHex, unknownEntity);
				
            }
			
        }
        else {
			NSString *amp;
			
			[scanner scanString:@"&" intoString:&amp];      //an isolated & symbol
			[result appendString:amp];
			
			/*
			 NSString *unknownEntity = @"";
			 [scanner scanUpToString:@";" intoString:&unknownEntity];
			 NSString *semicolon = @"";
			 [scanner scanString:@";" intoString:&semicolon];
			 [result appendFormat:@"%@%@", unknownEntity, semicolon];
			 NSLog(@"Unsupported XML character entity %@%@", unknownEntity, semicolon);
			 */
        }
		
    }
    while (![scanner isAtEnd]);
	
finish:
    return result;
}


+(NSString*)conformDateString:(NSString*)datestring toFormat:(NSString*)format{
	
	BOOL fixed=NO;
	NSString *fixedDateString=nil;
	NSString	*errorString=nil;
	NSDictionary	*conformDict=nil;
	NSDate *testDate=[NSDate dateFromString:datestring withFormat:format];
	
	if(testDate==nil){
		
		if([format isEqualToString:[NSDate dbFormatString]]){
			conformDict=[StringUtilities conformDBFormatString:datestring];
		}
		
		fixed=UNBOX_BOOL([conformDict objectForKey:STATE]);
		
		if(fixed==YES){
			fixedDateString=[conformDict objectForKey:@"conformString"];
		}else{
			errorString=[conformDict objectForKey:@"errorString"];
		}
		
		
	}else{
		return datestring;
	}
	
	if(fixed==NO){
		NSLog(@"[ERROR] DateString conform Error: %@",errorString);
		return [NSDate stringFromDate:[NSDate date]];
	}else{
		return fixedDateString;
	}
	
}


+(NSDictionary*)conformDBFormatString:(NSString*)dateString{
	
	NSString *conformedString=nil;
	NSString *errorString=@"DateStringConformError";
	BOOL conforms=NO;
	
	NSMutableArray *darr=(NSMutableArray*)[dateString componentsSeparatedByString:@" "];
	NSMutableArray *datearr=(NSMutableArray*)[[darr objectAtIndex:0] componentsSeparatedByString:@"-"];
	NSMutableArray *timearr=(NSMutableArray*)[[darr objectAtIndex:1] componentsSeparatedByString:@":"];
	
	if([datearr count]>3){
		[GlobalUtilities trimArray:datearr FromIndex:3];
		[darr replaceObjectAtIndex:0 withObject:[datearr componentsJoinedByString:@"-"]];
	}
	
	if([timearr count]>3){
		[GlobalUtilities trimArray:timearr FromIndex:3];
		[darr replaceObjectAtIndex:1 withObject:[timearr componentsJoinedByString:@":"]];
	}
	
	conformedString=[darr componentsJoinedByString:@" "];
	conforms=[StringUtilities validateUnixDate:conformedString];
	
	if(conforms==YES){
		return [NSMutableDictionary dictionaryWithObjectsAndKeys:BOX_BOOL(YES),STATE,conformedString, @"conformString",nil];
	}else{
		return [NSMutableDictionary dictionaryWithObjectsAndKeys:BOX_BOOL(NO),STATE,errorString, @"errorString",nil];
	}
	
}

		   
+(BOOL)validateUnixDate:(NSString*)datestring{
   
   NSString *regexString=@"[0-9]{4,4}-[0-9]{2,2}-[0-9]{2,2} [0-9]{2,2}:[0-9]{2,2}:[0-9]{2,2}";
   BOOL validated = [datestring isMatchedByRegex:regexString];
   
   return validated;
   
}

+(UIImage*)imageFromString:(NSString*)str{

	UIImage* image = [UIImage imageWithData:[NSData  dataWithBase64EncodedString:str]];
	return image;
}

@end
