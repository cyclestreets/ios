//
//  BUHorizontalMenuView.h
//  Flotsm
//
//  Created by Neil Edwards on 23/09/2014.
//  Copyright (c) 2014 mohawk. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GenericConstants.h"

@class BUHorizontalMenuView;


@protocol BUHorizontalMenuItem <NSObject>

@optional
-(void)setTouchBlock:(GenericEventBlock)block;
-(void)setDataProvider:(NSDictionary*)data;
-(void)setSelected:(BOOL)selected;

@end


@protocol BUHorizontalMenuDataSource <NSObject>

@required

- (NSInteger) numberOfItemsForMenu:(BUHorizontalMenuView*) menuView;

- (NSDictionary*) horizMenu:(BUHorizontalMenuView*) menuView itemAtIndex:(NSInteger) index;

- (UIView<BUHorizontalMenuItem>*)menuViewItemForIndex:(NSInteger) index;

@optional

- (UIImage*) selectedItemImageForMenu:(BUHorizontalMenuView*) menuView;

- (UIColor*) backgroundColorForMenu:(BUHorizontalMenuView*) menuView;

- (NSString*) pixateStyleIdForMenu:(BUHorizontalMenuView*) menuView;



@end



@protocol BUHorizontalMenuDelegate <NSObject>

@optional

- (void)horizMenu:(BUHorizontalMenuView*) menuView itemSelectedAtIndex:(NSInteger) index;

@end



@interface BUHorizontalMenuView : UIView

@property (nonatomic, assign) IBOutlet id <BUHorizontalMenuDelegate>            menuDelegate;
@property (nonatomic, strong) IBOutlet id <BUHorizontalMenuDataSource>          menuDataSource;

@property (nonatomic, assign) NSInteger                                         itemCount;

@property (nonatomic,assign)  NSInteger                                         selectedIndex;



-(void) reloadData;

-(void) setSelectedIndex:(NSInteger) index animated:(BOOL) animated;


@end
