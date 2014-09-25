//
//  StringUtilities.m
//
//
//  Created by Neil Edwards on 09/12/2009.
//  Copyright 2009 Buffer. All rights reserved.
//

#import "StringUtilities.h"
#import "RegexKitLite.h"
#import "NSDate+Helper.h"
#import "GlobalUtilities.h"
#import "NSString-Utilities.h"
#import "NSDataAdditions.h"

@implementation StringUtilities



+(NSString*)ordinalFromIndex:(int)position{
	
	NSString *ordinal;
	
	if(position==INT16_MAX){
		return @"";
	}
	
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
	
	if(position<0){
		return @"N/A";
	}else{
		return [NSString stringWithFormat:@"%i%@",position,[StringUtilities ordinalFromIndex:position]];
	}
}


+(NSString*)fileNameFromURL:(NSString*)url :(NSString*)delimiter{
	NSArray *path=[url componentsSeparatedByString:delimiter];
	return [path objectAtIndex:[path count]-1];
}
+(NSString*)pathStringFromURL:(NSString*)url :(NSString*)delimiter{
	NSArray *path=[url componentsSeparatedByString:delimiter];
	return [path objectAtIndex:[path count]-2];
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
	NSString	*str=nil;
	
	if(uuidObj){
		str = (__bridge_transfer NSString*)CFUUIDCreateString(nil, uuidObj);
		CFRelease(uuidObj);
	}
	return str;
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


//
/***********************************************
 * @description			Removes occurances of <tag></tag>, this isnt 100% ok
 ***********************************************/
//
+(NSString*)removeHTMLTag:(NSString*)tagname fromHTMLString:(NSString*)html{
	
	NSString *regexString=[NSString stringWithFormat:@"</?(?i:%@)(.|\n)*?>",tagname];
	
	// if we want to support an arr, the reg ex is this
	//NSString *regexString=@"</?(?i:object|param)(.|\n)*?>";
	
	NSArray *testarr=[html componentsMatchedByRegex:regexString];
	
	if([testarr count]>0){
		
		NSString *newhtml = [html stringByReplacingOccurrencesOfRegex:regexString withString:EMPTYSTRING];
		
		if(newhtml!=nil){
			return newhtml;
		}else{
			return html;
		}
	}
	return html;
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
    
    return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
}

+(NSString *)Base64Encode:(NSData *)data{
	//Point to start of the data and set buffer sizes
	NSUInteger inLength = [data length];
	NSUInteger outLength = ((((inLength * 4)/3)/4)*4) + (((inLength * 4)/3)%4 ? 4 : 0);
	const char *inputBuffer = [data bytes];
	char *outputBuffer = malloc(outLength);
	outputBuffer[outLength] = 0;
	
	//64 digit code
	static char Encode[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
	
	//start the count
	int cycle = 0;
	int inpos = 0;
	int outpos = 0;
	char temp;
	
	//Pad the last to bytes, the outbuffer must always be a multiple of 4
	outputBuffer[outLength-1] = '=';
	outputBuffer[outLength-2] = '=';
	
	/* http://en.wikipedia.org/wiki/Base64
	 Text content   M           a           n
	 ASCII          77          97          110
	 8 Bit pattern  01001101    01100001    01101110
	 
	 6 Bit pattern  010011  010110  000101  101110
	 Index          19      22      5       46
	 Base64-encoded T       W       F       u
	 */
	
	
	while (inpos < inLength){
		switch (cycle) {
			case 0:
				outputBuffer[outpos++] = Encode[(inputBuffer[inpos]&0xFC)>>2];
				cycle = 1;
				break;
			case 1:
				temp = (inputBuffer[inpos++]&0x03)<<4;
				outputBuffer[outpos] = Encode[temp];
				cycle = 2;
				break;
			case 2:
				outputBuffer[outpos++] = Encode[temp|(inputBuffer[inpos]&0xF0)>> 4];
				temp = (inputBuffer[inpos++]&0x0F)<<2;
				outputBuffer[outpos] = Encode[temp];
				cycle = 3;                  
				break;
			case 3:
				outputBuffer[outpos++] = Encode[temp|(inputBuffer[inpos]&0xC0)>>6];
				cycle = 4;
				break;
			case 4:
				outputBuffer[outpos++] = Encode[inputBuffer[inpos++]&0x3f];
				cycle = 0;
				break;                          
			default:
				cycle = 0;
				break;
		}
	}
	NSString *pictemp = [NSString stringWithUTF8String:outputBuffer];
	free(outputBuffer); 
	return pictemp;
	
}

/*
+(NSString *) HTTPbase64Encode: (NSString *) stringToBase64Encode{

CFHTTPMessageRef dummyRequest = CFHTTPMessageCreateEmpty(kCFAllocatorDefault,YES);

CFHTTPMessageAddAuthentication(dummyRequest,nil,(CFStringRef)@"12",(CFStringRef)stringToBase64Encode,kCFHTTPAuthenticationSchemeBasic,FALSE);

NSString *base64String =[(NSString *)CFHTTPMessageCopyHeaderFieldValue(dummyRequest,CFSTR("Authorization")) substringFromIndex:4];
	
CFRelease(dummyRequest);

return base64String;

}
*/


+(NSString *) urlencode: (NSString *) unencodedString
{
    NSString * encodedString = (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(
																				   NULL,
																				   (__bridge CFStringRef)unencodedString,
																				   NULL,
																				   (CFStringRef)@"!*'();:@&=+$,/?%#[]",
																				   kCFStringEncodingUTF8 );
	return encodedString;
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
		else if ([scanner scanString:@"&pound;" intoString:NULL])
            [result appendString:@"£"];
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
                [result appendFormat:@"%u", charCode];
				
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

+(NSString*)extractDayStringFromDate:(NSString*)dateString{
	
	NSDate *date=[NSDate dateFromString:dateString withFormat:[NSDate dbFormatString]];
	
	NSString *dayString=nil;
	
	if(date!=nil){
		NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
		[dateFormat setDateFormat:[NSDate dayFormatString]];
		dayString = [dateFormat stringFromDate:date];
	}
	
	return dayString;
}


+(NSString*)urlFromGETURL:(NSString*)url{
	
	NSArray *urlarr=[url componentsSeparatedByString:@"?"];
	NSString *actualurl=nil;
	if([urlarr count]>0){
		actualurl=[urlarr objectAtIndex:0];
	}
	return actualurl;
	
}


//
/***********************************************
 * 
 ***********************************************/
//



// return formatted string, this is convoluted
+(NSString*)createCurrencyStringForValue:(NSString*)strvalue useSystemCurrency:(BOOL)useSystem usingSymbol:(NSString*)symbol useCurrencyScale:(NSInteger)currencyScale useGrouping:(BOOL)useGrouping{
	
	// get current user currency properties
	NSNumberFormatter *currencyFormatter = [[NSNumberFormatter alloc] init];
	[currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	NSString *currencySymbol=nil;
	if(useSystem==YES){
		currencySymbol=[currencyFormatter currencySymbol];
	}else {
		if(symbol!=nil){
			currencySymbol=symbol;
		}
	}
	
	if(currencyScale==-1){
		currencyScale = [currencyFormatter maximumFractionDigits];
	}
	
	// set value & scaling as decimals
	
	NSNumber *value=[[NSNumber alloc] initWithInt:[strvalue intValue]];
	NSDecimalNumber *scale=[[NSDecimalNumber alloc]initWithInt:100];
	NSString *svalue;
	// set up formatter
	NSNumberFormatter *nformatter = [[NSNumberFormatter alloc] init];
	[nformatter setNumberStyle:NSNumberFormatterDecimalStyle];
	[nformatter setUsesGroupingSeparator:useGrouping];
	[nformatter setMinimumFractionDigits:currencyScale];
	[nformatter setMaximumFractionDigits:currencyScale];
	
	// create currency specific scaling
	NSDecimalNumber *newprice=[[NSDecimalNumber alloc]initWithInt:[value intValue]];
	if(currencyScale==2){
		NSDecimalNumber *dividedNumber=[newprice decimalNumberByDividingBy:scale];
		svalue=[nformatter stringFromNumber:dividedNumber];
	}else{
		svalue=[nformatter stringFromNumber:newprice];
	}
	
	// if value is 0 override calculated value
	if(newprice==0){
		if(currencyScale==2){
			svalue=@"0.00";
		}else{
			svalue=@"0";
		}
	}
	
	
	if (symbol==nil) {
		return [NSString stringWithFormat:@"%@",svalue];
	}else {
		return [NSString stringWithFormat:@"%@%@",currencySymbol,svalue];
	}
	
	
}


+(NSString*)scaledCurrencyValue:(double)value{
	
	NSNumberFormatter *formatter=[[NSNumberFormatter alloc]init];
	[formatter setNumberStyle: NSNumberFormatterCurrencyStyle];
	int cscale=[formatter maximumFractionDigits];
	int scaledvalue=value;
	
	if(cscale>0)
		scaledvalue=value*pow(10.0, cscale);
	
	return [NSString stringWithFormat:@"%i",scaledvalue];
	
}


// very basic ID to symbol conversion, not very robust!
+(NSString*)convertCurrencyIdentifierToSymbol:(NSString*)identifier{
	
	NSDictionary *idDict=[NSDictionary dictionaryWithObjectsAndKeys:@"£",@"GBP",@"$",@"USD",@"€",@"EUR",@"¥",@"YEN",@"¥",@"JPY",@"kr",@"SEK",@"kr",@"DKK",nil];
	if ([idDict objectForKey:identifier] != nil){
		return [idDict objectForKey:identifier];
	} else {
		return identifier;
	}
	
	
}

#define CREDITCARDNUMBERLENGTH 16
#define CREDITCARDRANGELENGTH 4
+(NSString*)formattedCreditCardNumber:(NSString*)cardnumber{
	
	
	if([cardnumber length]==CREDITCARDNUMBERLENGTH){
		NSMutableArray *chunkarr=[[NSMutableArray alloc]init];
		for (int i=0; i<4; i++) {
			[chunkarr addObject:[cardnumber substringWithRange:NSMakeRange(i*CREDITCARDRANGELENGTH,CREDITCARDRANGELENGTH)]];
		}
		return [chunkarr componentsJoinedByString:@"-"];
	}
	
	return @"Invalid Card Number format";
	
}


//
/***********************************************
 * @description			converts a day int to the equivalent human readable form
 ***********************************************/
//
+(NSString*)convertDayDurationToDateString:(int)duration{
	
	switch (duration) {
			
		case 1:
			return @"1 day";
		break;
		
		case 7:
			return @"1 week";
		break;
			
		case 28:
		case 29:
		case 30:
		case 31:
			return @"1 month";
		break;
			
		case 365:
		case 366:
			return @"1 year";
		default:
			return @"no known duration";
		break;
	}
	
}

//
/***********************************************
 * @description			converts x1 image filenames to their x2 equivalent
 ***********************************************/
//
+(NSString*)convertImageFilenameToRetina:(NSString*)filename{
	
	if([filename containsString:@"@2x"]==NO){
		
		NSString *convertedstr=[filename stringByReplacingOccurrencesOfString:@".png" withString:@"@2x.png"];
		
		return convertedstr;
		
	}else{
		return filename;
	}
	
}


//
/***********************************************
 * @description			creates a presistent id for an app
 ***********************************************/
//
+(NSString*)createAppUUID{
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *uuid=[defaults objectForKey:UUID_USER_DEFAULTS_KEY];
	
    if (uuid == nil) {
		uuid=[StringUtilities stringWithUUID];
        [defaults setObject:uuid forKey:UUID_USER_DEFAULTS_KEY];
        [defaults synchronize];
		
    }
	
	return uuid;
	
}

+(UIImage*)imageFromString:(NSString*)str{
	
	UIImage* image = [UIImage imageWithData:[NSData  dataWithBase64EncodedString:str]];
	return image;
}

+ (NSString *)convertToKilometres:(NSString *)stringMiles {
	NSInteger miles = [stringMiles integerValue];
	NSInteger kilometres = 50;//clearly stupid value.
	if (miles == 10) {
		kilometres = 16;
	} else if (miles == 12) {
		kilometres = 20;
	} else if (miles == 15) {
		kilometres = 24;
	}
	return [[NSNumber numberWithInteger:kilometres] stringValue];
}

@end
