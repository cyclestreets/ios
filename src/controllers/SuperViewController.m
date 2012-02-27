//
//  SuperViewController.m
//  
//
//  Created by Neil Edwards on 07/12/2009.
//

#import "SuperViewController.h"
#import "StyleManager.h"
#import "GlobalUtilities.h"
#import "ViewUtilities.h"
#import "AppConstants.h"
#import "LayoutBox.h"
#import "GradientView.h"
#import "ExpandedUILabel.h"
#import "StringManager.h"
#import "ButtonUtilities.h"
#import "CycleStreetsAppDelegate.h"

@implementation SuperViewController
@synthesize navigation;
@synthesize frame;
@synthesize delegate;
@synthesize appearWasBackEvent;
@synthesize notifications;
@synthesize UIType;
@synthesize GATag;
@synthesize activeViewOverlayType;
@synthesize viewOverlayView;



//=========================================================== 
// dealloc
//=========================================================== 
- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	 [navigation release], navigation = nil;
    [delegate release], delegate = nil;
    [notifications release], notifications = nil;
    [UIType release], UIType = nil;
    [GATag release], GATag = nil;
    [viewOverlayView release], viewOverlayView = nil;
	
    [super dealloc];
}






-(void)initialise{
	
	self.notifications=[[NSMutableArray alloc]init];
	
}

-(void)viewDidLoad{
	
	[self listNotificationInterests];
	[self addNotifications];
}


-(void)viewWillAppear:(BOOL)animated{
	
	[super viewWillAppear:animated];
}


-(void)deSelectRowForTableView:(UITableView*)table{
	
	if(table!=nil){
		NSIndexPath*	selection = [table indexPathForSelectedRow];
		
		if (selection){
			[table deselectRowAtIndexPath:selection animated:YES];
		}
	}
	
}


-(void)createNavigationBarUI{}
-(void)setInitialState{
	[self showViewOverlayForType:kViewOverlayTypeConnectionFailed show:NO withMessage:nil];
}
-(void)createNonPersistentUI{}
-(void)createPersistentUI{}
-(void)refreshUIFromDataProvider{}

#pragma mark RKCustomNavigationBarDelegate method

-(void)didRequestPopController{
	[self.navigationController popViewControllerAnimated:YES];
}



-(void)listNotificationInterests{
	
	[notifications addObject:DATAREQUESTFAILED];
	[notifications addObject:CONNECTIONERROR];
}


-(void)addNotifications{
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	for (int i=0; i<[notifications count]; i++) {
		
		[[NSNotificationCenter defaultCenter]
		 addObserver:self
		 selector:@selector(didReceiveNotification:)
		 name:[notifications objectAtIndex:i]
		 object:nil];
		
	}
	
}


//
/***********************************************
 * @description			super class notification 
 ***********************************************/
//
-(void)didReceiveNotification:(NSNotification*)notification{
	
	//BetterLog(@" name=%@",notification.name);
	
	if([notification.name isEqualToString:DATAREQUESTFAILED]){
		if (![UIType isEqualToString:UITYPE_MODALUI]) {
			[navigation createRightNavItemWithType:BUNavRefreshType];
		}
		[self handleRemoteRequestIndication:NO];
		
	}else if([notification.name isEqualToString:CONNECTIONERROR]){
		if (![UIType isEqualToString:UITYPE_MODALUI]) {
			[navigation createRightNavItemWithType:BUNavRefreshType];
		}

		[self handleRemoteRequestIndication:NO];
		[self showViewOverlayForType:kViewOverlayTypeConnectionFailed show:YES withMessage:nil];
	}
	
}


//
/***********************************************
 * @description			New Generic Error view
 ***********************************************/
//
#define kSuperViewOverlayViewTag 8000
-(void)showViewOverlayForType:(ViewOverlayType)type show:(BOOL)show withMessage:(NSString*)message{
	
	
	if(show==YES){
		
		
		if(viewOverlayView!=nil){
			if (activeViewOverlayType==type) {
				return;
			}else {
				[viewOverlayView removeFromSuperview];
				self.viewOverlayView=nil;
			}
		}
		
		activeViewOverlayType=type;
		LayoutBox *contentContainer;
		
		if([UIType isEqualToString:UITYPE_CONTROLUI]){
			contentContainer=[[LayoutBox alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHTWITHCONTROLUI)];
			self.viewOverlayView=[[GradientView alloc] initWithFrame:CGRectMake(0, CONTROLUIHEIGHT, SCREENWIDTH, SCREENHEIGHTWITHCONTROLUI)];
		}else if ([UIType isEqualToString:UITYPE_CONTROLHEADERUI]) {
			contentContainer=[[LayoutBox alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHTWITHCONTROLANDHEADERUI)];
			self.viewOverlayView=[[GradientView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHTWITHCONTROLANDHEADERUI)];
		}else {
			contentContainer=[[LayoutBox alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, NAVTABVIEWHEIGHT)];
			self.viewOverlayView=[[GradientView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, NAVTABVIEWHEIGHT)];
		}
        
		
		[viewOverlayView setColoursWithCGColors:UIColorFromRGB(0xFFFFFF).CGColor :UIColorFromRGB(0xDDDDDD).CGColor];
		viewOverlayView.tag=kSuperViewOverlayViewTag;
        contentContainer.layoutMode=BUVerticalLayoutMode;
		contentContainer.itemPadding=10;
		contentContainer.fixedWidth=YES;
		contentContainer.alignMode=BUCenterAlignMode;
		
		
		switch(type){
				
			case kViewOverlayTypeNoResults:
				
				break;
			case kViewOverlayTypeLoginRestriction:		
			case kViewOverlayTypeConnectionFailed:
			case kViewOverlayTypeServerDown:
			{	
				UIImageView *iview=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 100, 100)];
				iview.image=[UIImage imageNamed:@"alertLarge.png"];
				iview.alpha=.3;
				[contentContainer addSubview:iview];
			}	
				break;	
				
			case kViewOverlayTypeRequestIndicator:
			{
				UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
				CGRect aframe=CGRectMake(0, 0, 20, 20);
				activity.frame=aframe;
				[activity startAnimating];
				[contentContainer addSubview:activity];
			}	
				break;
				
		}
		
		
		
		ExpandedUILabel *ilabel=[[ExpandedUILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 40)];
		ilabel.backgroundColor=[UIColor clearColor];
		
		switch(type){
				
			case kViewOverlayTypeRequestIndicator:
				ilabel.textColor=[[StyleManager sharedInstance] colorForType:@"maincolor"];
				ilabel.font=[UIFont boldSystemFontOfSize:12];
				break;
			default:
				ilabel.textColor=[UIColor grayColor];
				ilabel.font=[UIFont systemFontOfSize:13];
				break;
				
		}
		
		ilabel.numberOfLines=0;
		ilabel.textAlignment=UITextAlignmentCenter;
		ilabel.shadowColor=[UIColor whiteColor];
		ilabel.shadowOffset=CGSizeMake(0, 1);
		
		if(message==nil){
			NSString *viewTypeString=[SuperViewController viewTypeToStringType:type];
			BetterLog(@"viewTypeString=%@",viewTypeString);
			if (viewTypeString!=nil) {
				ilabel.text=[[StringManager sharedInstance] stringForSection:@"ui" andType:[NSString stringWithFormat:@"viewoverlaycontent_%@",viewTypeString]]; 
			}else {
				ilabel.text=@"An Error occured";
			}
			
			
		}else {
			ilabel.text=[[StringManager sharedInstance] stringForSection:@"ui" andType:message];
		}
		
		[contentContainer addSubview:ilabel];					
		
		
		
		switch(type){
				
			case kViewOverlayTypeRequestIndicator:
				viewOverlayView.alpha=0;
				
				[UIView beginAnimations:nil context:NULL];
				[UIView setAnimationDelegate:self];
				[UIView setAnimationDuration:0.1];
				viewOverlayView.alpha=1;
				[UIView commitAnimations];
				break;
				
			case kViewOverlayTypeLoginRestriction:
			{
				UIButton *button=[ButtonUtilities UIButtonWithWidth:100 height:30 type:@"racinggreen" text:@"Login"];
				[button addTarget:self action:@selector(loginButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
				[contentContainer addSubview:button];
				
			}
				
			default:
				
				break;
				
		}
		
		[viewOverlayView addSubview:contentContainer];
		[ViewUtilities alignView:contentContainer withView:viewOverlayView :BUNoneLayoutMode :BUCenterAlignMode];
		[self.view addSubview:viewOverlayView];
		
		
	}else {
		if(viewOverlayView!=nil){
			[viewOverlayView removeFromSuperview];
			self.viewOverlayView=nil;
		}
		activeViewOverlayType=kViewOverlayTypeNone;
		
	}
	
	
}


//
/***********************************************
 * @description			ViewOverlay callbacks
 ***********************************************/
//
-(IBAction)loginButtonSelected:(id)sender{
	CycleStreetsAppDelegate *appDelegate=(CycleStreetsAppDelegate*)[[UIApplication sharedApplication] delegate];
	[appDelegate showTabBarViewControllerByName:@"Account"];
}


+ (NSString*)viewTypeToStringType:(ViewOverlayType)viewType {
	
    NSString *result = nil;
	
    switch(viewType) {
        case kViewOverlayTypeConnectionFailed:
            result = @"ConnectionFailed";
            break;
        case kViewOverlayTypeDataRequestFailed:
            result = @"DataRequestFailed";
            break;
        case kViewOverlayTypeNoResults:
            result = @"NoResults";
            break;
		case kViewOverlayTypeServerDown:
			result = @"ServerDown"; 
			break;
		case kViewOverlayTypeLoginRestriction:
			result = @"LoginRestriction"; 
			break;	
		case kViewOverlayTypeRequestIndicator:
			result = @"RequestIndicator"; 
			break;		
		default:
			result = @"None";
			break;	
    }
	
    return result;
}


+ (NSString *)className{
    return NSStringFromClass([self class]);
}


+ (NSString *)nibName {
    return [[self className] stringByReplacingOccurrencesOfString:@"Controller" withString:@""];
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

@end
