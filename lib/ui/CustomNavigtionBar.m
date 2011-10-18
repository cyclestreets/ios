//
//  BULeftNavItemView.m
//
//
//  Created by Neil Edwards on 04/12/2009.
//  Copyright 2009 Chroma. All rights reserved.
//

#import "CustomNavigtionBar.h"
#import "GlobalUtilities.h"
#import "StyleManager.h"
#import "ViewUtilities.h"
#import "LayoutBox.h"
#import "ButtonUtilities.h"

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
@synthesize titleFontSize;
@synthesize titleFontColor;
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
    [rightButtonStyle release], rightButtonStyle = nil;
    [leftButtonStyle release], leftButtonStyle = nil;
    [dataProvider release], dataProvider = nil;
    [rightItems release], rightItems = nil;
    [titleType release], titleType = nil;
    [rightItemType release], rightItemType = nil;
    [leftItemType release], leftItemType = nil;
    [titleImage release], titleImage = nil;
    [leftItemTitle release], leftItemTitle = nil;
    [titleString release], titleString = nil;
    [titleFontColor release], titleFontColor = nil;
    delegate = nil;
	
    [super dealloc];
}







- (id)init {
    if (self = [super init]) {
		titleType=BUNavNoneType;
		leftItemType=BUNavBackType;
		rightItemType=BUNavNoneType;
		titleFontSize=18;
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
	if(leftItemType==BUNavBackType){
		
		UIImage  *backimage=[[StyleManager sharedInstance] imageForType:@"UINavigationBar_back_lo"];
		
        UIButton *button=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, backimage.size.width, 30)];
		self.backButton=button;
        [button release];
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
		
        UIButton *button=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 60, 32)];
		self.backButton=button;
        [button release];
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
		
		
	}else if ([leftItemType isEqualToString:BUNavUICustomType]){
		
		UIButton *leftButton=[ButtonUtilities UIButtonWithWidth:30 height:30 type:leftButtonStyle text:leftItemTitle];
		
		[leftButton addTarget:self action:@selector(doGenericLeftEvent:) forControlEvents:UIControlEventTouchUpInside];
		
		UIBarButtonItem *barbutton=[[UIBarButtonItem alloc] initWithCustomView:leftButton];
		[navigationItem setLeftBarButtonItem:barbutton animated:YES];
		[barbutton release];
		
		
	}else if ([leftItemType isEqualToString:BUNavNoneType]){
		
		[navigationItem setLeftBarButtonItem:nil animated:NO];
		
	}
}


-(void)createTitle{
	
	
	// 2 line type with title and info (normally race/date combo)
	if(titleType==BUNavTitleReadoutType){
	
		LayoutBox *labelContainer=[[LayoutBox alloc]init];
        labelContainer.layoutMode=BUVerticalLayoutMode;
		labelContainer.itemPadding=0;
		labelContainer.alignMode=BUCenterAlignMode;
		CGFloat lineheight;
		// title label
		lineheight=[GlobalUtilities calculateHeightOfTextFromWidth:[dataProvider objectForKey:@"title"] :[UIFont systemFontOfSize:18] :200 :UILineBreakModeHeadTruncation];
        UILabel *tlabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, lineheight)];
		self.titleLabel=tlabel;
        [tlabel release];
		titleLabel.textAlignment=UITextAlignmentCenter;
		titleLabel.backgroundColor=[UIColor clearColor];
		titleLabel.font=[UIFont systemFontOfSize:18];
		titleLabel.textColor=[UIColor whiteColor];
		titleLabel.text=[dataProvider objectForKey:@"title"];
		[labelContainer addSubview:titleLabel];
		// sub label
		lineheight=[GlobalUtilities calculateHeightOfTextFromWidth:[dataProvider objectForKey:@"subtitle"] :[UIFont systemFontOfSize:10] :200 :UILineBreakModeHeadTruncation];
        UILabel *slabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, lineheight)];
		self.subtitleLabel=slabel;
        [slabel release];
		subtitleLabel.textAlignment=UITextAlignmentCenter;
		subtitleLabel.backgroundColor=[UIColor clearColor];
		subtitleLabel.font=[UIFont systemFontOfSize:11];
		subtitleLabel.textColor=UIColorFromRGB(0x8e9fca);
		subtitleLabel.text=[dataProvider objectForKey:@"subtitle"];
		[labelContainer addSubview:subtitleLabel];
		
		[navigationItem setTitleView:labelContainer];
		[labelContainer release];
	
	// logo image type
	}else if(titleType==BUNavTitleImageType) {
				
		UIImage *image=[[StyleManager sharedInstance] imageForType:titleImage];
		UIImageView *ititle=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
		ititle.image=image;
		ititle.contentMode=UIViewContentModeCenter;
		[navigationItem setTitleView:ititle];
		[ititle release];
		
	// default iOS type
	}else if(titleType==BUNavTitleDefaultType) {
		
		CGFloat lineheight;
		
		lineheight=[GlobalUtilities calculateHeightOfTextFromWidth:titleString :[UIFont systemFontOfSize:titleFontSize] :200 :UILineBreakModeHeadTruncation];
        UILabel *tlabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, lineheight)];
		self.titleLabel=tlabel;
        [tlabel release];
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




-(void)createRightNavItemWithType:(NSString*)type{
	
	if(![type isEqualToString:rightItemType]){
		rightItemType=type;
		[self createRightNavItem];
	}
	
	
}

-(void)createRightNavItem{
	

	
	if([rightItemType isEqualToString:BUNavRefreshType]){
	
        UIButton *button=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 20, 20)];
		self.refreshButton=button;
        [button release];
		[refreshButton	setImage:[[StyleManager sharedInstance] imageForType:@"uibuttonbar_refreshgray"] forState:UIControlStateNormal];
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
		[barbutton release];
		
	}else if ([rightItemType isEqualToString:BUNavButtonType]) {
		
        UIButton *button=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 60, 30)];
		self.rightButton=button;
        [button release];
		[rightButton setBackgroundImage:[[[StyleManager sharedInstance] imageForType:@"UIBarButton_lo"] stretchableImageWithLeftCapWidth:16 topCapHeight:0 ] forState:UIControlStateNormal];
		[rightButton setBackgroundImage:[[[StyleManager sharedInstance] imageForType:@"UIBarButton_hi"] stretchableImageWithLeftCapWidth:16 topCapHeight:0 ] forState:UIControlStateHighlighted];
		[rightButton setTitle:rightButtonTitle forState:UIControlStateNormal];
		[rightButton addTarget:self action:@selector(doGenericEvent:) forControlEvents:UIControlEventTouchUpInside];
		UIBarButtonItem *barbutton=[[UIBarButtonItem alloc] initWithCustomView:rightButton];
		[navigationItem setRightBarButtonItem:barbutton animated:NO];
		[barbutton release];
		
		
	}else if ([rightItemType isEqualToString:UIKitButtonType]) {
		
        UIBarButtonItem *barbutton=[[UIBarButtonItem alloc] initWithTitle:rightButtonTitle style:UIBarButtonItemStyleBordered target:self action:@selector(doGenericEvent:)];
		self.rightBarButton=barbutton;
        [barbutton release];
		[navigationItem setRightBarButtonItem:rightBarButton animated:NO];
		
	}else if ([rightItemType isEqualToString:BUNavNoneType]){
		
		[navigationItem setRightBarButtonItem:nil animated:NO];
		
	}else if ([rightItemType isEqualToString:BUItemStepButtonType]) {
		
		LayoutBox *itemSelectView=[[LayoutBox alloc]initWithFrame:CGRectZero];
		
        UIButton    *pbutton=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
		self.prevItemButton=pbutton;
        [pbutton release];
		[prevItemButton setBackgroundImage:[[[StyleManager sharedInstance] imageForType:@"UINavLeftSegment_bg"] stretchableImageWithLeftCapWidth:16 topCapHeight:0 ] forState:UIControlStateNormal];
		[prevItemButton setBackgroundImage:[[[StyleManager sharedInstance] imageForType:@"UINavLeftSegment_bg"] stretchableImageWithLeftCapWidth:16 topCapHeight:0 ] forState:UIControlStateHighlighted];
		[prevItemButton setBackgroundImage:[[[StyleManager sharedInstance] imageForType:@"UINavLeftSegment_bg"] stretchableImageWithLeftCapWidth:16 topCapHeight:0 ] forState:UIControlStateDisabled];
		[prevItemButton setImage:[[StyleManager sharedInstance] imageForType:@"navuparrow"] forState:UIControlStateNormal];
		[prevItemButton setImage:[[StyleManager sharedInstance] imageForType:@"navuparrow_disabled"] forState:UIControlStateDisabled];
		[prevItemButton addTarget:self action:@selector(doPrevItemEvent:) forControlEvents:UIControlEventTouchUpInside];
		[itemSelectView addSubview:prevItemButton];
		
		UIButton *nbutton=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
		self.nextItemButton=nbutton;
        [nbutton release];
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
		
		UIButton *addButton=[ButtonUtilities UIIconButton:@"UIButtonIcon_add" height:30 type:@"green"];
		[addButton addTarget:self action:@selector(doGenericEvent:) forControlEvents:UIControlEventTouchUpInside];
		UIBarButtonItem *barbutton=[[UIBarButtonItem alloc] initWithCustomView:addButton];
		[navigationItem setRightBarButtonItem:barbutton animated:YES];
		[barbutton release];
		
		
	}else if ([rightItemType isEqualToString:BUNavUICustomType]){
		
		self.rightButton=[ButtonUtilities UIButtonWithWidth:30 height:30 type:rightButtonStyle text:rightButtonTitle];
		
		[rightButton addTarget:self action:@selector(doGenericEvent:) forControlEvents:UIControlEventTouchUpInside];
		
		UIBarButtonItem *barbutton=[[UIBarButtonItem alloc] initWithCustomView:rightButton];
		[navigationItem setRightBarButtonItem:barbutton animated:YES];
		[barbutton release];
		
		
	}else if ([rightItemType isEqualToString:BUNavNoneType]){
		
		[navigationItem setRightBarButtonItem:nil animated:NO];
		
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
		[delegate doNavigationItemSelector:RIGHT];
	}	
}
-(IBAction)doPrevItemEvent:(id)sender{
	if([delegate respondsToSelector:@selector(doNavigationItemSelector:)]){
		[delegate doNavigationItemSelector:LEFT];
	}
}

@end
