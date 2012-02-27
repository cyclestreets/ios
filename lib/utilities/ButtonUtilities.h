//
//  ButtonUtilities.h
// CycleStreets
//
//  Created by Neil Edwards on 19/08/2011.
//  Copyright 2011 buffer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GlobalUtilities.h"

@interface ButtonUtilities : NSObject{}

+ (UIButton*)shinyButtonWithWidth:(NSUInteger)width height:(NSUInteger)height color:(UIColor*)color;
+ (UIButton*)shinyButtonWithWidth:(NSUInteger)width height:(NSUInteger)height color:(UIColor*)color text:(NSString*)text;
+ (UIButton*)UIButtonWithWidth:(NSUInteger)width height:(NSUInteger)height type:(NSString*)type text:(NSString*)text;
+ (UIButton*)UIButtonWithFixedWidth:(NSUInteger)width height:(NSUInteger)height type:(NSString*)type text:(NSString*)text minFont:(int)minFont;
+ (UIButton*)UIImageButtonWithWidth:(NSString*)image height:(NSUInteger)height type:(NSString*)type text:(NSString*)text;
+ (UIButton*)UIToggleButtonWithWidth:(NSUInteger)width height:(NSUInteger)height states:(NSDictionary*)stateDict;
+ (UIButton*)UIIconButton:(NSString*)image height:(NSUInteger)height type:(NSString*)type;
+ (void)UIToggleIBButton:(UIButton*)button states:(NSDictionary*)stateDict;
+(void)styleIBButton:(UIButton*)button type:(NSString*)type text:(NSString*)text;
+(void)styleFixedWidthIBButton:(UIButton*)button type:(NSString*)type text:(NSString*)text;
+ (void)styleIBButton:(UIButton*)button  withWidth:(NSUInteger)width type:(NSString*)type text:(NSString*)text;
+ (void)styleIBIconButton:(UIButton*)button iconimage:(NSString*)image type:(NSString*)type text:(NSString*)text align:(LayoutBoxAlignMode)alignment;
+(void)updateTitleForUIButton:(UIButton*)button withTitle:(NSString*)title;
+ (void)styleIBIconButton:(UIButton*)button iconimage:(NSString*)image type:(NSString*)type;
+ (UIButton*)UITextButtonWithWidth:(NSUInteger)width height:(NSUInteger)height textColor:(NSString*)color text:(NSString*)text;
+ (UIButton*)UISimpleImageButton:(NSString*)type;
+(void)styleIBButton:(UIButton*)button type:(NSString*)type text:(NSString*)text useFont:(BOOL)useFont;

@end
