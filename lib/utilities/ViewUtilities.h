//
//  ViewUtilities.h
//
//
//  Created by Neil Edwards on 03/12/2009.
//  Copyright 2009 Buffer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GlobalUtilities.h"
#import <QuartzCore/QuartzCore.h>

typedef struct
{
	CGFloat left;
	CGFloat right;
	CGFloat top;
	CGFloat bottom;
} BorderParams;

@interface ViewUtilities : NSObject {

}


+(void)alignView:(UIView*)child withView:(UIView*)view :(LayoutBoxAlignMode)horizontal :(LayoutBoxAlignMode)vertical;
+(void)alignView:(UIView*)child withView:(UIView*)view :(LayoutBoxAlignMode)horizontal :(LayoutBoxAlignMode)vertical :(int)inset;
+(void)alignView:(UIView*)child inRect:(CGRect)targetRect :(LayoutBoxAlignMode)horizontal :(LayoutBoxAlignMode)vertical;

+(void)distributeItems:(NSArray*)items inDirection:(LayoutBoxLayoutMode)direction :(int)dimension :(int)inset;
+(void)removeAllSubViewsForView:(UIView*)view;
+ (void)setTransformForCurrentOrientation:(UIView*)view;
+ (id) loadInstanceOfView:(Class)className fromNibNamed:(NSString *)name;
+ (id) loadInstanceOfView:(Class)className fromNibNamed:(NSString *)name forOwner:(id)owner;

+(void)drawViewBorder:(UIView*)view context:(CGContextRef)context borderParams:(BorderParams)params strokeColor:(UIColor*)strokeColor;

// support method for UISupportedInterfaceOrientations string based array
+ (UIInterfaceOrientation)stringtoUIInterfaceOrientation:(NSString*)stringType;

// Returns comparison of passed in orientation against the UISupportedInterfaceOrientations  array
+(BOOL)interfaceOrientationIsSupportedInOrientationStrings:(NSArray*)orientationArray withOrientation:(UIInterfaceOrientation)interfaceOrientation;

+(UIAlertView*)createPasswordPromptView:(id)delegate;

+(void)createPDFfromUIView:(UIView*)aView saveToDocumentsWithFileName:(NSString*)aFilename;

// draws bottom or top outside edge shadow
+(void)drawUIViewEdgeShadow:(UIView*)view;
+(void)drawUIViewEdgeShadow:(UIView*)view atTop:(BOOL)top;
+(void)drawUIViewEdgeShadow:(UIView*)view withHeight:(int)height;

// draws side and top inset shadow
+(void)drawInsertedViewShadow:(UIView*)view;

// draws top and bottom inset shadow
+(void)drawUIViewInsetShadow:(UIView*)view;

+ (CAGradientLayer *)shadowAsInverse:(BOOL)inverse :(UIView*)view;

+(UIView*)findKeyboardViewInApplication;
+(UIWindow*)findKeyboardWindowInApplication;

+(void)removeAllStackViewSubviews:(UIStackView*)stackView;

+(BorderParams)BorderParamsMake:(CGFloat)left :(CGFloat)right :(CGFloat)top :(CGFloat)bottom;

// returns the Tabindex of the current nav controller, useful for apps that share vcs across tabs
+(NSInteger)findTabIndexOfNavigationController:(UINavigationController*)controller;

+(UIAlertView*)createTextEntryAlertView:(NSString*)title fieldText:(NSString*)fieldText delegate:(id)delegate;

+(UIAlertView*)createTextEntryAlertView:(NSString*)title fieldText:(NSString*)fieldText withMessage:(NSString*)message keyboardType:(UIKeyboardType)keyboardType delegate:(id)delegate;

@end
