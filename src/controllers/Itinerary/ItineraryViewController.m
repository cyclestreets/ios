    //
//  ItineraryViewController.m
//  CycleStreets
//
//  Created by Neil Edwards on 09/03/2011.
//  Copyright 2011 CycleStreets Ltd. All rights reserved.
//

#import "ItineraryViewController.h"
#import "RouteVO.h"
#import "ItineraryCellView.h"
#import "SegmentVO.h"
#import "CycleStreets.h"
#import "AppDelegate.h"
#import "RouteSegmentViewController.h"
#import "ButtonUtilities.h"
#import "AppConstants.h"
#import "ExpandedUILabel.h"
#import "RouteManager.h"
#import "LayoutBox.h"
#import "ViewUtilities.h"
#import "GradientView.h"
#import <Twitter/Twitter.h>


@implementation ItineraryViewController
@synthesize route;
@synthesize routeId;
@synthesize headerText;
@synthesize routeSegmentViewcontroller;
@synthesize routeidLabel;
@synthesize readoutLineOne;
@synthesize readoutLineTwo;
@synthesize readoutLineThree;
@synthesize readoutContainer;
@synthesize tableView;
@synthesize rowHeightsArray;


//
/***********************************************
 * @description		NOTIFICATIONS
 ***********************************************/
//

-(void)listNotificationInterests{
	
	[self initialise];
	
	[notifications addObject:CSROUTESELECTED];
	
	[super listNotificationInterests];
	
}

-(void)didReceiveNotification:(NSNotification*)notification{
	
	BetterLog(@"");
	
	[super didReceiveNotification:notification];
	
	if([notification.name isEqualToString:CSROUTESELECTED]){
		[self refreshUIFromDataProvider];
	}
	
}


//
/***********************************************
 * @description			DATA UPDATING
 ***********************************************/
//

-(void)refreshUIFromDataProvider{
	
	BetterLog(@"");
	
	self.route=[RouteManager sharedInstance].selectedRoute;
	self.routeId = [route.routeid integerValue];
	
	
	[self createRowHeightsArray];
	[tableView reloadData];
	
}


//
/***********************************************
 * @description			UI CREATION
 ***********************************************/
//

- (void)viewDidLoad {
	
	[self refreshUIFromDataProvider];
	
    [super viewDidLoad];
	
	[self createPersistentUI];
}


-(void)createPersistentUI{
	
	readoutContainer.paddingTop=5;
	readoutContainer.itemPadding=4;
	readoutContainer.layoutMode=BUVerticalLayoutMode;
	readoutContainer.alignMode=BUCenterAlignMode;
	readoutContainer.fixedWidth=YES;
	readoutContainer.fixedHeight=YES;
	readoutContainer.backgroundColor=UIColorFromRGB(0xE5E5E5);
	
	routeidLabel.multiline=NO;
	
	
	readoutLineOne=[[MultiLabelLine alloc]initWithFrame:CGRectMake(0, 0, UIWIDTH, 15)];
	readoutLineOne.showShadow=YES;
	readoutLineOne.colors=[NSArray arrayWithObjects:UIColorFromRGB(0x804000),UIColorFromRGB(0x000000),UIColorFromRGB(0x804000),UIColorFromRGB(0x000000),nil];
	readoutLineOne.fonts=[NSArray arrayWithObjects:[UIFont boldSystemFontOfSize:13],[UIFont systemFontOfSize:13],[UIFont boldSystemFontOfSize:13],[UIFont systemFontOfSize:13],nil];
	
	readoutLineTwo=[[MultiLabelLine alloc]initWithFrame:CGRectMake(0, 0, UIWIDTH, 15)];
	readoutLineTwo.showShadow=YES;
	readoutLineTwo.colors=[NSArray arrayWithObjects:UIColorFromRGB(0x804000),UIColorFromRGB(0x000000),UIColorFromRGB(0x804000),UIColorFromRGB(0x000000),nil];
	readoutLineTwo.fonts=[NSArray arrayWithObjects:[UIFont boldSystemFontOfSize:13],[UIFont systemFontOfSize:13],[UIFont boldSystemFontOfSize:13],[UIFont systemFontOfSize:13],nil];
	
	readoutLineThree=[[MultiLabelLine alloc]initWithFrame:CGRectMake(0, 0, UIWIDTH, 15)];
	readoutLineThree.showShadow=YES;
	readoutLineThree.colors=[NSArray arrayWithObjects:UIColorFromRGB(0x804000),UIColorFromRGB(0x000000),UIColorFromRGB(0x804000),UIColorFromRGB(0x000000),nil];
	readoutLineThree.fonts=[NSArray arrayWithObjects:[UIFont boldSystemFontOfSize:13],[UIFont systemFontOfSize:13],[UIFont boldSystemFontOfSize:13],[UIFont systemFontOfSize:13],nil];
	
	
	ExpandedUILabel *readoutlabel=[[ExpandedUILabel alloc] initWithFrame:CGRectMake(0, 0, UIWIDTH, 10)];
	readoutlabel.font=[UIFont systemFontOfSize:12];
	readoutlabel.textColor=UIColorFromRGB(0x666666);
	readoutlabel.shadowColor=[UIColor whiteColor];
	readoutlabel.shadowOffset=CGSizeMake(0, 1);
	readoutlabel.text=@"Select any segment to view the map & details for it.";
	 
	
	[readoutContainer addSubViewsFromArray:[NSArray arrayWithObjects:readoutLineOne,readoutLineTwo,readoutLineThree,readoutlabel, nil]];
	
	[self createNavigationBarUI];
}


-(void)viewWillAppear:(BOOL)animated{
	
	[super viewWillAppear:animated];
	
	[self createNonPersistentUI];
	
	[super deSelectRowForTableView:tableView];
	
}

-(void)createNonPersistentUI{
	
	BetterLog(@"");
	
	
	if(route==nil){
		
		
		[self showNoActiveRouteView:YES];
		
		self.navigationItem.rightBarButtonItem.enabled=NO;
		
		
	}else {
		
		[self showNoActiveRouteView:NO];
		
		routeidLabel.text=[route routeid];
		
		readoutLineOne.labels=[NSArray arrayWithObjects:@"Length:",route.lengthString,
							   @"Estimated time:",route.timeString,nil];
		[readoutLineOne drawUI];
		
		readoutLineTwo.labels=[NSArray arrayWithObjects:@"Planned speed:",route.speedString,
							   @"Strategy:",route.planString,nil];
		[readoutLineTwo drawUI];
		
		readoutLineThree.labels=[NSArray arrayWithObjects:@"Calories:",route.calorieString,
							   @"CO2 saved:",route.coString,nil];
		[readoutLineThree drawUI];
		
		self.navigationItem.rightBarButtonItem.enabled=YES;
		
		
	}
	
}


-(void)createNavigationBarUI{
	
}


//
/***********************************************
 * @description		UITABLEVIEW DELEGATE METHODS
 ***********************************************/
//

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
   return [route numSegments];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ItineraryCellView *cell = (ItineraryCellView *)[ItineraryCellView cellForTableView:tv fromNib:[ItineraryCellView nib]];
	
	SegmentVO *segment = [route segmentAtIndex:indexPath.row];
	cell.dataProvider=segment;
	[cell populate];
	
    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if(routeSegmentViewcontroller==nil){
		self.routeSegmentViewcontroller=[[RouteSegmentViewController alloc] initWithNibName:@"RouteSegmentView" bundle:nil];
		routeSegmentViewcontroller.hidesBottomBarWhenPushed=YES;
	}
	
	[routeSegmentViewcontroller setRoute:route];
	routeSegmentViewcontroller.index=[indexPath row];
	
	[self.navigationController pushViewController:routeSegmentViewcontroller animated:YES];

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	
	return [[rowHeightsArray objectAtIndex:[indexPath row]] floatValue];
}




//
/***********************************************
 * @description		UI EVENTS
 ***********************************************/
//

-(IBAction)shareButtonSelected:(id)sender{
	
	NSArray *activitites;
	
	if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0")) {
		
		UIActivityViewController *activity=[[UIActivityViewController alloc] initWithActivityItems:@[[NSURL URLWithString:[NSString stringWithFormat:@"cyclestreets://route/%@",route.routeid]]] applicationActivities:nil];
		activity.excludedActivityTypes = @[UIActivityTypeSaveToCameraRoll, UIActivityTypePrint, UIActivityTypePostToWeibo];
		
		[self presentViewController:activity animated:YES completion:nil];
		[activity setCompletionHandler:^(NSString *activityType, BOOL completed){
			
			if(completed==YES){
				
				
				
			}
			
		}];
		 
		 
		 
	}else{
		activitites=@[@(BUIconActionSheetIconTypeTwitter),@(BUIconActionSheetIconTypeMail),@(BUIconActionSheetIconTypeSMS)];
		
		BUIconActionSheet *iconSheet=[[BUIconActionSheet alloc] initWithButtons:activitites andTitle:@"Share your CycleStreets route"];
		iconSheet.delegate=self;
		
		[iconSheet show:YES];
	}

	
	
}

// BUIconActionSheet delegate callback
-(void)actionSheetClickedButtonWithType:(BUIconActionSheetIconType)type{
	
	
	
	switch (type) {
		case BUIconActionSheetIconTypeTwitter:
			
			if ([TWTweetComposeViewController canSendTweet]) {   
					
				TWTweetComposeViewController *tweetViewController = [[TWTweetComposeViewController alloc] init];
				[tweetViewController setInitialText:@"My CycleStreet route"];
					
				[tweetViewController addURL:[NSURL URLWithString:[NSString stringWithFormat:@"cyclestreets://route/%@",route.routeid]]]; 
					
				[self presentViewController:tweetViewController animated:YES completion:nil];
				[tweetViewController setCompletionHandler:^(SLComposeViewControllerResult result){
					
					if(result==TWTweetComposeViewControllerResultDone){
						
						
						
					}
					
				}];
					
				} else {
					
					UIAlertView *alertView = [[UIAlertView alloc]
											  initWithTitle:@"Sorry"
											  message:@"You can't send a tweet right now, make sure your device has an internet connection and you have at least one Twitter account setup"
											  delegate:self
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
					[alertView show];
					
					
					
					
			}
				
			
		break;
		
		case BUIconActionSheetIconTypeMail:
		{
			MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
			picker.mailComposeDelegate = self;
			[picker setSubject:[NSString stringWithFormat:@"CycleStreets route %@",route.routeid]];
			
			UINavigationBar		*pickerNavBar=[[[picker viewControllers] lastObject] navigationBar];
			
			
			if(picker!=nil)
				[self presentModalViewController:picker animated:YES];
		}
		break;
			
		case BUIconActionSheetIconTypeSMS:
		{
			
			MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
			picker.messageComposeDelegate = self;
			picker.body=[NSString stringWithFormat:@"CycleStreets route %@",route.routeid];
			
			if(picker!=nil)
				[self presentModalViewController:picker animated:YES];
			
		}
			
		break;
	}
	
}


// The mail compose view controller delegate method
- (void)mailComposeController:(MFMailComposeViewController *)controller  didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
	
	[self dismissModalViewControllerAnimated:YES];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result{
	
	[self dismissModalViewControllerAnimated:YES];
}


#define kItineraryPlanView 9001
-(void)showNoActiveRouteView:(BOOL)show{
	
	if(show==YES){
		
		GradientView *errorView;
		LayoutBox *contentContainer;
		
		contentContainer=[[LayoutBox alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, NAVTABVIEWHEIGHT)];
		errorView=[[GradientView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, NAVTABVIEWHEIGHT)];
		
		[errorView setColoursWithCGColors:UIColorFromRGB(0xFFFFFF).CGColor :UIColorFromRGB(0xDDDDDD).CGColor];
		errorView.tag=kItineraryPlanView;
		contentContainer.layoutMode=BUVerticalLayoutMode;
        contentContainer.itemPadding=20;
        contentContainer.fixedWidth=YES;
        contentContainer.alignMode=BUCenterAlignMode;
		
		ExpandedUILabel *titlelabel=[[ExpandedUILabel alloc]initWithFrame:CGRectMake(0, 0, UIWIDTH, 10)];
		titlelabel.font=[UIFont boldSystemFontOfSize:14];
		titlelabel.textAlignment=UITextAlignmentCenter;
		titlelabel.hasShadow=YES;
		titlelabel.textColor=[UIColor grayColor];
		titlelabel.text=@"You have no route active currently.";
		[contentContainer addSubview:titlelabel];					
		
		ExpandedUILabel *infolabel=[[ExpandedUILabel alloc]initWithFrame:CGRectMake(0, 0, UIWIDTH, 10)];
		infolabel.font=[UIFont systemFontOfSize:13];
		infolabel.textAlignment=UITextAlignmentCenter;
		infolabel.hasShadow=YES;
		infolabel.textColor=[UIColor grayColor];
		infolabel.text=@"Once you have loaded a route, the itinerary will be shown here.";
		[contentContainer addSubview:infolabel];					
		
		UIButton *routeButton=[ButtonUtilities UIButtonWithWidth:100 height:32 type:@"green" text:@"Plan route"];
		[routeButton addTarget:self action:@selector(swapToMapView) forControlEvents:UIControlEventTouchUpInside];
		[contentContainer addSubview:routeButton];
		
		UIButton *savedButton=[ButtonUtilities UIButtonWithWidth:100 height:32 type:@"green" text:@"Saved routes"];
		[savedButton addTarget:self action:@selector(swapToSavedRoutesView) forControlEvents:UIControlEventTouchUpInside];
		[contentContainer addSubview:savedButton];
		
		[errorView addSubview:contentContainer];
		[ViewUtilities alignView:contentContainer withView:errorView :BUNoneLayoutMode :BUCenterAlignMode];
		[self.view addSubview:errorView];
		
	}else {
		UIView	*errorView = [self.view viewWithTag:kItineraryPlanView];
		[errorView removeFromSuperview];
		errorView=nil;
		
	}
	
	
}

-(IBAction)swapToMapView{
	[[CycleStreets sharedInstance].appDelegate showTabBarViewControllerByName:@"Plan route"];
}

-(IBAction)swapToSavedRoutesView{
	[[CycleStreets sharedInstance].appDelegate showTabBarViewControllerByName:@"Saved routes"];
}


//
/***********************************************
 * @description			GENERIC METHODS
 ***********************************************/
//

-(void)createRowHeightsArray{
	
	self.rowHeightsArray=[[NSMutableArray alloc]init];
	
	for (int i=0; i<[route numSegments]; i++) {
		
		SegmentVO *segment = [route segmentAtIndex:i];
		
		[rowHeightsArray addObject:[ItineraryCellView heightForCellWithDataProvider:segment]];
		
		
	}
	
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}




@end
