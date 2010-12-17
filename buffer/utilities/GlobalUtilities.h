//
//  GlobalUtilities.h
//  Racing UK
//
//  Created by Neil Edwards on 08/04/2009.
//  Copyright 2009 buffer. All rights reserved.
//
// stores all global methods and constants

#import <Foundation/Foundation.h>

#define ENABLEDEBUGTRACE 1

#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define UIColorFromRGBAndAlpha(rgbValue,alphaValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:alphaValue]

///////////////////////////////////////////////////////////////////////////////////////////////////

#define RELEASE_SAFELY(__POINTER) { [__POINTER release]; __POINTER = nil; }
#define AUTORELEASE_SAFELY(__POINTER) { [__POINTER autorelease]; __POINTER = nil; }
#define RELEASE_TIMER(__TIMER) { [__TIMER invalidate]; __TIMER = nil; }

#define LF @"\n"


// detailed log 
#if ENABLEDEBUGTRACE
#define BetterLog(str, args...)\
NSLog(@"\n-------------\n%s:%d\n%s\n\n[%@]\n-------------\n",\
strrchr(__FILE__, '/'), __LINE__, __PRETTY_FUNCTION__,\
[NSString stringWithFormat:str , ## args ] )
#else
#define BetterLog(str, args...)
#endif

#define LogRect(RECT) NSLog(@"%s: (%0.0f, %0.0f) %0.0f x %0.0f",RECT, RECT.origin.x, RECT.origin.y, RECT.size.width, RECT.size.height)


// global notification ids
#define BUNavigationRequestNotification @"BUNavigationRequestNotification" // Why is this here?


///////////////////////////////////////////////////////////////////////////////////////////////////
// Time

#define TIME_MINUTE 60
#define TIME_HOUR (60*TIME_MINUTE)
#define TIME_DAY (24*TIME_HOUR)
#define TIME_WEEK (7*TIME_DAY)
#define TIME_MONTH (30.5*TIME_DAY)
#define TIME_YEAR (365*TIME_DAY)



enum  {
	BULeftAlignMode,
	BURightAlignMode,
	BUCenterAlignMode,
	BUTopAlignMode,
	BUBottomAlignMode
};
typedef int LayoutBoxAlignMode;


enum  {
	BUVerticalLayoutMode,
	BUHorizontalLayoutMode,
	BUNoneLayoutMode=0
};
typedef int LayoutBoxLayoutMode;


@interface GlobalUtilities : NSObject {
	
	
}


+(float) calculateHeightOfTextFromWidth:(NSString*) text: (UIFont*)withFont: (float)width :(UILineBreakMode)lineBreakMode;
+(float) calculateHeightOfTextFromWidthWithLineCount:(UIFont*)withFont: (float)width :(UILineBreakMode)lineBreakMode :(int)linecount;
+(float) calculateWidthOfText:(NSString*) text: (UIFont*)withFont;
+(NSURL*)validateURL:(NSString*)urlstring;
+(void)createCornerContainer:(UIView *)viewToUse forWidth:(CGFloat)width forHeight:(CGFloat)height drawHeader:(BOOL)header;
+ (NSString*)timeIntervalWithStartDate:(NSDate*)d1 withEndDate:(NSDate*)d2;

// UIButton
+ (UIButton*)shinyButtonWithWidth:(NSUInteger)width height:(NSUInteger)height color:(UIColor*)color;
+ (UIButton*)shinyButtonWithWidth:(NSUInteger)width height:(NSUInteger)height color:(UIColor*)color text:(NSString*)text;
+ (UIButton*)UIButtonWithWidth:(NSUInteger)width height:(NSUInteger)height type:(NSString*)type text:(NSString*)text;
+ (UIButton*)UIButtonWithFixedWidth:(NSUInteger)width height:(NSUInteger)height type:(NSString*)type text:(NSString*)text minFont:(int)minFont;
+ (UIButton*)UIImageButtonWithWidth:(NSString*)image height:(NSUInteger)height type:(NSString*)type text:(NSString*)text;
+ (UIButton*)UIToggleButtonWithWidth:(NSUInteger)width height:(NSUInteger)height states:(NSDictionary*)stateDict;
+ (void)UIToggleIBButton:(UIButton*)button states:(NSDictionary*)stateDict;
+(void)styleIBButton:(UIButton*)button type:(NSString*)type text:(NSString*)text;
+(void)styleFixedWidthIBButton:(UIButton*)button type:(NSString*)type text:(NSString*)text;
+ (void)styleIBIconButton:(UIButton*)button iconimage:(NSString*)image type:(NSString*)type text:(NSString*)text align:(LayoutBoxAlignMode)alignment;
+(NSString*)GUIDString;
+(NSMutableArray*)newTableIndexArrayFromDictionary:(NSMutableDictionary*)dict withSearch:(BOOL)search;
+(NSMutableDictionary*)newTableViewIndexFromArray:(NSMutableArray*)dataProvider usingKey:(NSString*)key;
+(BOOL)validateEmail:(NSString*)emailstring;
+(NSMutableURLRequest*)createURLRequestForType:(NSString*)type with:(NSDictionary*)parameters toURL:(NSString*)url;
+(NSString*)convertBooleanToType:(NSString*)type :(BOOL)boo;
+(void)printDictionaryContents:(NSDictionary*)dict;
//
/***********************************************
 * @description			returns a date array from a start for a given length in future or past direction
 ***********************************************/
//
+(NSMutableArray*)newDateArray:(NSDate*)start length:(int)length future:(BOOL)future;
@end
