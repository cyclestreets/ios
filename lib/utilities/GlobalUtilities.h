//
//  GlobalUtilities.h
//  Racing UK
//
//  Created by Neil Edwards on 08/04/2009.
//  Copyright 2009 buffer. All rights reserved.
//
// stores all global methods and constants

#import <Foundation/Foundation.h>
#import "TestFlight.h"
#import "AppConstants.h"



// returns RGB form web hex
#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

// as above but with alpha
#define UIColorFromRGBAndAlpha(rgbValue,alphaValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:alphaValue]


// release groups
#define RELEASE_SAFELY(__POINTER) { [__POINTER release]; __POINTER = nil; }
#define RELEASE_TIMER(__TIMER) { [__TIMER invalidate]; __TIMER = nil; }


#define LineFeed @"\n"


// rotation
#define RADIANS(degrees) ((degrees * M_PI) / 180.0)
#define DEGREES(radians) ((radians) * 180.0 / M_PI)


// Configurable Log
#if ENABLEDEBUGTRACE
#define BetterLog(str, args...)\
NSLog(@"\n-------------\n%s:%d\n%s\n\n[%@]\n-------------\n",\
strrchr(__FILE__, '/'), __LINE__, __PRETTY_FUNCTION__,\
[NSString stringWithFormat:str , ## args ] )
#else
#define BetterLog(str, args...)
#endif

// TestFlight Tracking
#if ENABLEDTESTFLIGHTTRACKING
#define TestFlightLog(str,args...)NSLog(@"\n----TestFlight----\n%s:%d\n%s\n[%@]\n----Checkpoint----\n",\
strrchr(__FILE__, '/'), __LINE__, __PRETTY_FUNCTION__,[NSString stringWithFormat:str , ## args ])
#else
#define TestFlightLog(str,args...)
#endif


// CGRECT Log
#define LogRect(RECT) NSLog(@"(%0.0f, %0.0f) %0.0f x %0.0f", RECT.origin.x, RECT.origin.y, RECT.size.width, RECT.size.height)



/// iPAD
#if UI_USER_INTERFACE_IDIOM==UIUserInterfaceIdiomPad
	#define DEVICESCREEN_WIDTH  1024.0
	#define DEVICESCREEN_HEIGHT  768.0
#else
	#define DEVICESCREEN_WIDTH  320.0
	#define DEVICESCREEN_HEIGHT  480.0
#endif



// Time
#define TIME_MINUTE 60
#define TIME_HOUR (60*TIME_MINUTE)
#define TIME_DAY (24*TIME_HOUR)
#define TIME_WEEK (7*TIME_DAY)
#define TIME_MONTH (30.5*TIME_DAY)
#define TIME_YEAR (365*TIME_DAY)


// SELECTORS
#define SEL(x) @selector(x)

// STRINGS
#define IS_EMPTY_STRING(str) (!(str) || ![(str) isKindOfClass:NSString.class] || [(str) length] == 0)
#define IS_POPULATED_STRING(str) ((str) && [(str) isKindOfClass:NSString.class] && [(str) length] > 0)

// SCreen orientation
#define IS_DEVICE_ORIENTATION_PORTRAIT ([UIDevice currentDevice].orientation == UIDeviceOrientationPortrait)
#define IS_DEVICE_ORIENTATION_LANDSCAPE ([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeLeft || [UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeRight)
#define IS_DEVICE_ORIENTATION_LANDSCAPE_LEFT ([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeLeft)
#define IS_DEVICE_ORIENTATION_LANDSCAPE_RIGHT ([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeRight)
#define IS_DEVICE_ORIENTATION_PORTRAIT_UPSIDE_DOWN ([UIDevice currentDevice].orientation == UIDeviceOrientationPortraitUpsideDown)
#define IS_DEVICE_ORIENTATION_FACE_UP ([UIDevice currentDevice].orientation == UIDeviceOrientationFaceUp)
#define IS_DEVICE_ORIENTATION_FACE_DOWN ([UIDevice currentDevice].orientation == UIDeviceOrientationFaceDown)

#define HARDWARE_SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define HARDWARE_SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)

#define ISRETINADISPLAY (([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) ? [[UIScreen mainScreen] scale] > 1.0 : NO)



// primative>Object wrapping
#define BOX_BOOL(x) [NSNumber numberWithBool:(x)]
#define BOX_INT(x) [NSNumber numberWithInt:(x)]
#define BOX_FLOAT(x) [NSNumber numberWithFloat:(x)]
#define BOX_DOUBLE(x) [NSNumber numberWithDouble:(x)]

#define UNBOX_BOOL(x) [(x) boolValue]
#define UNBOX_INT(x) [(x) intValue]
#define UNBOX_FLOAT(x) [(x) floatValue]
#define UNBOX_DOUBLE(x) [(x) doubleValue]
//


#define DOCUMENTS_DIR ([NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject])



enum  {
	BULeftAlignMode,
	BURightAlignMode,
	BUCenterAlignMode,
	BUTopAlignMode,
	BUBottomAlignMode,
	BUNoneAlignMode
};
typedef int LayoutBoxAlignMode;


enum  {
	BUVerticalLayoutMode=1,
	BUHorizontalLayoutMode=2,
	BUNoneLayoutMode=0
};
typedef int LayoutBoxLayoutMode;


@interface GlobalUtilities : NSObject {
	
	
}

// returns height of text for given width
+(float) calculateHeightOfTextFromWidth:(NSString*) text: (UIFont*)withFont: (float)width :(UILineBreakMode)lineBreakMode;

// returns height of text for given width with fixed line count
+(float) calculateHeightOfTextFromWidthWithLineCount:(UIFont*)withFont: (float)width :(UILineBreakMode)lineBreakMode :(int)linecount;

// returns width of text for single line 
+(float) calculateWidthOfText:(NSString*) text: (UIFont*)withFont;

// creates old style view based corner rectangle with optional header
+(void)createCornerContainer:(UIView *)viewToUse forWidth:(CGFloat)width forHeight:(CGFloat)height drawHeader:(BOOL)header;

//  timeinterval form a to b
+ (NSString*)timeIntervalWithStartDate:(NSDate*)d1 withEndDate:(NSDate*)d2;

// unique guid id
+(NSString*)GUIDString;

// returns tablview index array with optional search icon
+(NSMutableArray*)newTableIndexArrayFromDictionary:(NSMutableDictionary*)dict withSearch:(BOOL)search;

// returns new tableview index for key in each row item dataprovider
+(NSMutableDictionary*)newTableViewIndexFromArray:(NSMutableArray*)dataProvider usingKey:(NSString*)key;
+(NSMutableArray*)newTableIndexArrayFromDictionary:(NSMutableDictionary*)dict withSearch:(BOOL)search ascending:(BOOL)ascending;

// returns new dict for sectioned table views
+(NSMutableDictionary*)newKeyedDictionaryFromArray:(NSMutableArray*)dataProvider usingKey:(NSString*)key;
+(NSMutableDictionary*)newKeyedDictionaryFromArray:(NSMutableArray*)dataProvider usingKey:(NSString*)key sortedBy:(NSString*)sortkey;

// generic create request: DEPRECATED?
+(NSMutableURLRequest*)createURLRequestForType:(NSString*)type with:(NSDictionary*)parameters toURL:(NSString*)url;

// converts boolean to yes/no, true/false  1/0
+(NSString*)convertBooleanToType:(NSString*)type :(BOOL)boo;

//  Form dict support, returns validatity of a set of form items
+(BOOL)validationResultForFormDict:(NSDictionary*)dict;

//returns a date array from a start for a given length in future or past direction
+(NSMutableArray*)newDateArray:(NSDate*)start length:(int)length future:(BOOL)future;


+(id)sectionDataProviderFromIndexPath:(NSIndexPath*)indexpath dataProvider:(NSDictionary*)dataProvider withKeys:(NSArray*)keys;

+(void)trimArray:(NSMutableArray*)arr FromIndex:(int)index;

// return total entries count for nested arra of arrays
+(int)inflateArrayCountForArray:(NSMutableArray*)arr;

+ (void)dismissKeyboard:(UIView*)view;

@end
