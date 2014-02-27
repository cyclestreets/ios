//
//  GlobalVariables.m
//
//
//  Created by Neil Edwards on 08/04/2009.
//  Copyright 2009 buffer. All rights reserved.
//

#import "GlobalUtilities.h"
#import "RegexKitLite.h"
#import "HalfRoundedRectView.h"
#import "RoundedRectView.h"
#import "UIButton+Glossy.h"
#import "NSDate-Misc.h"
#import "StyleManager.h"
#import "AppConstants.h"
#import "StringUtilities.h"
#import "NSDictionary+UrlEncoding.h"

@implementation GlobalUtilities
	



+(float) calculateHeightOfTextFromWidth:(NSString*)text :(UIFont*)withFont :(float)width :(NSLineBreakMode)lineBreakMode
{
	CGSize suggestedSize = [text sizeWithFont:withFont constrainedToSize:CGSizeMake(width, FLT_MAX) lineBreakMode:lineBreakMode];
	
	
	return suggestedSize.height;
}

+(float) calculateHeightOfTextFromWidthWithLineCount:(UIFont*)withFont :(float)width :(NSLineBreakMode)lineBreakMode :(int)linecount
{
	
	NSMutableArray *strarr=[[NSMutableArray alloc]init];
	for( int i=0;i<linecount;i++){
		[strarr addObject:@" "];
	}
	NSString *linestr=[strarr componentsJoinedByString:@"\r"];  
	
	CGSize suggestedSize = [linestr sizeWithFont:withFont constrainedToSize:CGSizeMake(width, FLT_MAX) lineBreakMode:lineBreakMode];
	
	
	return suggestedSize.height;
}


+(float) calculateWidthOfText:(NSString*)text :(UIFont*)withFont
{
	CGSize suggestedSize = [text sizeWithFont:withFont];
	
	
	return suggestedSize.width;
}



+(void)createCornerContainer:(UIView *)viewToUse forWidth:(CGFloat)width forHeight:(CGFloat)height drawHeader:(BOOL)header{
	
	if(header==YES){
		HalfRoundedRectView *halfroundedRect = [[HalfRoundedRectView alloc] initWithFrame:CGRectMake(1.0, 1.0, width-2, 30.0)];
		halfroundedRect.rectColor=UIColorFromRGB(0x9E005D);
		[viewToUse addSubview:halfroundedRect];
		[viewToUse sendSubviewToBack:halfroundedRect];
	}
	
	RoundedRectView *roundedRect = [[RoundedRectView alloc] initWithFrame:CGRectMake(1.0, 1.0, width-2, height-2)];
	roundedRect.rectColor=UIColorFromRGB(0xCBEFF1);
	roundedRect.strokeColor=UIColorFromRGB(0xFFFFFF);	
	roundedRect.strokeWidth=0.0;
	[viewToUse addSubview:roundedRect];
	[viewToUse sendSubviewToBack:roundedRect];
	
	
	RoundedRectView *wroundedRect = [[RoundedRectView alloc] initWithFrame:CGRectMake(0.0, 0.0, width, height)];
	wroundedRect.rectColor=UIColorFromRGB(0xFFFFFF);
	wroundedRect.strokeWidth=0.0;
	[viewToUse addSubview:wroundedRect];
	[viewToUse sendSubviewToBack:wroundedRect];
}





+ (NSString*)timeIntervalWithStartDate:(NSDate*)d1 withEndDate:(NSDate*)d2
{
    //Calculate the delta in seconds between the two dates
    NSTimeInterval delta = [d2 timeIntervalSinceDate:d1];
	
	NSString *stringsuffix;
	BOOL	isFuture=NO;
	
	if(delta<0){
		stringsuffix=@"to go";
		isFuture=YES;
		delta=0-delta;
	}else{
		stringsuffix=@"ago";
	}
		
	
    if (delta < 1 * TIME_MINUTE)
    {
        return delta == 1 ? [NSString stringWithFormat:@"one second %@",stringsuffix] : [NSString stringWithFormat:@"%d seconds %@", (int)delta,stringsuffix];
    }
    if (delta < 2 * TIME_MINUTE)
    {
        return [NSString stringWithFormat:@"a minute %@",stringsuffix];
    }
    if (delta < 45 * TIME_MINUTE)
    {
        int minutes = floor((double)delta/TIME_MINUTE);
        return [NSString stringWithFormat:@"%d minutes %@", minutes,stringsuffix];
    }
    if (delta < 90 * TIME_MINUTE)
    {
        return [NSString stringWithFormat:@"an hour %@",stringsuffix];
    }
    if (delta < 24 * TIME_HOUR)
    {
        int hours = floor((double)delta/TIME_HOUR);
		NSString *valuesuffix=hours>1 ? @"s" : @"";
        return [NSString stringWithFormat:@"%d hour%@ %@", hours,valuesuffix, stringsuffix];
    }
    if (delta < 48 * TIME_HOUR)
    {
        return isFuture==NO ? @"Yesterday": (@"Tomorrow");
    }
    if (delta < 30 * TIME_DAY)
    {
        int days = floor((double)delta/TIME_DAY);
        return [NSString stringWithFormat:@"%d days %@", days,stringsuffix];
    }
    if (delta < 12 * TIME_MONTH)
    {
        int months = floor((double)delta/TIME_MONTH);
        return months <= 1 ? [NSString stringWithFormat:@"one month %@",stringsuffix] : [NSString stringWithFormat:@"%d months %@", months,stringsuffix];
    }
    else
    {
        int years = floor((double)delta/TIME_MONTH/12.0);
        return years <= 1 ? [NSString stringWithFormat:@"one year %@",stringsuffix] : [NSString stringWithFormat:@"%d years %@", years,stringsuffix];
    }
}


+(NSString*)GUIDString {
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
	
	NSString *convertedStr=(__bridge_transfer NSString *)string;
	NSString *str = [NSString stringWithFormat:@"%@",convertedStr];
	
    CFRelease(theUUID);
	
    return str;
}



+(NSMutableDictionary*)newTableViewIndexFromArray:(NSMutableArray*)dataProvider usingKey:(NSString*)key{
	
	NSSortDescriptor *nameSortDescriptor = [[NSSortDescriptor alloc] initWithKey:key ascending:YES selector:@selector(compare:)];
	[dataProvider sortUsingDescriptors:[NSMutableArray arrayWithObjects:nameSortDescriptor, nil]];
	
	NSMutableDictionary *alphaDataProvider=[[NSMutableDictionary alloc]init];
	NSString *activekey=@"";
	NSString *itemkey;
	NSMutableArray *keyArray=[[NSMutableArray alloc]init];
	BOOL firstvalue=YES;
	
	for( id item in dataProvider){
		
		NSString *keyvalue=[item valueForKeyPath:key];
		
		if(![keyvalue isEqualToString:EMPTYSTRING]){
			
			itemkey = [ keyvalue substringWithRange:NSMakeRange(0,1)];
			//
			if(firstvalue==YES){
				activekey=[itemkey copy];
				firstvalue=NO;
			}
			if([activekey isEqualToString:itemkey]){
				[keyArray addObject:item];
			}else{
				NSMutableArray *keycopy=[keyArray mutableCopy];
				[alphaDataProvider setObject:keycopy forKey:activekey];
				activekey=[itemkey copy];
				[keyArray removeAllObjects];
				[keyArray addObject:item];
			}
		}
		
	}
	if([keyArray count]>0){
		NSMutableArray *keycopy=[keyArray mutableCopy];
		[alphaDataProvider setObject:keycopy forKey:activekey];
	}
	//
	
	
	
	return alphaDataProvider;
	
}


+(NSMutableArray*)newTableIndexArrayFromDictionary:(NSMutableDictionary*)dict withSearch:(BOOL)search{

	NSMutableArray *keys=[[NSMutableArray alloc] init];
	[keys addObjectsFromArray:[[dict allKeys] sortedArrayUsingSelector:@selector(compare:)]];
	if(search==YES){
		[keys insertObject:UITableViewIndexSearch  atIndex:0];
	}
	
	return keys;
}

+(NSMutableArray*)newTableIndexArrayFromDictionary:(NSMutableDictionary*)dict withSearch:(BOOL)search ascending:(BOOL)ascending{
	
	NSMutableArray *keys=[[NSMutableArray alloc] init];
	[keys addObjectsFromArray:[dict allKeys]];
	
	[keys sortUsingComparator: 
	 ^(id obj1, id obj2) 
	 {
		 
		 NSComparisonResult result;
		 
		 if(ascending==NO){
			 result = [obj2 compare: obj1];
		 }else {
			 result = [obj1 compare: obj2];
		 }
		 return result;
	 }];
	
	if(search==YES){
		[keys insertObject:UITableViewIndexSearch  atIndex:0];
	}
	
	return keys;
}


+(NSMutableDictionary*)newKeyedDictionaryFromArray:(NSMutableArray*)dataProvider usingKey:(NSString*)key{
	
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:key ascending:YES selector:@selector(compare:)];
	[dataProvider sortUsingDescriptors:[NSMutableArray arrayWithObjects:sortDescriptor, nil]];
	
	NSMutableDictionary *keyedDataProvider=[[NSMutableDictionary alloc]init];
	NSString *activekey=@"";
	NSString *itemkey;
	NSMutableArray *keyArray=[[NSMutableArray alloc]init];
	BOOL firstvalue=YES;
	
	for( id item	in dataProvider){
		
		itemkey = [item valueForKeyPath:key];
		//
		if(firstvalue==YES){
			activekey=[itemkey copy];
			firstvalue=NO;
		}
		if([activekey isEqualToString:itemkey]){
			[keyArray addObject:item];
		}else{
			NSMutableArray *keycopy=[keyArray mutableCopy];
			[keyedDataProvider setObject:keycopy forKey:activekey];
			activekey=[itemkey copy];
			[keyArray removeAllObjects];
			[keyArray addObject:item];
		}
		
		
	}
	if([keyArray count]>0){
		NSMutableArray *keycopy=[keyArray mutableCopy];
		[keyedDataProvider setObject:keycopy forKey:activekey];
	}
	//
	
	
	
	return keyedDataProvider;
	
}

+(NSMutableDictionary*)newKeyedDictionaryFromArray:(NSMutableArray*)dataProvider usingKey:(NSString*)key sortedBy:(NSString*)sortkey{
	
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortkey ascending:NO selector:@selector(compare:)];
	[dataProvider sortUsingDescriptors:[NSMutableArray arrayWithObjects:sortDescriptor, nil]];
	
	NSMutableDictionary *keyedDataProvider=[[NSMutableDictionary alloc]init];
	NSString *activekey=@"";
	NSString *itemkey;
	NSMutableArray *keyArray=[[NSMutableArray alloc]init];
	BOOL firstvalue=YES;
	
	for( id item	in dataProvider){
		
		itemkey = [item valueForKeyPath:key];
		
		if(itemkey==nil){
			itemkey=EMPTYSTRING;
		}
		
		//
		if(firstvalue==YES){
			activekey=[itemkey copy];
			firstvalue=NO;
		}
		if([activekey isEqualToString:itemkey]){
			[keyArray addObject:item];
		}else{
			NSMutableArray *keycopy=[keyArray mutableCopy];
			[keyedDataProvider setObject:keycopy forKey:activekey];
			activekey=[itemkey copy];
			[keyArray removeAllObjects];
			[keyArray addObject:item];
		}
		
		
	}
	if([keyArray count]>0){
		NSMutableArray *keycopy=[keyArray mutableCopy];
		[keyedDataProvider setObject:keycopy forKey:activekey];
	}
	
	return keyedDataProvider;
	
}


+(NSMutableArray*)newDateArray:(NSDate*)start length:(int)length future:(BOOL)future{
	
	NSMutableArray *arr=[[NSMutableArray alloc]init];
	start = [start midnightUTC];
	for(int i=0;i<length;i++){
		NSDate *newday;
		
		if (future==YES) {
			newday=[start dateByAddingDays:i];
			[arr addObject:newday];
		}else {
			newday=[start dateByAddingDays:0-i];
			[arr insertObject:newday atIndex:0];
		}
		
	}
		
	return arr;
	
}


+(NSMutableURLRequest*)createURLRequestForType:(NSString*)type with:(NSDictionary*)parameters toURL:(NSString*)url{
	
	NSURL *requesturl;
	NSMutableURLRequest *request=nil;
	
	
	if ([type isEqualToString:URL]) {
		
		NSString *urlString=[StringUtilities urlFromParameterArray:[parameters objectForKey:@"parameterarray"] url:[NSMutableString stringWithString:url]];
		requesturl=[NSURL URLWithString:urlString];
		
		request = [NSMutableURLRequest requestWithURL:requesturl
										  cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
									  timeoutInterval:30.0 ];
		
		BetterLog(@"url type url: %@",urlString);
		
	}else if([type isEqualToString:POST]){
		
		requesturl=[NSURL URLWithString:url];
		
		request = [NSMutableURLRequest requestWithURL:requesturl
										  cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
									  timeoutInterval:30.0 ];
		
		NSString *parameterString=[parameters urlEncodedString];
		NSString *msgLength = [NSString stringWithFormat:@"%d", [parameterString length]];
		[request addValue: msgLength forHTTPHeaderField:@"Content-Length"];
		[request setHTTPMethod:@"POST"];
		
		NSData		*httpbody=[parameterString dataUsingEncoding:NSUTF8StringEncoding];
		
		BetterLog(@" httpbody %@",httpbody);
		
		[request setHTTPBody: httpbody];
		
		
		BetterLog(@"service %@",url);
		
		
		
	}else if ([type isEqualToString:GET]) {
		
		NSString *urlString=[[NSString alloc]initWithFormat:@"%@?%@",url,[parameters urlEncodedString]];
		
		requesturl=[NSURL URLWithString:urlString];
		
		request = [NSMutableURLRequest requestWithURL:requesturl
										  cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
									  timeoutInterval:30.0 ];
	}
	
	
	
	return request;
	
}



+(NSString*)convertBooleanToType:(NSString*)type :(BOOL)boo{
	
	if ([type isEqualToString:@"boolean"]){
		
		if (boo==YES) {
			return @"true";
		}else {
			return @"false";
		}
	}else if([type isEqualToString:@"string"]){
		if (boo==YES) {
			return @"yes";
		}else {
			return @"no";
		}
	}else if([type isEqualToString:@"int"]){
		if (boo==YES) {
			return @"1";
		}else {
			return @"0";
		}
	}else if([type isEqualToString:@"single"]){
		if (boo==YES) {
			return @"Y";
		}else {
			return @"N";
		}
	}
	return nil;
}


//
/***********************************************
 * @description			Enumerates a form dict for failed validation results. Form dict must have BOOL valid key
 ***********************************************/
//
+(BOOL)validationResultForFormDict:(NSDictionary*)dict{
	
	BOOL isClearOfErrors=YES;
	for (NSString *key in dict) {
		NSDictionary *formdict=[dict objectForKey:key];
		isClearOfErrors=[[formdict objectForKey:@"valid"] boolValue];
		if(isClearOfErrors==NO)
			return isClearOfErrors;
	}
	return isClearOfErrors;
}




+(id)sectionDataProviderFromIndexPath:(NSIndexPath*)indexpath 
dataProvider:(NSDictionary*)dataProvider withKeys:(NSArray*)keys{
    
    NSString *key=[keys objectAtIndex:[indexpath section]];
	NSMutableArray *dp=[dataProvider objectForKey:key];
    return [dp objectAtIndex:[indexpath row]];
    
}



+(void)trimArray:(NSMutableArray*)arr FromIndex:(int)index{
	
	NSMutableIndexSet *indexes = [NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(index, [arr count]-index)];
	[arr removeObjectsAtIndexes:indexes];
	
}

+(int)inflateArrayCountForArray:(NSMutableArray*)arr{
    
    int value=0;
    
    for (NSMutableArray *subarr in arr){
        value+=[subarr count]; 
    }
    return value;
}

+ (void)dismissKeyboard:(UIView*)view { 
	UITextField *tempTextField = [[UITextField alloc] initWithFrame:CGRectZero];
	
	[view  addSubview:tempTextField];
	
	tempTextField.keyboardType=UIKeyboardTypeNumberPad;
	[tempTextField becomeFirstResponder];
	[tempTextField resignFirstResponder];
	[tempTextField removeFromSuperview];
}


+ (float)randomFloatBetween:(float)smallNumber and:(float)bigNumber {
	float diff = bigNumber - smallNumber;
	return (((float) (arc4random() % ((unsigned)RAND_MAX + 1)) / RAND_MAX) * diff) + smallNumber;
}


@end
