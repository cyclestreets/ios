//
//  StringUtilities.m
//  RacingUK
//
//  Created by Neil Edwards on 09/12/2009.
//  Copyright 2009 Chroma. All rights reserved.
//

#import "StringUtilities.h"


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
	
	NSString *ordinal;
	
	switch (position % 100)
	{
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
	
	return [NSString stringWithFormat:@"%i%@",position,ordinal];
	
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

@end
