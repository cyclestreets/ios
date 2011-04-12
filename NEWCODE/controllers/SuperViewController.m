//
//  SuperViewController.m
//  RacingUK
//
//  Created by Neil Edwards on 07/12/2009.
//  Copyright 2009 Chroma. All rights reserved.
//

#import "SuperViewController.h"
#import "StyleManager.h"
#import "GlobalUtilities.h"
#import "ViewUtilities.h"
#import "AppConstants.h"
#import "VBox.h"
#import "GradientView.h"
#import "VBox.h"

@implementation SuperViewController
@synthesize navigation;
@synthesize frame;
@synthesize delegate;
@synthesize appearWasBackEvent;
@synthesize notifications;
@synthesize UIType;
@synthesize GATag;

/***********************************************************/
// dealloc
/***********************************************************/
- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    [navigation release], navigation = nil;
    delegate = nil;
    [notifications release], notifications = nil;
    [UIType release], UIType = nil;
    [GATag release], GATag = nil;
	
    [super dealloc];
}




-(void)initialise{
	
	notifications=[[NSMutableArray alloc]init];
	
}

-(void)viewDidLoad{
	
	[self listNotificationInterests];
	[self addNotifications];
}


-(void)viewWillAppear:(BOOL)animated{
	
	//[[GoogleAnalyticsManager sharedInstance] trackPageViewWithNavigation:self.navigationController.viewControllers];
	
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
	[self showConnectionErrorView:NO];
}
-(void)createNonPersistentUI{}
-(void)createPersistentUI{}
-(void)refreshUIFromDataProvider{}

#pragma mark RKCustomNavigationBarDelegate method

-(void)didRequestPopController{
	[self.navigationController popViewControllerAnimated:YES];
}



// generic method to receive global notification (puremvc handleNotification)
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
		[self showConnectionErrorView:YES];
	}
	
}


//
/***********************************************
 * @description			shows/hides request loading overlay view
 ***********************************************/
//
#define kRemoteRequestTAG 9999
-(void)handleRemoteRequestIndication:(BOOL)show{
	
	
	if(self.navigationController.visibleViewController==self){
		
		if(show==YES){
			
			if([self.view viewWithTag:kRemoteRequestTAG]!=nil){
				return;
			}
			
			GradientView *loadingview;
			
			VBox	*contentContainer=[[VBox alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 10)];
			contentContainer.fixedWidth=YES;
			contentContainer.verticalGap=0;
			contentContainer.alignby=CENTER;
			
			
			if([UIType isEqualToString:UITYPE_CONTROLUI]){
				loadingview=[[GradientView alloc] initWithFrame:CGRectMake(0, CONTROLUIHEIGHT, SCREENWIDTH, SCREENHEIGHTWITHCONTROLUI)];
			}else if([UIType isEqualToString:UITYPE_MODALUI]) {
				loadingview=[[GradientView alloc] initWithFrame:CGRectMake(0, CONTROLUIHEIGHT, SCREENWIDTH, NAVCONTROLMODALHEIGHT)];
			}else {
				loadingview=[[GradientView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, NAVTABVIEWHEIGHT)];
			}
			
			[loadingview setColoursWithCGColors:UIColorFromRGB(0xFFFFFF).CGColor :UIColorFromRGB(0xDDDDDD).CGColor];
			
			//
			UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
			CGRect aframe=CGRectMake(0, 0, 20, 20);
			activity.frame=aframe;
			loadingview.tag=kRemoteRequestTAG;
			[activity startAnimating];
			[contentContainer addSubview:activity];
			[activity release];
			
			UILabel *ilabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 40)];
			ilabel.backgroundColor=[UIColor clearColor];
			ilabel.textColor=[[StyleManager sharedInstance] colorForType:@"darkgreen"];
			ilabel.numberOfLines=0;
			ilabel.textAlignment=UITextAlignmentCenter;
			ilabel.font=[UIFont boldSystemFontOfSize:12];
			ilabel.shadowColor=[UIColor whiteColor];
			ilabel.shadowOffset=CGSizeMake(0, 1);
			ilabel.text=@"LOADING DATA...";
			[contentContainer addSubview:ilabel];
			[ilabel release];
			
			[loadingview addSubview:contentContainer];
			[ViewUtilities alignView:contentContainer withView:loadingview :BUCenterAlignMode :BUCenterAlignMode];
			[contentContainer release];
			
			[self.view addSubview:loadingview];
			[loadingview release];
			
		}else {
			UIView	*loadingview = [self.view viewWithTag:kRemoteRequestTAG];
			[loadingview removeFromSuperview];
			loadingview=nil;
			
			[self showConnectionErrorView:NO];
			
		}
		
	}
	
}

//
/***********************************************
 * @description			shows/hides custom results view no results overlay view
 ***********************************************/
//
#define kNoResultsViewTAG 9998
-(void)showNoResultsView:(BOOL)show{
	
	//BetterLog(@"");
	
	//if(self.navigationController.visibleViewController==self){
		
		//BetterLog(@"");
	
		if(show==YES){
			
			
			//BetterLog(@"");
			
			GradientView *errorView;
			VBox *contentContainer;
			
			if([UIType isEqualToString:UITYPE_CONTROLUI]){
				contentContainer=[[VBox alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHTWITHCONTROLUI)];
				errorView=[[GradientView alloc] initWithFrame:CGRectMake(0, CONTROLUIHEIGHT, SCREENWIDTH, SCREENHEIGHTWITHCONTROLUI)];
			}else if ([UIType isEqualToString:UITYPE_CONTROLHEADERUI]) {
				contentContainer=[[VBox alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHTWITHCONTROLANDHEADERUI)];
				errorView=[[GradientView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHTWITHCONTROLANDHEADERUI)];
			}else {
				contentContainer=[[VBox alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, NAVTABVIEWHEIGHT)];
				errorView=[[GradientView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, NAVTABVIEWHEIGHT)];
			}
			
			[errorView setColoursWithCGColors:UIColorFromRGB(0xFFFFFF).CGColor :UIColorFromRGB(0xDDDDDD).CGColor];
			errorView.tag=kNoResultsViewTAG;
			contentContainer.verticalGap=20;
			contentContainer.fixedWidth=YES;
			contentContainer.alignby=CENTER;
			
			UIImageView *iview=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 180, 150)];
			iview.image=[UIImage imageNamed:@"Alert200x200.png"];
			iview.alpha=.4;
			[contentContainer addSubview:iview];
			[iview release];
			
			UILabel *ilabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 40)];
			ilabel.backgroundColor=[UIColor clearColor];
			ilabel.textColor=[UIColor grayColor];
			ilabel.numberOfLines=0;
			ilabel.textAlignment=UITextAlignmentCenter;
			ilabel.font=[UIFont systemFontOfSize:12];
			ilabel.shadowColor=[UIColor whiteColor];
			ilabel.shadowOffset=CGSizeMake(0, 1);
			ilabel.text=@"There are no results yet";
			[contentContainer addSubview:ilabel];					
			[ilabel release];
			
			[errorView addSubview:contentContainer];
			[ViewUtilities alignView:contentContainer withView:errorView :BUNoneLayoutMode :BUCenterAlignMode];
			[self.view addSubview:errorView];
			[contentContainer release];
			[errorView release];
			
		}else {
			UIView	*errorView = [self.view viewWithTag:kNoResultsViewTAG];
			[errorView removeFromSuperview];
			errorView=nil;
			
		}
		
	//}
	
}

//
/***********************************************
 * @description			shws/hies conection error overlay view
 ***********************************************/
//
#define kConnectionErrorViewTAG 9997
-(void)showConnectionErrorView:(BOOL)show{
	
	if(self.navigationController.visibleViewController==self){
		
		if(show==YES){
			
			if([self.view viewWithTag:kConnectionErrorViewTAG]!=nil){
				return;
			}
			
			   
			GradientView *errorView;
			VBox *contentContainer;
			
			if([UIType isEqualToString:UITYPE_CONTROLUI]){
				contentContainer=[[VBox alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHTWITHCONTROLUI)];
				errorView=[[GradientView alloc] initWithFrame:CGRectMake(0, CONTROLUIHEIGHT, SCREENWIDTH, SCREENHEIGHTWITHCONTROLUI)];
			}else if([UIType isEqualToString:UITYPE_MODALUI]){
				contentContainer=[[VBox alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, NAVCONTROLMODALHEIGHT)];
				errorView=[[GradientView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, NAVCONTROLMODALHEIGHT)];
			}else {
				contentContainer=[[VBox alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, NAVTABVIEWHEIGHT)];
				errorView=[[GradientView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, NAVTABVIEWHEIGHT)];
			}
			
			
			[errorView setColoursWithCGColors:UIColorFromRGB(0xFFFFFF).CGColor :UIColorFromRGB(0xDDDDDD).CGColor];
			errorView.tag=kConnectionErrorViewTAG;
			contentContainer.verticalGap=20;
			contentContainer.fixedWidth=YES;
			contentContainer.alignby=CENTER;
			
			UIImage *image=[UIImage imageNamed:@"Alert200x200.png"];
			UIImageView *iview=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, image.size.width,image.size.height)];
			iview.image=image;
			iview.alpha=.4;
			[contentContainer addSubview:iview];
			[iview release];
			
			UILabel *ilabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 80)];
			ilabel.backgroundColor=[UIColor clearColor];
			ilabel.textColor=[UIColor grayColor];
			ilabel.numberOfLines=0;
			ilabel.textAlignment=UITextAlignmentCenter;
			ilabel.font=[UIFont systemFontOfSize:12];
			ilabel.shadowColor=[UIColor whiteColor];
			ilabel.shadowOffset=CGSizeMake(0, 1);
			ilabel.text=@"Unable to contact the server as no Wi-Fi or cellular network was detected, please check your network settings.";
			[contentContainer addSubview:ilabel];					
			[ilabel release];
			
			[errorView addSubview:contentContainer];
			[ViewUtilities alignView:contentContainer withView:errorView :BUNoneLayoutMode :BUCenterAlignMode];
			[contentContainer release];
			[self.view addSubview:errorView];
			[errorView release];
			
		}else {
			UIView	*errorView = [self.view viewWithTag:kConnectionErrorViewTAG];
			[errorView removeFromSuperview];
			errorView=nil;
			
		}
		
	}
	
}



//
/***********************************************
 * @description			shws/hies conection error overlay view
 ***********************************************/
//
#define kRestrictionErrorViewTAG 9996
-(void)showEventRestrictionView:(BOOL)show{
	
	if(self.navigationController.visibleViewController==self){
		
		if(show==YES){
			
			if([self.view viewWithTag:kRestrictionErrorViewTAG]!=nil){
				return;
			}
			
			
			GradientView *errorView;
			VBox *contentContainer;
			
			if([UIType isEqualToString:UITYPE_CONTROLUI]){
				contentContainer=[[VBox alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHTWITHCONTROLUI)];
				errorView=[[GradientView alloc] initWithFrame:CGRectMake(0, CONTROLUIHEIGHT, SCREENWIDTH, SCREENHEIGHTWITHCONTROLUI)];
			}else if([UIType isEqualToString:UITYPE_MODALUI]){
				contentContainer=[[VBox alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, NAVCONTROLMODALHEIGHT)];
				errorView=[[GradientView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, NAVCONTROLMODALHEIGHT)];
			}else {
				contentContainer=[[VBox alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, NAVTABVIEWHEIGHT)];
				errorView=[[GradientView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, NAVTABVIEWHEIGHT)];
			}
			
			
			[errorView setColoursWithCGColors:UIColorFromRGB(0xFFFFFF).CGColor :UIColorFromRGB(0xDDDDDD).CGColor];
			errorView.tag=kRestrictionErrorViewTAG;
			contentContainer.verticalGap=20;
			contentContainer.fixedWidth=YES;
			contentContainer.alignby=CENTER;
			
			UIImage *image=[UIImage imageNamed:@"Alert200x200.png"];
			UIImageView *iview=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, image.size.width,image.size.height)];
			iview.image=image;
			iview.alpha=.4;
			[contentContainer addSubview:iview];
			[iview release];
			
			UILabel *ilabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 80)];
			ilabel.backgroundColor=[UIColor clearColor];
			ilabel.textColor=[UIColor grayColor];
			ilabel.numberOfLines=0;
			ilabel.textAlignment=UITextAlignmentCenter;
			ilabel.font=[UIFont systemFontOfSize:12];
			ilabel.shadowColor=[UIColor whiteColor];
			ilabel.shadowOffset=CGSizeMake(0, 1);
			ilabel.text=@"You cannot view this data unless you are logged in";
			[contentContainer addSubview:ilabel];					
			[ilabel release];
			
			[errorView addSubview:contentContainer];
			[ViewUtilities alignView:contentContainer withView:errorView :BUNoneLayoutMode :BUCenterAlignMode];
			[contentContainer release];
			[self.view addSubview:errorView];
			[errorView release];
			
		}else {
			UIView	*errorView = [self.view viewWithTag:kRestrictionErrorViewTAG];
			[errorView removeFromSuperview];
			errorView=nil;
			
		}
		
	}
	
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
