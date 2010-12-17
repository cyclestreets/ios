//
//  CustomNavigtionBar.h
//  Generic
//
//  Created by Neil Edwards on 04/12/2009.
//  Copyright 2009 Chroma. All rights reserved.
//

#import <UIKit/UIKit.h>

#define	BUNavTitleImageType @"NavImageTitle"
#define	BUNavTitleReadoutType @"NavReadoutType"
#define BUNavTitleIncrementalType @"BUNavTitleIncrementalType"
#define	BUNavBackType @"NavbackType"
#define BUNavBackStandardType @"BUNavBackStandardType"
#define	BUNavRefreshType @"NavrefreshType"
#define	BUNavActivityType @"NavactivityType"
#define	BUNavNoneType @"BUNavNoneType"
#define	BUNavButtonType @"BUNavButtonType"
#define	UIKitButtonType @"UIKitButtonType"
#define	BUItemStepButtonType @"BUItemStepButtonType"
#define	BUNavAddButtonType @"BUNavAddButtonType"

@protocol CustomNavigationBarDelegate <NSObject>

-(void)didRequestPopController;
@optional
-(void)didRequestRefresh;
-(void)doNavigationSelector:(NSString*)type;
-(void)doNavigationItemSelector:(NSString*)type;


@end



@interface CustomNavigtionBar : NSObject {
	
	//ui elements
	UIButton				*backButton;
	UIButton				*refreshButton;
	UILabel					*titleLabel;
	UILabel					*subtitleLabel;
	UIButton				*rightButton;
	UIBarButtonItem			*rightBarButton;
	NSString				*rightButtonTitle;
	UIButton				*nextItemButton;
	UIButton				*prevItemButton;
	UINavigationItem		*navigationItem;
	
	// data provider
	NSMutableDictionary		*dataProvider;
	NSMutableArray			*rightItems;
	
	// text
	NSString				*titleType;
	NSString				*rightItemType;
	NSString				*leftItemType;
	NSString				*titleImage;
	NSString				*leftItemTitle;
	NSString				*titleString;
	
	// delegate
	id<CustomNavigationBarDelegate> delegate;
	
	
}
@property (nonatomic, retain) UIButton *backButton;
@property (nonatomic, retain) UIButton *refreshButton;
@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UILabel *subtitleLabel;
@property (nonatomic, retain) UIButton *rightButton;
@property (nonatomic, retain) UIBarButtonItem *rightBarButton;
@property (nonatomic, retain) NSString *rightButtonTitle;
@property (nonatomic, retain) UIButton *nextItemButton;
@property (nonatomic, retain) UIButton *prevItemButton;
@property (nonatomic, retain) UINavigationItem *navigationItem;
@property (nonatomic, retain) NSMutableDictionary *dataProvider;
@property (nonatomic, retain) NSMutableArray *rightItems;
@property (nonatomic, retain) NSString *titleType;
@property (nonatomic, retain) NSString *rightItemType;
@property (nonatomic, retain) NSString *leftItemType;
@property (nonatomic, retain) NSString *titleImage;
@property (nonatomic, retain) NSString *leftItemTitle;
@property (nonatomic, retain) NSString *titleString;
@property (nonatomic, assign) id<CustomNavigationBarDelegate> delegate;



-(void)createNavigationUI;
-(void)createLeftNavItem;
-(void)createTitle;
-(void)createRightNavItem;
-(void)createRightNavItemWithType:(NSString*)type;
-(IBAction)doBackEvent:(id)sender;
-(IBAction)doRefreshEvent:(id)sender;
-(IBAction)doGenericEvent:(id)sender;
-(IBAction)doNextItemEvent:(id)sender;
-(IBAction)doPrevItemEvent:(id)sender;
-(void)updateLeftItemTitle:(NSString*)str;
@end
