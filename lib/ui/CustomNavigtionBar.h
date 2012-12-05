//
//  CustomNavigtionBar.h
//  Generic
//
//  Created by Neil Edwards on 04/12/2009.
//  Copyright 2009 Buffer. All rights reserved.
//

#import <UIKit/UIKit.h>

#define	BUNavTitleImageType @"NavImageTitle"
#define	BUNavTitleDefaultType @"BUNavTitleDefaultType"
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
#define	BUNavUICustomType @"BUNavUICustomType"
#define	BUNavNullType @"BUNavNullType"


@protocol CustomNavigationBarDelegate <NSObject>

-(void)didRequestPopController;
@optional
-(void)didRequestRefresh;
-(IBAction)doNavigationSelector:(NSString*)type;
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
	
	NSString				*rightButtonStyle;
	NSString				*leftButtonStyle;
	
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
	
	UIActivityIndicatorViewStyle	activityStyle;
	
	// used in conjunction with BUNavTitleDefaultType
	int						titleFontSize;
	UIColor					*titleFontColor;
	
	// delegate
	id<CustomNavigationBarDelegate> __unsafe_unretained delegate;
	
	
}
@property (nonatomic, strong)	UIButton		*backButton;
@property (nonatomic, strong)	UIButton		*refreshButton;
@property (nonatomic, strong)	UILabel		*titleLabel;
@property (nonatomic, strong)	UILabel		*subtitleLabel;
@property (nonatomic, strong)	UIButton		*rightButton;
@property (nonatomic, strong)	UIBarButtonItem		*rightBarButton;
@property (nonatomic, strong)	NSString		*rightButtonTitle;
@property (nonatomic, strong)	UIButton		*nextItemButton;
@property (nonatomic, strong)	UIButton		*prevItemButton;
@property (nonatomic, strong)	UINavigationItem		*navigationItem;
@property (nonatomic, strong)	NSString		*rightButtonStyle;
@property (nonatomic, strong)	NSString		*leftButtonStyle;
@property (nonatomic, strong)	NSMutableDictionary		*dataProvider;
@property (nonatomic, strong)	NSMutableArray		*rightItems;
@property (nonatomic, strong)	NSString		*titleType;
@property (nonatomic, strong)	NSString		*rightItemType;
@property (nonatomic, strong)	NSString		*leftItemType;
@property (nonatomic, strong)	NSString		*titleImage;
@property (nonatomic, strong)	NSString		*leftItemTitle;
@property (nonatomic, strong)	NSString		*titleString;
@property (nonatomic)	UIActivityIndicatorViewStyle		activityStyle;
@property (nonatomic)	int		titleFontSize;
@property (nonatomic, strong)	UIColor		*titleFontColor;
@property (nonatomic, unsafe_unretained)		id<CustomNavigationBarDelegate>		 delegate;


-(void)createNavigationUI;
-(void)createLeftNavItem;
-(void)createTitle;
-(void)createRightNavItem;
-(void)createRightNavItemWithType:(NSString*)type;
-(IBAction)doBackEvent:(id)sender;
-(IBAction)doRefreshEvent:(id)sender;
-(IBAction)doGenericEvent:(id)sender;
-(IBAction)doGenericLeftEvent:(id)sender;
-(IBAction)doNextItemEvent:(id)sender;
-(IBAction)doPrevItemEvent:(id)sender;
-(void)updateLeftItemTitle:(NSString*)str;



+(UIBarButtonItem*)createBackButtonItemwithSelector:(SEL)selector target:(id)target;

@end
