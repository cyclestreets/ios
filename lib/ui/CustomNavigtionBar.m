//
//  BULeftNavItemView.m
//  RacingUK
//
//  Created by Neil Edwards on 04/12/2009.
//  Copyright 2009 Chroma. All rights reserved.
//

#import "CustomNavigtionBar.h"
#import "GlobalUtilities.h"
#import "StyleManager.h"
#import "ViewUtilities.h"
#import "VBox.h"
#import "HBox.h"


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
@synthesize dataProvider;
@synthesize rightItems;
@synthesize titleType;
@synthesize rightItemType;
@synthesize leftItemType;
@synthesize titleImage;
@synthesize leftItemTitle;
@synthesize titleString;
@synthesize delegate;


/***********************************************************/
// dealloc
/***********************************************************/
- (void)dealloc
{
    [backButton release], backButton = nil;
    [refreshButton release], refreshButton = nil;
    [titleLabel release], titleLabel = nil;
    [subtitleLabel release], subtitleLabel = nil;
    [rightButton release], rightButton = nil;
    [rightBarButton release], rightBarButton = nil;
    [rightButtonTitle release], rightButtonTitle = nil;
    [nextItemButton release], nextItemButton = nil;
    [prevItemButton release], prevItemButton = nil;
    [navigationItem release], navigationItem = nil;
    [dataProvider release], dataProvider = nil;
    [rightItems release], rightItems = nil;
    [titleType release], titleType = nil;
    [rightItemType release], rightItemType = nil;
    [leftItemType release], leftItemType = nil;
    [titleImage release], titleImage = nil;
    [leftItemTitle release], leftItemTitle = nil;
    [titleString release], titleString = nil;
    delegate = nil;
	
    [super dealloc];
}





- (id)init {
    if (self = [super init]) {
		titleType=BUNavNoneType;
		leftItemType=BUNavBackType;
		rightItemType=BUNavRefreshType;
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
	if(leftItemType==BUNavBackType){
		
		backButton=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 32)];
		[backButton setBackgroundImage:[[[StyleManager sharedInstance] imageForType:@"UINavigationBar_back_lo"] stretchableImageWithLeftCapWidth:16 topCapHeight:0 ] forState:UIControlStateNormal];
		[backButton setBackgroundImage:[[[StyleManager sharedInstance] imageForType:@"UINavigationBar_back_hi"] stretchableImageWithLeftCapWidth:16 topCapHeight:0 ] forState:UIControlStateHighlighted];
		[backButton	setImage:[[StyleManager sharedInstance] imageForType:@"uibuttonbar_backarrow"] forState:UIControlStateNormal];
		[backButton	setImage:[[StyleManager sharedInstance] imageForType:@"uibuttonbar_backarrow"] forState:UIControlStateHighlighted];
		[backButton addTarget:self action:@selector(doBackEvent:) forControlEvents:UIControlEventTouchUpInside];
		
		UIBarButtonItem *barbutton=[[UIBarButtonItem alloc] initWithCustomView:backButton];
		[navigationItem setLeftBarButtonItem:barbutton animated:YES];
		[barbutton release];
	
		// standard back with text label style
	}else if (leftItemType==BUNavBackStandardType) {
		
		backButton=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 60, 32)];
		[backButton setBackgroundImage:[[[StyleManager sharedInstance] imageForType:@"UINavigationBar_back_lo"] stretchableImageWithLeftCapWidth:16 topCapHeight:0 ] forState:UIControlStateNormal];
		[backButton setBackgroundImage:[[[StyleManager sharedInstance] imageForType:@"UINavigationBar_back_hi"] stretchableImageWithLeftCapWidth:16 topCapHeight:0 ] forState:UIControlStateHighlighted];
		
		
		[backButton setTitle:leftItemTitle forState:UIControlStateNormal];
		[backButton setTitle:leftItemTitle forState:UIControlStateHighlighted];
		[backButton setTitle:leftItemTitle forState:UIControlStateSelected];
		backButton.titleEdgeInsets=UIEdgeInsetsMake(0, 5, 0, 0);
		backButton.titleLabel.userInteractionEnabled=NO;
		backButton.titleLabel.font=[UIFont systemFontOfSize:12];;
		[backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[backButton setTitleShadowColor:[UIColor grayColor] forState:UIControlStateNormal];
		backButton.titleLabel.textAlignment=UITextAlignmentCenter;
		backButton.titleLabel.shadowOffset=CGSizeMake(0, -1);
		
		[backButton addTarget:self action:@selector(doBackEvent:) forControlEvents:UIControlEventTouchUpInside];
		
		UIBarButtonItem *barbutton=[[UIBarButtonItem alloc] initWithCustomView:backButton];
		[navigationItem setLeftBarButtonItem:barbutton animated:YES];
		[barbutton release];
		
		
	}
}


-(void)createTitle{
	
	
	
	if(titleType==BUNavTitleReadoutType){
	
	
		VBox *labelContainer=[[VBox alloc]init];
		labelContainer.verticalGap=0;
		labelContainer.alignby=CENTER;
		CGFloat lineheight;
		// title label
		lineheight=[GlobalUtilities calculateHeightOfTextFromWidth:[dataProvider objectForKey:@"title"] :[UIFont systemFontOfSize:18] :200 :UILineBreakModeHeadTruncation];
		titleLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, lineheight)];
		titleLabel.textAlignment=UITextAlignmentCenter;
		titleLabel.backgroundColor=[UIColor clearColor];
		titleLabel.font=[UIFont systemFontOfSize:18];
		titleLabel.textColor=[UIColor whiteColor];
		titleLabel.text=[dataProvider objectForKey:@"title"];
		[labelContainer addSubview:titleLabel];
		// sub label
		lineheight=[GlobalUtilities calculateHeightOfTextFromWidth:[dataProvider objectForKey:@"subtitle"] :[UIFont systemFontOfSize:10] :200 :UILineBreakModeHeadTruncation];
		subtitleLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, lineheight)];
		subtitleLabel.textAlignment=UITextAlignmentCenter;
		subtitleLabel.backgroundColor=[UIColor clearColor];
		subtitleLabel.font=[UIFont systemFontOfSize:11];
		subtitleLabel.textColor=UIColorFromRGB(0x8e9fca);
		subtitleLabel.text=[dataProvider objectForKey:@"subtitle"];
		[labelContainer addSubview:subtitleLabel];
		
		[navigationItem setTitleView:labelContainer];
		[labelContainer release];
	
	
		
	}else if(titleType==BUNavTitleIncrementalType){
		
		
		CGFloat lineheight;
		
		lineheight=[GlobalUtilities calculateHeightOfTextFromWidth:titleString :[UIFont systemFontOfSize:18] :200 :UILineBreakModeHeadTruncation];
		titleLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, lineheight)];
		titleLabel.textAlignment=UITextAlignmentCenter;
		titleLabel.backgroundColor=[UIColor clearColor];
		titleLabel.font=[UIFont systemFontOfSize:18];
		titleLabel.textColor=[UIColor whiteColor];
		titleLabel.shadowColor=UIColorFromRGB(0x666666);
		titleLabel.text=titleString;
		
		[navigationItem setTitleView:titleLabel];
		
	}else if(titleType==BUNavTitleImageType) {
		
		
		UIImage *image=[[StyleManager sharedInstance] imageForType:titleImage];
		UIImageView *ititle=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
		ititle.image=image;
		ititle.contentMode=UIViewContentModeCenter;
		[navigationItem setTitleView:ititle];
		[ititle release];
		
	}
	
}




-(void)createRightNavItemWithType:(NSString*)type{
	
	if(![type isEqualToString:rightItemType]){
		rightItemType=type;
		[self createRightNavItem];
	}
	
	
}

-(void)createRightNavItem{
	

	
	if([rightItemType isEqualToString:BUNavRefreshType]){
	
		refreshButton=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 20, 20)];
		[refreshButton	setImage:[[StyleManager sharedInstance] imageForType:@"uibuttonbar_refresh"] forState:UIControlStateNormal];
		[refreshButton addTarget:self action:@selector(doRefreshEvent:) forControlEvents:UIControlEventTouchUpInside];
		UIBarButtonItem *barbutton=[[UIBarButtonItem alloc] initWithCustomView:refreshButton];
		[navigationItem setRightBarButtonItem:barbutton animated:YES];
		[barbutton release];
		
		
	}else if([rightItemType isEqualToString:BUNavActivityType]){
		
		UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		CGRect aframe=CGRectMake(0,0, 20, 20);
		activity.frame=aframe;
		[activity startAnimating];
		UIBarButtonItem *barbutton=[[UIBarButtonItem alloc] initWithCustomView:activity];
		[activity release];
		[navigationItem setRightBarButtonItem:barbutton animated:YES];
		// Note: do we want o support request cancelling from here?
		[barbutton release];
		
	}else if ([rightItemType isEqualToString:BUNavButtonType]) {
		
		rightButton=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 60, 30)];
		[rightButton setBackgroundImage:[[[StyleManager sharedInstance] imageForType:@"UIBarButton_lo"] stretchableImageWithLeftCapWidth:16 topCapHeight:0 ] forState:UIControlStateNormal];
		[rightButton setBackgroundImage:[[[StyleManager sharedInstance] imageForType:@"UIBarButton_hi"] stretchableImageWithLeftCapWidth:16 topCapHeight:0 ] forState:UIControlStateHighlighted];
		[rightButton setTitle:rightButtonTitle forState:UIControlStateNormal];
		[rightButton addTarget:self action:@selector(doGenericEvent:) forControlEvents:UIControlEventTouchUpInside];
		UIBarButtonItem *barbutton=[[UIBarButtonItem alloc] initWithCustomView:rightButton];
		[navigationItem setRightBarButtonItem:barbutton animated:NO];
		[barbutton release];
		
		
	}else if ([rightItemType isEqualToString:UIKitButtonType]) {
		
		rightBarButton=[[UIBarButtonItem alloc] initWithTitle:rightButtonTitle style:UIBarButtonItemStyleBordered target:self action:@selector(doGenericEvent:)];
		[navigationItem setRightBarButtonItem:rightBarButton animated:NO];
		
	}else if ([rightItemType isEqualToString:BUNavNoneType]){
		
		[navigationItem setRightBarButtonItem:nil animated:NO];
		
	}else if ([rightItemType isEqualToString:BUItemStepButtonType]) {
		
		HBox *itemSelectView=[[HBox alloc]initWithFrame:CGRectZero];
		
		prevItemButton=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
		[prevItemButton setBackgroundImage:[[[StyleManager sharedInstance] imageForType:@"UINavLeftSegment_bg"] stretchableImageWithLeftCapWidth:16 topCapHeight:0 ] forState:UIControlStateNormal];
		[prevItemButton setBackgroundImage:[[[StyleManager sharedInstance] imageForType:@"UINavLeftSegment_bg"] stretchableImageWithLeftCapWidth:16 topCapHeight:0 ] forState:UIControlStateHighlighted];
		[prevItemButton setBackgroundImage:[[[StyleManager sharedInstance] imageForType:@"UINavLeftSegment_bg"] stretchableImageWithLeftCapWidth:16 topCapHeight:0 ] forState:UIControlStateDisabled];
		[prevItemButton setImage:[[StyleManager sharedInstance] imageForType:@"navuparrow"] forState:UIControlStateNormal];
		[prevItemButton setImage:[[StyleManager sharedInstance] imageForType:@"navuparrow_disabled"] forState:UIControlStateDisabled];
		[prevItemButton addTarget:self action:@selector(doPrevItemEvent:) forControlEvents:UIControlEventTouchUpInside];
		[itemSelectView addSubview:prevItemButton];
		
		
		nextItemButton=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
		[nextItemButton setBackgroundImage:[[[StyleManager sharedInstance] imageForType:@"UINavRightSegment_bg"] stretchableImageWithLeftCapWidth:16 topCapHeight:0 ] forState:UIControlStateNormal];
		[nextItemButton setBackgroundImage:[[[StyleManager sharedInstance] imageForType:@"UINavRightSegment_bg"] stretchableImageWithLeftCapWidth:16 topCapHeight:0 ] forState:UIControlStateHighlighted];
		[nextItemButton setBackgroundImage:[[[StyleManager sharedInstance] imageForType:@"UINavRightSegment_bg"] stretchableImageWithLeftCapWidth:16 topCapHeight:0 ] forState:UIControlStateDisabled];
		[nextItemButton setImage:[[StyleManager sharedInstance] imageForType:@"navdownarrow"] forState:UIControlStateNormal];
		
		[nextItemButton addTarget:self action:@selector(doNextItemEvent:) forControlEvents:UIControlEventTouchUpInside];
		[itemSelectView addSubview:nextItemButton];
		
		rightBarButton=[[UIBarButtonItem alloc] initWithCustomView:itemSelectView];
		[itemSelectView release];
		[navigationItem setRightBarButtonItem:rightBarButton animated:NO];

	}else if ([rightItemType isEqualToString:BUNavAddButtonType]){
		
		UIButton *addButton=[GlobalUtilities UIImageButtonWithWidth:@"UIButtonIcon_add" height:30 type:@"green" text:@""];
		[addButton addTarget:self action:@selector(doGenericEvent:) forControlEvents:UIControlEventTouchUpInside];
		UIBarButtonItem *barbutton=[[UIBarButtonItem alloc] initWithCustomView:addButton];
		[navigationItem setRightBarButtonItem:barbutton animated:YES];
		[barbutton release];
		
		
	}
	
	
}




-(void)updateLeftItemTitle:(NSString*)str{
	
	if(leftItemType==BUNavBackStandardType){
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



-(IBAction)doGenericEvent:(id)sender{
	
	if([delegate respondsToSelector:@selector(doNavigationSelector:)]){
		[delegate doNavigationSelector:RIGHT];  // for now just send default
	}
	
}
	
-(IBAction)doNextItemEvent:(id)sender{
	if([delegate respondsToSelector:@selector(doNavigationItemSelector:)]){
		[delegate doNavigationItemSelector:RIGHT];
	}	
}
-(IBAction)doPrevItemEvent:(id)sender{
	if([delegate respondsToSelector:@selector(doNavigationItemSelector:)]){
		[delegate doNavigationItemSelector:LEFT];
	}
}

@end
