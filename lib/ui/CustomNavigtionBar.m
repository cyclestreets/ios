//
//  BULeftNavItemView.m
//
//
//  Created by Neil Edwards on 04/12/2009.
//  Copyright 2009 Buffer. All rights reserved.
//

#import "CustomNavigtionBar.h"
#import "GlobalUtilities.h"
#import "StyleManager.h"
#import "LayoutBox.h"
#import "ButtonUtilities.h"
#import "GenericConstants.h"
#import "ExpandedUILabel.h"

@implementation CustomNavigtionBar
@synthesize backButton;
@synthesize refreshButton;
@synthesize titleLabel;
@synthesize subtitleLabel;
@synthesize rightButton;
@synthesize rightBarButton;
@synthesize rightButtonTitle;
@synthesize nextItemButton;
@synthesize prevItemButton;
@synthesize navigationItem;
@synthesize rightButtonStyle;
@synthesize leftButtonStyle;
@synthesize dataProvider;
@synthesize rightItems;
@synthesize titleType;
@synthesize rightItemType;
@synthesize leftItemType;
@synthesize titleImage;
@synthesize leftItemTitle;
@synthesize titleString;
@synthesize activityStyle;
@synthesize titleFontSize;
@synthesize titleFontColor;
@synthesize delegate;


/***********************************************************/
// dealloc
/***********************************************************/
- (void)dealloc
{
    delegate = nil;
	
}







- (id)init {
    if (self = [super init]) {
		titleType=BUNavNoneType;
		leftItemType=BUNavBackType;
		rightItemType=BUNavNoneType;
		activityStyle=UIActivityIndicatorViewStyleWhite;
		titleFontSize=19;
		self.titleFontColor=[UIColor whiteColor];
    }
    return self;
}


-(void)createNavigationUI{
	
	[self createLeftNavItem];
	[self createTitle];
	[self createRightNavItem];
	
	
}


-(void)createLeftNavItem{
	
	// basic arrow only back style
	if([leftItemType isEqualToString:BUNavBackType]){
		
		self.backButton=[ButtonUtilities UISimpleImageButton:@"navbarback"];
		
		[backButton addTarget:self action:@selector(doBackEvent:) forControlEvents:UIControlEventTouchUpInside];
		
		UIBarButtonItem *barbutton=[[UIBarButtonItem alloc] initWithCustomView:backButton];
		[navigationItem setLeftBarButtonItem:barbutton animated:YES];
	
	// standard back with text label style
	}else if ([leftItemType isEqualToString:BUNavBackStandardType]) {
		
        UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
		button.adjustsImageWhenHighlighted=YES;
		button.frame=CGRectMake(0, 0, 52, 30);
		self.backButton=button;
		[backButton setBackgroundImage:[[[StyleManager sharedInstance] imageForType:@"UINavigationBar_backblank_lo"] stretchableImageWithLeftCapWidth:16 topCapHeight:0 ] forState:UIControlStateNormal];
		if([[StyleManager sharedInstance] imageForType:@"UINavigationBar_backblank_hi"] !=nil)
			[backButton setBackgroundImage:[[[StyleManager sharedInstance] imageForType:@"UINavigationBar_backblank_hi"] stretchableImageWithLeftCapWidth:16 topCapHeight:0 ] forState:UIControlStateHighlighted];
		
		
		[backButton setTitle:leftItemTitle forState:UIControlStateNormal];
		[backButton setTitle:leftItemTitle forState:UIControlStateHighlighted];
		[backButton setTitle:leftItemTitle forState:UIControlStateSelected];
		backButton.titleEdgeInsets=UIEdgeInsetsMake(0, 7, 0, 0);
		backButton.titleLabel.userInteractionEnabled=NO;
		backButton.titleLabel.font=[UIFont boldSystemFontOfSize:12];;
		[backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[backButton setTitleShadowColor:[UIColor colorWithRed:.25 green:.25 blue:.25 alpha:.7] forState:UIControlStateNormal];
		backButton.titleLabel.textAlignment=UITextAlignmentCenter;
		backButton.titleLabel.shadowOffset=CGSizeMake(0, -1);
		
		[backButton addTarget:self action:@selector(doBackEvent:) forControlEvents:UIControlEventTouchUpInside];
		
		UIBarButtonItem *barbutton=[[UIBarButtonItem alloc] initWithCustomView:backButton];
		[navigationItem setLeftBarButtonItem:barbutton animated:YES];
		
		
	}else if ([leftItemType isEqualToString:BUNavUICustomType]){
		
		UIButton *leftButton=[ButtonUtilities UIButtonWithWidth:30 height:30 type:leftButtonStyle text:leftItemTitle];
		
		[leftButton addTarget:self action:@selector(doGenericLeftEvent:) forControlEvents:UIControlEventTouchUpInside];
		
		UIBarButtonItem *barbutton=[[UIBarButtonItem alloc] initWithCustomView:leftButton];
		[navigationItem setLeftBarButtonItem:barbutton animated:YES];
		
	// these two used to remove/hide the button	
	}else if ([leftItemType isEqualToString:BUNavNoneType]){
		
		[navigationItem setLeftBarButtonItem:nil animated:NO];
		
	}else if ([leftItemType isEqualToString:BUNavNullType]){
		
		UIButton *leftButton=[ButtonUtilities UIButtonWithWidth:10 height:10 type:leftButtonStyle text:@""];
		leftButton.hidden=YES;
		UIBarButtonItem *barbutton=[[UIBarButtonItem alloc] initWithCustomView:leftButton];
		[navigationItem setLeftBarButtonItem:barbutton animated:YES];
		
	}else if ([leftItemType isEqualToString:BUNavBackExistingType]){
		
		if(self.leftItemTitle!=nil){
			
			[navigationItem setBackBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:self.leftItemTitle style:UIBarButtonItemStylePlain target:nil action:nil]];
			
		}
		
	}
}




-(void)createTitle{
	
	
	// 2 line type with title and info (normally race/date combo)
	if([titleType isEqualToString:BUNavTitleReadoutType]){
	
		LayoutBox *labelContainer=[[LayoutBox alloc]init];
        labelContainer.layoutMode=BUVerticalLayoutMode;
		labelContainer.itemPadding=0;
		labelContainer.alignMode=BUCenterAlignMode;
		
		CGFloat lineheight;
		// title label
		lineheight=[GlobalUtilities calculateHeightOfTextFromWidth:[dataProvider objectForKey:@"title"] :[UIFont systemFontOfSize:18] :320 :UILineBreakModeHeadTruncation];
		ExpandedUILabel *tlabel=[[ExpandedUILabel alloc]initWithFrame:CGRectMake(0, 0, 50, lineheight)];
		tlabel.multiline=NO;
		self.titleLabel=tlabel;
		titleLabel.textAlignment=UITextAlignmentCenter;
		titleLabel.backgroundColor=[UIColor clearColor];
		titleLabel.font=[UIFont systemFontOfSize:18];
		titleLabel.textColor=titleFontColor;
		titleLabel.text=[dataProvider objectForKey:@"title"];
		[labelContainer addSubview:titleLabel];
		// sub label
		lineheight=[GlobalUtilities calculateHeightOfTextFromWidth:[dataProvider objectForKey:@"subtitle"] :[UIFont systemFontOfSize:10] :200 :UILineBreakModeHeadTruncation];
        ExpandedUILabel *slabel=[[ExpandedUILabel alloc]initWithFrame:CGRectMake(0, 0, 50, lineheight)];
		slabel.multiline=NO;
		self.subtitleLabel=slabel;
		subtitleLabel.textAlignment=UITextAlignmentCenter;
		subtitleLabel.backgroundColor=[UIColor clearColor];
		subtitleLabel.font=[UIFont systemFontOfSize:11];
		subtitleLabel.textColor=UIColorFromRGBAndAlpha(0xFFFFFF, 0.7f);
		subtitleLabel.text=[dataProvider objectForKey:@"subtitle"];
		[labelContainer addSubview:subtitleLabel];
		
		[navigationItem setTitleView:labelContainer];
	
	// logo image type
	}else if([titleType isEqualToString:BUNavTitleImageType]) {
				
		UIImage *image=[[StyleManager sharedInstance] imageForType:titleImage];
		UIImageView *ititle=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
		ititle.image=image;
		ititle.contentMode=UIViewContentModeCenter;
		[navigationItem setTitleView:ititle];
		
	// default iOS type
	}else if([titleType isEqualToString:BUNavTitleDefaultType]) {
		
        UILabel *tlabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, NAVIGATIONHEIGHT)];
		self.titleLabel=tlabel;
		titleLabel.textAlignment=UITextAlignmentCenter;
		titleLabel.backgroundColor=[UIColor clearColor];
		titleLabel.font=[UIFont boldSystemFontOfSize:titleFontSize];
		titleLabel.textColor=titleFontColor;
		if(titleFontColor==[UIColor whiteColor]){
			titleLabel.shadowColor=UIColorFromRGB(0x666666);
			titleLabel.shadowOffset=CGSizeMake(0, -1);
		}else {
			titleLabel.shadowColor=UIColorFromRGB(0xcccccc);
			titleLabel.shadowOffset=CGSizeMake(0, 1);
		}

		titleLabel.text=titleString;
		
		[navigationItem setTitleView:titleLabel];
		
	}
	
}

-(void)updateTitleString:(NSString*)str{
	self.titleString=str;
	self.titleLabel.text=self.titleString;
}


-(void)createRightNavItemWithType:(NSString*)type{
	
	if(![type isEqualToString:rightItemType]){
		rightItemType=type;
		[self createRightNavItem];
	}
	
	
}

-(void)createRightNavItem{
	

	// data refresh type
	if([rightItemType isEqualToString:BUNavRefreshType]){
	
        UIButton *button=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 20, 20)];
		self.refreshButton=button;
		[refreshButton	setImage:[[StyleManager sharedInstance] imageForType:@"uibuttonbar_refresh"] forState:UIControlStateNormal];
		[refreshButton addTarget:self action:@selector(doRefreshEvent:) forControlEvents:UIControlEventTouchUpInside];
		UIBarButtonItem *barbutton=[[UIBarButtonItem alloc] initWithCustomView:refreshButton];
		[navigationItem setRightBarButtonItem:barbutton animated:YES];
		
	// data activity type	
	}else if([rightItemType isEqualToString:BUNavActivityType]){
		
		
		UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:activityStyle];
		CGRect aframe=CGRectMake(0,0, 20, 20);
		activity.frame=aframe;
		[activity startAnimating];
		UIBarButtonItem *barbutton=[[UIBarButtonItem alloc] initWithCustomView:activity];
		[navigationItem setRightBarButtonItem:barbutton animated:YES];
		
	// standard type	
	}else if ([rightItemType isEqualToString:BUNavButtonType]) {
		
        UIButton *button=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 60, 30)];
		self.rightButton=button;
		[rightButton setBackgroundImage:[[[StyleManager sharedInstance] imageForType:@"UIBarButton_lo"] stretchableImageWithLeftCapWidth:16 topCapHeight:0 ] forState:UIControlStateNormal];
		[rightButton setBackgroundImage:[[[StyleManager sharedInstance] imageForType:@"UIBarButton_hi"] stretchableImageWithLeftCapWidth:16 topCapHeight:0 ] forState:UIControlStateHighlighted];
		[rightButton setTitle:rightButtonTitle forState:UIControlStateNormal];
		[rightButton addTarget:self action:@selector(doGenericEvent:) forControlEvents:UIControlEventTouchUpInside];
		UIBarButtonItem *barbutton=[[UIBarButtonItem alloc] initWithCustomView:rightButton];
		[navigationItem setRightBarButtonItem:barbutton animated:NO];
		
	// actual UIKit	
	}else if ([rightItemType isEqualToString:UIKitButtonType]) {
		
        UIBarButtonItem *barbutton=[[UIBarButtonItem alloc] initWithTitle:rightButtonTitle style:UIBarButtonItemStyleBordered target:self action:@selector(doGenericEvent:)];
		self.rightBarButton=barbutton;
		[navigationItem setRightBarButtonItem:rightBarButton animated:NO];
		
	}else if ([rightItemType isEqualToString:BUNavNoneType]){
		
		[navigationItem setRightBarButtonItem:nil animated:NO];
	
	// up/down data stepper type
	}else if ([rightItemType isEqualToString:BUItemStepButtonType]) {
		
		LayoutBox *itemSelectView=[[LayoutBox alloc]initWithFrame:CGRectZero];
		
        UIButton    *pbutton=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 31, 30)];
		self.prevItemButton=pbutton;
		[prevItemButton setBackgroundImage:[[[StyleManager sharedInstance] imageForType:@"UIBarButton_up_lo"] stretchableImageWithLeftCapWidth:16 topCapHeight:0 ] forState:UIControlStateNormal];
		[prevItemButton setBackgroundImage:[[[StyleManager sharedInstance] imageForType:@"UIBarButton_up_hi"] stretchableImageWithLeftCapWidth:16 topCapHeight:0 ] forState:UIControlStateHighlighted];
		[prevItemButton setBackgroundImage:[[[StyleManager sharedInstance] imageForType:@"UIBarButton_up_disabled"] stretchableImageWithLeftCapWidth:16 topCapHeight:0 ] forState:UIControlStateDisabled];
		[prevItemButton addTarget:self action:@selector(doPrevItemEvent:) forControlEvents:UIControlEventTouchUpInside];
		[itemSelectView addSubview:prevItemButton];
		
		UIButton *nbutton=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 31, 30)];
		self.nextItemButton=nbutton;
		[nextItemButton setBackgroundImage:[[[StyleManager sharedInstance] imageForType:@"UIBarButton_down_lo"] stretchableImageWithLeftCapWidth:16 topCapHeight:0 ] forState:UIControlStateNormal];
		[nextItemButton setBackgroundImage:[[[StyleManager sharedInstance] imageForType:@"UIBarButton_down_hi"] stretchableImageWithLeftCapWidth:16 topCapHeight:0 ] forState:UIControlStateHighlighted];
		[nextItemButton setBackgroundImage:[[[StyleManager sharedInstance] imageForType:@"UIBarButton_down_disabled"] stretchableImageWithLeftCapWidth:16 topCapHeight:0 ] forState:UIControlStateDisabled];
		
		[nextItemButton addTarget:self action:@selector(doNextItemEvent:) forControlEvents:UIControlEventTouchUpInside];
		[itemSelectView addSubview:nextItemButton];
		
		rightBarButton=[[UIBarButtonItem alloc] initWithCustomView:itemSelectView];
		[navigationItem setRightBarButtonItem:rightBarButton animated:NO];

	}else if ([rightItemType isEqualToString:BUNavAddButtonType]){
		
		UIButton *addButton=[ButtonUtilities UIIconButton:rightButtonStyle iconImage:@"UIButtonIcon_add" height:32 width:32];
		[addButton addTarget:self action:@selector(doGenericEvent:) forControlEvents:UIControlEventTouchUpInside];
		UIBarButtonItem *barbutton=[[UIBarButtonItem alloc] initWithCustomView:addButton];
		[navigationItem setRightBarButtonItem:barbutton animated:YES];
		
		
	}else if ([rightItemType isEqualToString:BUNavUICustomType]){
		
		self.rightButton=[ButtonUtilities UIButtonWithWidth:30 height:30 type:rightButtonStyle text:rightButtonTitle];
		
		[rightButton addTarget:self action:@selector(doGenericEvent:) forControlEvents:UIControlEventTouchUpInside];
		
		UIBarButtonItem *barbutton=[[UIBarButtonItem alloc] initWithCustomView:rightButton];
		[navigationItem setRightBarButtonItem:barbutton animated:YES];
		
		
	}else if ([rightItemType isEqualToString:BUNavNoneType]){
		
		[navigationItem setRightBarButtonItem:nil animated:NO];
		
	}else if([rightItemType isEqualToString:BUNavUIKitIconType]){
		
		UIBarButtonItem *barbutton=[[UIBarButtonItem alloc] initWithImage:[[StyleManager sharedInstance] imageForType:rightButtonStyle]  style:UIBarButtonItemStyleBordered target:self action:@selector(doGenericEvent:)];
		self.rightBarButton=barbutton;
		[navigationItem setRightBarButtonItem:rightBarButton animated:NO];
		
		
	}
	
	
}




-(void)updateLeftItemTitle:(NSString*)str{
	
	if([leftItemType isEqualToString:BUNavBackStandardType]){
		leftItemTitle=str;
		
		[backButton setTitle:leftItemTitle forState:UIControlStateNormal];
		[backButton setTitle:leftItemTitle forState:UIControlStateHighlighted];
		[backButton setTitle:leftItemTitle forState:UIControlStateSelected];
	
	}
}



//
/***********************************************
 * @description			DELEGATE METHODS
 ***********************************************/
//



#pragma maBU delegate methods

-(IBAction)doBackEvent:(id)sender{
	
	if([delegate respondsToSelector:@selector(didRequestPopController)]){
		[delegate didRequestPopController];
	}
	
}

-(IBAction)doRefreshEvent:(id)sender{
	
	if([delegate respondsToSelector:@selector(didRequestRefresh)]){
		
		// swap refresh for activity
		
		[delegate didRequestRefresh];
	}
	
}

-(IBAction)doGenericLeftEvent:(id)sender{
	
	if([delegate respondsToSelector:@selector(doNavigationSelector:)]){
		[delegate doNavigationSelector:LEFT]; 
	}
	
}

-(IBAction)doGenericEvent:(id)sender{
	
	// TODO: get tag for sender for index of right items array if using array based construction
	if([delegate respondsToSelector:@selector(doNavigationSelector:)]){
		[delegate doNavigationSelector:RIGHT];  // for now just send default
	}
	
}
	
-(IBAction)doNextItemEvent:(id)sender{
	if([delegate respondsToSelector:@selector(doNavigationItemSelector:)]){
		[delegate doNavigationItemSelector:NEXT];
	}	
}
-(IBAction)doPrevItemEvent:(id)sender{
	if([delegate respondsToSelector:@selector(doNavigationItemSelector:)]){
		[delegate doNavigationItemSelector:PREV];
	}
}


//------------------------------------------------------------------------------------
#pragma mark - Class methods
//------------------------------------------------------------------------------------

+(UIBarButtonItem*)createBackButtonItemwithSelector:(SEL)selector target:(id)target{
	
	UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
	button.frame=CGRectMake(0, 0, 52, 30);
	
	[button setBackgroundImage:[[[StyleManager sharedInstance] imageForType:@"UIBarButton_Back"] stretchableImageWithLeftCapWidth:16 topCapHeight:0 ] forState:UIControlStateNormal];
	
	
	[button setTitle:@"Back" forState:UIControlStateNormal];
	button.titleEdgeInsets=UIEdgeInsetsMake(0, 7, 0, 0);
	button.titleLabel.userInteractionEnabled=NO;
	button.titleLabel.font=[UIFont boldSystemFontOfSize:12];;
	[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[button setTitleShadowColor:[UIColor colorWithRed:.25 green:.25 blue:.25 alpha:.7] forState:UIControlStateNormal];
	button.titleLabel.textAlignment=UITextAlignmentCenter;
	button.titleLabel.shadowOffset=CGSizeMake(0, -1);
	
	[button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
	
	UIBarButtonItem *barbutton=[[UIBarButtonItem alloc] initWithCustomView:button];

	
	return barbutton;
	
}

@end
