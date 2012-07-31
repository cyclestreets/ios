//
//  ButtonUtilities.h
//  NagMe
//
//  Created by Neil Edwards on 19/08/2011.
//  Copyright 2011 buffer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GlobalUtilities.h"

enum  {
	UIButtonStyleLight,
	UIButtonStyleDark,
	UIButtonStyleNone
};
typedef int UIButtonStyle;

@interface ButtonUtilities : NSObject{}

// return new button
+ (UIButton*)shinyButtonWithWidth:(NSUInteger)width height:(NSUInteger)height color:(UIColor*)color;
+ (UIButton*)shinyButtonWithWidth:(NSUInteger)width height:(NSUInteger)height color:(UIColor*)color text:(NSString*)text;

+ (UIButton*)UIButtonWithWidth:(NSUInteger)width height:(NSUInteger)height type:(NSString*)type text:(NSString*)text;
+ (UIButton*)UIButtonWithFixedWidth:(NSUInteger)width height:(NSUInteger)height type:(NSString*)type text:(NSString*)text minFont:(int)minFont;
+ (UIButton*)UITextButtonWithWidth:(NSUInteger)width height:(NSUInteger)height textColor:(NSString*)color text:(NSString*)text;

+ (UIButton*)UIToggleButtonWithWidth:(NSUInteger)width height:(NSUInteger)height states:(NSDictionary*)stateDict;

+ (UIButton*)UIImageButtonWithWidth:(NSString*)image height:(NSUInteger)height type:(NSString*)type text:(NSString*)text;
+ (UIButton*)UIIconButton:(NSString*)backgroundimage  iconImage:(NSString*)iconimage height:(NSUInteger)height width:(NSUInteger)width;
+ (UIButton*)UIIconButton:(NSString*)type  iconImage:(NSString*)iconimagename height:(NSUInteger)height width:(NSUInteger)width midLeftCap:(BOOL)midLeft midTopCap:(BOOL)midTop;


+ (UIButton*)UISimpleImageButton:(NSString*)type;

+ (UIButton*)UIIconButton:(NSString*)image height:(NSUInteger)height type:(NSString*)type;

// style existing button
+ (void)UIToggleIBButton:(UIButton*)button states:(NSDictionary*)stateDict;
+(void)styleIBButton:(UIButton*)button type:(NSString*)type text:(NSString*)text;
+(void)styleFixedWidthIBButton:(UIButton*)button type:(NSString*)type text:(NSString*)text;
+ (void)styleIBButton:(UIButton*)button  withWidth:(NSUInteger)width type:(NSString*)type text:(NSString*)text;
+ (void)styleIBIconButton:(UIButton*)button iconimage:(NSString*)image type:(NSString*)type text:(NSString*)text align:(LayoutBoxAlignMode)alignment;
+(void)updateTitleForUIButton:(UIButton*)button withTitle:(NSString*)title;
+ (void)styleIBIconButton:(UIButton*)button iconimage:(NSString*)image type:(NSString*)type;
+(void)styleIBButton:(UIButton*)button type:(NSString*)type text:(NSString*)text useFont:(BOOL)useFont;
+ (void)styleIBButtonWithExistingWidth:(UIButton*)button type:(NSString*)type text:(NSString*)text;

// special RUK bug fix method
+ (void)styleIBIconButtonFixedStyle:(UIButton*)button iconimage:(NSString*)image type:(NSString*)type text:(NSString*)text align:(LayoutBoxAlignMode)alignment;


// new construction methods for v2.0 of this class
+(void)updateUIButton:(UIButton*)button withStyle:(UIButtonStyle)style;
+(void)setButtonImage:(UIButton*)button  forType:(NSString*)type;


//
/***********************************************
 * @description			v2.0 methods: these will superceed all the others
 ***********************************************/
//

+ (void)UIDefinableStyleButton:(UIButton*)button states:(NSDictionary*)stateDict buttonStyle:(UIButtonStyle)buttonStyle;

@end

