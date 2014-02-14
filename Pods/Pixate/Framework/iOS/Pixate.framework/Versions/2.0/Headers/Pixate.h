//
//  Pixate.h
//  Pixate
//
//  Created by Paul Colton on 12/11/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PXStylesheet.h"
#import "PixateConfiguration.h"

#import "UIView+PXStyling.h"
#import "NSDictionary+PXCSSEncoding.h"
#import "UIBarButtonItem+PXStyling.h"
#import "UITabBarItem+PXStyling.h"
#import "UINavigationItem+PXStyling.h"
#import "UIColor+PXColors.h"

/**
 * This is the main entry point into the Pixate Engine
 */
@interface Pixate : NSObject

/**
 * The version number of the Pixate Engine
 */
+ (NSString *)version;

/**
 * The build date of this version of the Pixate Engine
 */
+ (NSDate *)buildDate;

/**
 * The api integer version of the API
 */
+ (int)apiVersion;

/**
 * The email address used for licensing
 */
+ (NSString *)licenseEmail;

/**
 * The user name used for licensing
 */
+ (NSString *)licenseKey;

/**
 * Are we in Appcelerator Titanium mode
 */
+ (BOOL)titaniumMode;

/**
 *  A property used to configure options in the Pixate
 */
+ (PixateConfiguration *)configuration;

/**
 * This property, when set to YES, automatically refreshes
 * styling when the orientation of your device changes. This is
 * set to NO by default.
 */
+ (BOOL)refreshStylesWithOrientationChange;
+ (void)setRefreshStylesWithOrientationChange:(BOOL)value;

/**
 *  Set the license key and license serial number into the Pixate
 *  Engine. This is required before styling can occur.
 *
 *  @param licenseKey The serial number of your license
 *  @param licenseEmail The user of the license, usually an email address
 */
+ (void) licenseKey:(NSString *)licenseKey forUser:(NSString *)licenseEmail;

/**
 *  Return a collection of all styleables that match the specified selector. Note that the selector runs against views
 *  that are in the current view tree only.
 *
 *  @param styleable The root of the tree to search
 *  @param source The selector to use for matching
 */
+ (NSArray *)selectFromStyleable:(id<PXStyleable>)styleable usingSelector:(NSString *)source;

/**
 *  Return a string representation of all active rule sets matching the specified styleable
 *
 *  @param styleable The styleable to match
 */
+ (NSString *)matchingRuleSetsForStyleable:(id<PXStyleable>)styleable;

/**
 *  Return a string representation of all active declarations that apply to the specified styleable. Note that the list
 *  shows the result of merging all matching rule sets, taking specificity and duplications into account.
 *
 *  @param styleable The styleable to match
 */
+ (NSString *)matchingDeclarationsForStyleable:(id<PXStyleable>)styleable;

/**
 *  Allocate and initialize a new stylesheet using the specified source and stylesheet origin
 *
 *  @param source The CSS source for this stylesheet
 *  @param origin The specificity origin for this stylesheet
 */
+ (id)styleSheetFromSource:(NSString *)source withOrigin:(PXStylesheetOrigin)origin;

/**
 *  Allocate and initialize a new styleheet for the specified path and stylesheet origin
 *
 *  @param filePath The string path to the stylesheet file
 *  @param origin The specificity origin for this stylesheet
 */
+ (id)styleSheetFromFilePath:(NSString *)filePath withOrigin:(PXStylesheetOrigin)origin;

/**
 *  A class-level getter returning the current application-level stylesheet. This value may be nil
 */
+ (PXStylesheet *)currentApplicationStylesheet;

/**
 *  A class-level getter returning the current user-level stylesheet. This value may be nil
 */
+ (PXStylesheet *)currentUserStylesheet;

/**
 *  A class-level getter returning the current view-level stylesheet. This value may be nil
 */
+ (PXStylesheet *)currentViewStylesheet;

/**
 *  Calls updateStylesForAllViews. Please call updateStylesForAllViews directly.
 *  @deprecated
 */
+ (void)applyStylesheets;

/**
 * Update styles for all windows and all if their subviews.
 */
+ (void)updateStylesForAllViews;

/**
 *  Update styles for this styleable and all of its descendant styleables
 *
 *  @param styleable The styleable to update
 */
+ (void)updateStyles:(id<PXStyleable>)styleable;

/**
 *  Update styles for this styleable only
 *
 *  @param styleable The styleable to update
 */
+ (void)updateStylesNonRecursively:(id<PXStyleable>)styleable;

/**
 *  Update styles for this styleable and all of its descendant styleables asynchronously
 *
 *  @param styleable The styleable to update
 */
+ (void)updateStylesAsync:(id<PXStyleable>)styleable;

/**
 *  Update styles for this styleable only asynchronously
 *
 *  @param styleable The styleable to update
 */
+ (void)updateStylesNonRecursivelyAsync:(id<PXStyleable>)styleable;

/**
 *  Remove all content from Pixate's image cache, if one is being used
 */
+ (void)clearImageCache;

/**
 *  Remove all content from Pixate's style cache, if one is being used
 */
+ (void)clearStyleCache;

@end
