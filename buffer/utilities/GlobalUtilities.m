//
//  GlobalVariables.m
//  RacingUK
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
	

- (id) init
{
    self = [super init];
    if (self != nil) {
		
		
    }
    return self;
}

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


+(NSURL*)validateURL:(NSString*)urlstring{
	
	NSString *regexString=@"([A-Za-z][A-Za-z0-9+.-]{1,120}:[A-Za-z0-9/](([A-Za-z0-9$_.+!*,;/?:@&~=-])|%[A-Fa-f0-9]{2}){1,333}(#([a-zA-Z0-9][a-zA-Z0-9$_.+!*,;/?:@&~=%-]{0,1000}))?)";
	
	//NSString *regexString = @"((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+";
	BOOL validated = [urlstring isMatchedByRegex:regexString];
	
	//NSLog(@"[ERROR] Invalid URL: GlobalUtilities.validateURL returned: %i",validated);
	
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


+ (UIButton*)shinyButtonWithWidth:(NSUInteger)width height:(NSUInteger)height color:(UIColor*)color
{
	UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
	button.frame = CGRectMake(0, 0, width, height);
	
	// Configure background image(s)
	[UIButton setBackgroundToGlossyButton:button forColor:color withBorder:YES forState:UIControlStateNormal];
	[UIButton setBackgroundToGlossyButton:button forColor:[UIColor grayColor] withBorder:YES forState:UIControlStateHighlighted];
	
	// Configure title(s)
	[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[button setTitleShadowColor:[UIColor colorWithRed:.25 green:.25 blue:.25 alpha:1] forState:UIControlStateNormal];
	button.titleLabel.font=[UIFont boldSystemFontOfSize:12];
	button.titleLabel.shadowOffset=CGSizeMake(0, -1);
	// Add to TL view, and return
	return button;
}

+ (UIButton*)shinyButtonWithWidth:(NSUInteger)width height:(NSUInteger)height color:(UIColor*)color text:(NSString*)text
{
	UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
	UIFont *font=[UIFont boldSystemFontOfSize:12];
	
	CGFloat twidth=[GlobalUtilities calculateWidthOfText:text :font];
	button.frame = CGRectMake(0, 0, MAX(twidth,width), height);
	
	// Configure background image(s)
	[UIButton setBackgroundToGlossyButton:button forColor:color withBorder:YES forState:UIControlStateNormal];
	[UIButton setBackgroundToGlossyButton:button forColor:[UIColor grayColor] withBorder:YES forState:UIControlStateHighlighted];
	
	// Configure title(s)
	[button setTitle:text forState:UIControlStateNormal];
	button.titleLabel.font=font;
	[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[button setTitleShadowColor:[UIColor colorWithRed:.25 green:.25 blue:.25 alpha:1] forState:UIControlStateNormal];
	button.titleLabel.textAlignment=UITextAlignmentCenter;
	button.titleLabel.shadowOffset=CGSizeMake(0, -1);
	
	
	return button;
}


+(void)styleIBButton:(UIButton*)button type:(NSString*)type text:(NSString*)text{
	
	
	CGFloat twidth=[GlobalUtilities calculateWidthOfText:text :button.titleLabel.font];
	CGRect bframe=button.frame;
	bframe.size.width=MAX(twidth,bframe.size.width);
	button.frame = bframe;
	
	// Configure background image(s)
	[button setBackgroundImage:[[[StyleManager sharedInstance] imageForType:[NSString stringWithFormat:@"UIButton_%@_lo",type]] stretchableImageWithLeftCapWidth:9 topCapHeight:0 ] forState:UIControlStateNormal];
	[button setBackgroundImage:[[[StyleManager sharedInstance] imageForType:[NSString stringWithFormat:@"UIButton_%@_hi",type]] stretchableImageWithLeftCapWidth:9 topCapHeight:0 ] forState:UIControlStateHighlighted];
	[button setBackgroundImage:[[[StyleManager sharedInstance] imageForType:[NSString stringWithFormat:@"UIButton_%@_disabled",type]] stretchableImageWithLeftCapWidth:9 topCapHeight:0 ] forState:UIControlStateDisabled];
	
	
	// Configure title(s)
	[button setTitle:text forState:UIControlStateNormal];
	button.titleLabel.userInteractionEnabled=NO;
	[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[button setTitleShadowColor:[UIColor colorWithRed:.25 green:.25 blue:.25 alpha:1] forState:UIControlStateNormal];
	button.titleLabel.textAlignment=UITextAlignmentCenter;
	button.titleLabel.shadowOffset=CGSizeMake(0, -1);
}

+(void)styleFixedWidthIBButton:(UIButton*)button type:(NSString*)type text:(NSString*)text{
	
	// Configure background image(s)
	[button setBackgroundImage:[[[StyleManager sharedInstance] imageForType:[NSString stringWithFormat:@"UIButton_%@_lo",type]] stretchableImageWithLeftCapWidth:9 topCapHeight:0 ] forState:UIControlStateNormal];
	[button setBackgroundImage:[[[StyleManager sharedInstance] imageForType:[NSString stringWithFormat:@"UIButton_%@_hi",type]] stretchableImageWithLeftCapWidth:9 topCapHeight:0 ] forState:UIControlStateHighlighted];
	[button setBackgroundImage:[[[StyleManager sharedInstance] imageForType:[NSString stringWithFormat:@"UIButton_%@_disabled",type]] stretchableImageWithLeftCapWidth:9 topCapHeight:0 ] forState:UIControlStateDisabled];
	
	
	// Configure title(s)
	[button setTitle:text forState:UIControlStateNormal];
	button.titleLabel.userInteractionEnabled=NO;
	[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[button setTitleShadowColor:[UIColor grayColor] forState:UIControlStateNormal];
	button.titleLabel.textAlignment=UITextAlignmentCenter;
	button.titleLabel.shadowOffset=CGSizeMake(0, -1);
}


+ (UIButton*)UIButtonWithWidth:(NSUInteger)width height:(NSUInteger)height type:(NSString*)type text:(NSString*)text
{
	UIButton* button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	UIFont *font=[UIFont boldSystemFontOfSize:12];
	
	CGFloat twidth=[GlobalUtilities calculateWidthOfText:text :font];
	button.frame = CGRectMake(0, 0, MAX(twidth,width), height);
	
	// Configure background image(s)
	[button setBackgroundImage:[[[StyleManager sharedInstance] imageForType:[NSString stringWithFormat:@"UIButton_%@_lo",type]] stretchableImageWithLeftCapWidth:9 topCapHeight:0 ] forState:UIControlStateNormal];
	[button setBackgroundImage:[[[StyleManager sharedInstance] imageForType:[NSString stringWithFormat:@"UIButton_%@_hi",type]] stretchableImageWithLeftCapWidth:9 topCapHeight:0 ] forState:UIControlStateHighlighted];
	
	
	// Configure title(s)
	[button setTitle:text forState:UIControlStateNormal];
	button.titleLabel.userInteractionEnabled=NO;
	button.titleLabel.font=font;
	[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[button setTitleShadowColor:[UIColor colorWithRed:.25 green:.25 blue:.25 alpha:1] forState:UIControlStateNormal];
	button.titleLabel.textAlignment=UITextAlignmentCenter;
	button.titleLabel.shadowOffset=CGSizeMake(0, -1);
	
	
	return button;
}

// Note: These are autoreleased, do not over release!
+ (UIButton*)UIButtonWithFixedWidth:(NSUInteger)width height:(NSUInteger)height type:(NSString*)type text:(NSString*)text minFont:(int)minFont
{
	UIButton* button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	UIFont *font=[UIFont boldSystemFontOfSize:12];
	
	button.frame = CGRectMake(0, 0, width, height);
	
	// Configure background image(s)
	[button setBackgroundImage:[[[StyleManager sharedInstance] imageForType:[NSString stringWithFormat:@"UIButton_%@_lo",type]] stretchableImageWithLeftCapWidth:9 topCapHeight:0 ] forState:UIControlStateNormal];
	[button setBackgroundImage:[[[StyleManager sharedInstance] imageForType:[NSString stringWithFormat:@"UIButton_%@_hi",type]] stretchableImageWithLeftCapWidth:9 topCapHeight:0 ] forState:UIControlStateHighlighted];
	
	
	// Configure title(s)
	button.titleLabel.adjustsFontSizeToFitWidth=YES;
	[button.titleLabel setMinimumFontSize:minFont];
	[button setTitle:text forState:UIControlStateNormal];
	button.titleLabel.font=font;
	[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[button setTitleShadowColor:[UIColor colorWithRed:.25 green:.25 blue:.25 alpha:1] forState:UIControlStateNormal];
	button.titleLabel.textAlignment=UITextAlignmentCenter;
	button.titleLabel.shadowOffset=CGSizeMake(0, -1);
	
	
	return button;
}


+ (UIButton*)UIImageButtonWithWidth:(NSString*)image height:(NSUInteger)height type:(NSString*)type text:(NSString*)text
{
	UIButton* button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	button.titleEdgeInsets=UIEdgeInsetsMake(0, 10, 0, 5);
	UIFont *font=[UIFont boldSystemFontOfSize:12];
	CGFloat twidth=[GlobalUtilities calculateWidthOfText:text :font];
	//
	UIImage *iconimage=[[StyleManager sharedInstance] imageForType:image];
	[button setImage:iconimage forState:UIControlStateNormal];
	twidth+=iconimage.size.width+20;
	//
	button.frame = CGRectMake(0, 0, MAX(twidth,10), height);
	//
	// Configure background image(s)
	[button setBackgroundImage:[[[StyleManager sharedInstance] imageForType:[NSString stringWithFormat:@"UIButton_%@_lo",type]] stretchableImageWithLeftCapWidth:9 topCapHeight:0 ] forState:UIControlStateNormal];
	[button setBackgroundImage:[[[StyleManager sharedInstance] imageForType:[NSString stringWithFormat:@"UIButton_%@_hi",type]] stretchableImageWithLeftCapWidth:9 topCapHeight:0 ] forState:UIControlStateHighlighted];
	
	
	// Configure title(s)
	[button setTitle:text forState:UIControlStateNormal];
	button.titleLabel.userInteractionEnabled=NO;
	button.titleLabel.font=font;
	[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[button setTitleShadowColor:[UIColor colorWithRed:.25 green:.25 blue:.25 alpha:1] forState:UIControlStateNormal];
	button.titleLabel.textAlignment=UITextAlignmentCenter;
	button.titleLabel.shadowOffset=CGSizeMake(0, -1);
	
	
	return button;
}

+ (UIButton*)UIToggleButtonWithWidth:(NSUInteger)width height:(NSUInteger)height states:(NSDictionary*)stateDict
{
	UIButton* button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	UIFont *font=[UIFont boldSystemFontOfSize:12];
	
	CGFloat twidth=[GlobalUtilities calculateWidthOfText:[[stateDict objectForKey:@"normal"] objectForKey:@"text"] :font];
	twidth+=10;
	button.frame = CGRectMake(0, 0, MAX(twidth,width), height);
	
	// Configure background image(s)
	[button setBackgroundImage:[[[StyleManager sharedInstance] imageForType:[NSString stringWithFormat:@"UIButton_%@_lo",[[stateDict objectForKey:@"normal"] objectForKey:@"type"]]] stretchableImageWithLeftCapWidth:9 topCapHeight:0 ] forState:UIControlStateNormal];
	[button setBackgroundImage:[[[StyleManager sharedInstance] imageForType:[NSString stringWithFormat:@"UIButton_%@_hi",[[stateDict objectForKey:@"highlight"] objectForKey:@"type"]]] stretchableImageWithLeftCapWidth:9 topCapHeight:0 ] forState:UIControlStateHighlighted];
	[button setBackgroundImage:[[[StyleManager sharedInstance] imageForType:[NSString stringWithFormat:@"UIButton_%@_selected",[[stateDict objectForKey:@"selected"] objectForKey:@"type"]]] stretchableImageWithLeftCapWidth:9 topCapHeight:0 ] forState:UIControlStateSelected];
	[button setBackgroundImage:[[[StyleManager sharedInstance] imageForType:[NSString stringWithFormat:@"UIButton_%@_disabled",@"grey"]] stretchableImageWithLeftCapWidth:9 topCapHeight:0 ] forState:UIControlStateDisabled];
	
	
	// Configure title(s)
	[button setTitle:[[stateDict objectForKey:@"normal"] objectForKey:@"text"] forState:UIControlStateNormal];
	[button setTitle:[[stateDict objectForKey:@"highlight"] objectForKey:@"text"] forState:UIControlStateHighlighted];
	[button setTitle:[[stateDict objectForKey:@"selected"] objectForKey:@"text"] forState:UIControlStateSelected];
	[button setTitle:[[stateDict objectForKey:@"normal"] objectForKey:@"text"] forState:UIControlStateDisabled];
	
	button.titleLabel.userInteractionEnabled=NO;
	button.titleLabel.font=font;
	[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	button.titleLabel.textAlignment=UITextAlignmentCenter;
	button.titleLabel.shadowOffset=CGSizeMake(0, 1);
	
	
	return button;
}

+ (void)UIToggleIBButton:(UIButton*)button states:(NSDictionary*)stateDict
{
	
	CGFloat twidth=[GlobalUtilities calculateWidthOfText:[[stateDict objectForKey:@"normal"] objectForKey:@"text"] :button.titleLabel.font];
	CGRect bframe=button.frame;
	bframe.size=CGSizeMake(MAX(twidth,bframe.size.width), bframe.size.height);
	button.frame=bframe;
	
	//button.titleEdgeInsets=UIEdgeInsetsMake(0, 5, 0, 5);
	
	// Configure background image(s)
	[button setBackgroundImage:[[[StyleManager sharedInstance] imageForType:[NSString stringWithFormat:@"UIButton_%@_lo",[[stateDict objectForKey:@"normal"] objectForKey:@"type"]]] stretchableImageWithLeftCapWidth:9 topCapHeight:0 ] forState:UIControlStateNormal];
	[button setBackgroundImage:[[[StyleManager sharedInstance] imageForType:[NSString stringWithFormat:@"UIButton_%@_hi",[[stateDict objectForKey:@"highlight"] objectForKey:@"type"]]] stretchableImageWithLeftCapWidth:9 topCapHeight:0 ] forState:UIControlStateHighlighted];
	[button setBackgroundImage:[[[StyleManager sharedInstance] imageForType:[NSString stringWithFormat:@"UIButton_%@_selected",[[stateDict objectForKey:@"selected"] objectForKey:@"type"]]] stretchableImageWithLeftCapWidth:9 topCapHeight:0 ] forState:UIControlStateSelected];
	[button setBackgroundImage:[[[StyleManager sharedInstance] imageForType:[NSString stringWithFormat:@"UIButton_%@_disabled",@"grey"]] stretchableImageWithLeftCapWidth:9 topCapHeight:0 ] forState:UIControlStateDisabled];
	
	
	// Configure title(s)
	[button setTitle:[[stateDict objectForKey:@"normal"] objectForKey:@"text"] forState:UIControlStateNormal];
	[button setTitle:[[stateDict objectForKey:@"highlight"] objectForKey:@"text"] forState:UIControlStateHighlighted];
	[button setTitle:[[stateDict objectForKey:@"selected"] objectForKey:@"text"] forState:UIControlStateSelected];
	[button setTitle:[[stateDict objectForKey:@"normal"] objectForKey:@"text"] forState:UIControlStateDisabled];
	
	button.titleLabel.userInteractionEnabled=NO;
	[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	button.titleLabel.textAlignment=UITextAlignmentCenter;
	button.titleLabel.shadowOffset=CGSizeMake(0, 1);
	
	
}

+ (void)styleIBIconButton:(UIButton*)button iconimage:(NSString*)image type:(NSString*)type text:(NSString*)text align:(LayoutBoxAlignMode)alignment
{
	
	CGFloat twidth=[GlobalUtilities calculateWidthOfText:text :button.titleLabel.font];
	//
	UIImage *iconimage=[[StyleManager sharedInstance] imageForType:image];
	[button setImage:iconimage forState:UIControlStateNormal];
	
	if(alignment==BURightAlignMode){
		[button setTitleEdgeInsets:UIEdgeInsetsMake(0, -(iconimage.size.width+15), 0, 5)];
		[button setImageEdgeInsets:UIEdgeInsetsMake(0, twidth+15, 0, 5)];
	}else{
		button.titleEdgeInsets=UIEdgeInsetsMake(0, 10, 0, 5);
	}
	
	twidth+=iconimage.size.width+5;
	//
	CGRect bframe=button.frame;
	bframe.size=CGSizeMake(MAX(twidth,bframe.size.width), bframe.size.height);
	button.frame=bframe;
	//
	// Configure background image(s)
	[button setBackgroundImage:[[[StyleManager sharedInstance] imageForType:[NSString stringWithFormat:@"UIButton_%@_lo",type]] stretchableImageWithLeftCapWidth:9 topCapHeight:0 ] forState:UIControlStateNormal];
	[button setBackgroundImage:[[[StyleManager sharedInstance] imageForType:[NSString stringWithFormat:@"UIButton_%@_hi",type]] stretchableImageWithLeftCapWidth:9 topCapHeight:0 ] forState:UIControlStateHighlighted];
	
	
	// Configure title(s)
	[button setTitle:text forState:UIControlStateNormal];
	button.titleLabel.userInteractionEnabled=NO;
	[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[button setTitleShadowColor:[UIColor colorWithRed:.25 green:.25 blue:.25 alpha:1] forState:UIControlStateNormal];
	button.titleLabel.textAlignment=UITextAlignmentLeft;
	button.titleLabel.shadowOffset=CGSizeMake(0, -1);
}



//Constants
#define SECOND 1
#define MINUTE (60 * SECOND)
#define HOUR (60 * MINUTE)
#define DAY (24 * HOUR)
#define MONTH (30 * DAY)

+ (NSString*)timeIntervalWithStartDate:(NSDate*)d1 withEndDate:(NSDate*)d2
{
    //Calculate the delta in seconds between the two dates
    NSTimeInterval delta = [d2 timeIntervalSinceDate:d1];
	
    if (delta < 1 * MINUTE)
    {
        return delta == 1 ? @"one second ago" : [NSString stringWithFormat:@"%d seconds ago", (int)delta];
    }
    if (delta < 2 * MINUTE)
    {
        return @"a minute ago";
    }
    if (delta < 45 * MINUTE)
    {
        int minutes = floor((double)delta/MINUTE);
        return [NSString stringWithFormat:@"%d minutes ago", minutes];
    }
    if (delta < 90 * MINUTE)
    {
        return @"an hour ago";
    }
    if (delta < 24 * HOUR)
    {
        int hours = floor((double)delta/HOUR);
        return [NSString stringWithFormat:@"%d hours ago", hours];
    }
    if (delta < 48 * HOUR)
    {
        return @"Yesterday";
    }
    if (delta < 30 * DAY)
    {
        int days = floor((double)delta/DAY);
        return [NSString stringWithFormat:@"%d days ago", days];
    }
    if (delta < 12 * MONTH)
    {
        int months = floor((double)delta/MONTH);
        return months <= 1 ? @"one month ago" : [NSString stringWithFormat:@"%d months ago", months];
    }
    else
    {
        int years = floor((double)delta/MONTH/12.0);
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
	
	//NSSortDescriptor *nameSortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(compare:)] autorelease];
	//	[dataProvider sortUsingDescriptors:[NSMutableArray arrayWithObjects:nameSortDescriptor, nil]];
	
	NSMutableDictionary *alphaDataProvider=[[NSMutableDictionary alloc]init];
	NSString *activekey=@"";
	NSString *itemkey;
	NSMutableArray *keyArray=[[NSMutableArray alloc]init];
	BOOL firstvalue=YES;
	
	for( NSString *item	in dataProvider){
		
		//NSString *itemname=[[NSString alloc] initWithString:item.name];
		itemkey = [ [item valueForKey:key] substringWithRange:NSMakeRange(0,1)];
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
		
		//[newday release];
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
 * @description			COLLECTION UTILITIES
 ***********************************************/
//

+(void)printDictionaryContents:(NSDictionary*)dict{
	
	if(dict!=nil){
		NSLog(@"printDictionaryContents: %@",dict);
		NSLog(@"-----------------------------------");
		for (NSString *key in dict) {
			NSLog(@"%@: %@",key,[dict valueForKey:key]);
		}
		NSLog(@"-----------------------------------");
	}
	
}



- (void) dealloc{
	
    [super dealloc];
}

@end
