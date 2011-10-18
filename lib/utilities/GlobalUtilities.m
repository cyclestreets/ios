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
	



+(float) calculateHeightOfTextFromWidth:(NSString*) text: (UIFont*)withFont: (float)width :(UILineBreakMode)lineBreakMode
{
	[text retain];
	[withFont retain];
	CGSize suggestedSize = [text sizeWithFont:withFont constrainedToSize:CGSizeMake(width, FLT_MAX) lineBreakMode:lineBreakMode];
	
	[text release];
	[withFont release];
	
	return suggestedSize.height;
}

+(float) calculateHeightOfTextFromWidthWithLineCount:(UIFont*)withFont: (float)width :(UILineBreakMode)lineBreakMode :(int)linecount
{
	[withFont retain];
	
	NSMutableArray *strarr=[[NSMutableArray alloc]init];
	for( int i=0;i<linecount;i++){
		[strarr addObject:@" "];
	}
	NSString *linestr=[strarr componentsJoinedByString:@"\r"];  
	[strarr release];
	
	CGSize suggestedSize = [linestr sizeWithFont:withFont constrainedToSize:CGSizeMake(width, FLT_MAX) lineBreakMode:lineBreakMode];
	
	[withFont release];
	
	return suggestedSize.height;
}


+(float) calculateWidthOfText:(NSString*)text :(UIFont*)withFont
{
	[text retain];
	[withFont retain];
	CGSize suggestedSize = [text sizeWithFont:withFont];
	
	[text release];
	[withFont release];
	
	return suggestedSize.width;
}



+(void)createCornerContainer:(UIView *)viewToUse forWidth:(CGFloat)width forHeight:(CGFloat)height drawHeader:(BOOL)header{
	
	if(header==YES){
		HalfRoundedRectView *halfroundedRect = [[HalfRoundedRectView alloc] initWithFrame:CGRectMake(1.0, 1.0, width-2, 30.0)];
		halfroundedRect.rectColor=UIColorFromRGB(0x9E005D);
		[viewToUse addSubview:halfroundedRect];
		[viewToUse sendSubviewToBack:halfroundedRect];
		[halfroundedRect release];
	}
	
	RoundedRectView *roundedRect = [[RoundedRectView alloc] initWithFrame:CGRectMake(1.0, 1.0, width-2, height-2)];
	roundedRect.rectColor=UIColorFromRGB(0xCBEFF1);
	roundedRect.strokeColor=UIColorFromRGB(0xFFFFFF);	
	roundedRect.strokeWidth=0.0;
	[viewToUse addSubview:roundedRect];
	[viewToUse sendSubviewToBack:roundedRect];
	[roundedRect release];
	
	
	RoundedRectView *wroundedRect = [[RoundedRectView alloc] initWithFrame:CGRectMake(0.0, 0.0, width, height)];
	wroundedRect.rectColor=UIColorFromRGB(0xFFFFFF);
	wroundedRect.strokeWidth=0.0;
	[viewToUse addSubview:wroundedRect];
	[viewToUse sendSubviewToBack:wroundedRect];
	[wroundedRect release];
}





+ (NSString*)timeIntervalWithStartDate:(NSDate*)d1 withEndDate:(NSDate*)d2
{
    //Calculate the delta in seconds between the two dates
    NSTimeInterval delta = [d2 timeIntervalSinceDate:d1];
	
	if(delta<0){
		return @"Date is in future!";
	}
	
    if (delta < 1 * TIME_MINUTE)
    {
        return delta == 1 ? @"one second ago" : [NSString stringWithFormat:@"%d seconds ago", (int)delta];
    }
    if (delta < 2 * TIME_MINUTE)
    {
        return @"a minute ago";
    }
    if (delta < 45 * TIME_MINUTE)
    {
        int minutes = floor((double)delta/TIME_MINUTE);
        return [NSString stringWithFormat:@"%d minutes ago", minutes];
    }
    if (delta < 90 * TIME_MINUTE)
    {
        return @"an hour ago";
    }
    if (delta < 24 * TIME_HOUR)
    {
        int hours = floor((double)delta/TIME_HOUR);
        return [NSString stringWithFormat:@"%d hours ago", hours];
    }
    if (delta < 48 * TIME_HOUR)
    {
        return @"Yesterday";
    }
    if (delta < 30 * TIME_DAY)
    {
        int days = floor((double)delta/TIME_DAY);
        return [NSString stringWithFormat:@"%d days ago", days];
    }
    if (delta < 12 * TIME_MONTH)
    {
        int months = floor((double)delta/TIME_MONTH);
        return months <= 1 ? @"one month ago" : [NSString stringWithFormat:@"%d months ago", months];
    }
    else
    {
        int years = floor((double)delta/TIME_MONTH/12.0);
        return years <= 1 ? @"one year ago" : [NSString stringWithFormat:@"%d years ago", years];
    }
}


+(NSString*)GUIDString {
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    return [(NSString *)string autorelease];
}



+(NSMutableDictionary*)newTableViewIndexFromArray:(NSMutableArray*)dataProvider usingKey:(NSString*)key{
	
	NSSortDescriptor *nameSortDescriptor = [[[NSSortDescriptor alloc] initWithKey:key ascending:YES selector:@selector(compare:)] autorelease];
	[dataProvider sortUsingDescriptors:[NSMutableArray arrayWithObjects:nameSortDescriptor, nil]];
	
	NSMutableDictionary *alphaDataProvider=[[NSMutableDictionary alloc]init];
	NSString *activekey=@"";
	NSString *itemkey;
	NSMutableArray *keyArray=[[NSMutableArray alloc]init];
	BOOL firstvalue=YES;
	
	for( id item in dataProvider){
		
		itemkey = [ [item valueForKeyPath:key] substringWithRange:NSMakeRange(0,1)];
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
			[activekey release];
			activekey=[itemkey copy];
			[keyArray removeAllObjects];
			[keyArray addObject:item];
			[keycopy release];
		}
		
		
	}
	if([keyArray count]>0){
		NSMutableArray *keycopy=[keyArray mutableCopy];
		[alphaDataProvider setObject:keycopy forKey:activekey];
		[keycopy release];
	}
	//
	
	[keyArray release];
	
	[activekey release];
	
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


+(NSMutableDictionary*)newKeyedDictionaryFromArray:(NSMutableArray*)dataProvider usingKey:(NSString*)key{
	
	NSSortDescriptor *sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:key ascending:YES selector:@selector(compare:)] autorelease];
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
			[activekey release];
			activekey=[itemkey copy];
			[keyArray removeAllObjects];
			[keyArray addObject:item];
			[keycopy release];
		}
		
		
	}
	if([keyArray count]>0){
		NSMutableArray *keycopy=[keyArray mutableCopy];
		[keyedDataProvider setObject:keycopy forKey:activekey];
		[keycopy release];
	}
	//
	
	[keyArray release];
	
	[activekey release];
	
	return keyedDataProvider;
	
}




+(NSMutableArray*)newDateArray:(NSDate*)start length:(int)length future:(BOOL)future{
	
	NSMutableArray *arr=[[NSMutableArray alloc]init];
	
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
		[urlString release];
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



@end
