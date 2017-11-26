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
#import "GenericConstants.h"
#import "MultiLabelLine.h"
#import "LayoutBox.h"
#import "RouteSegmentViewController.h"
#import "CopyLabel.h"
#import "BUIconActionSheet.h"
#import "A2StoryboardSegueContext.h"
#import "CSRouteDetailsViewController.h"
#import "UIView+Additions.h"

#import "BUIconActionSheet.h"
#import <MessageUI/MessageUI.h>
#import <Twitter/Twitter.h>

#import "CycleStreets-Swift.h"

@interface ItineraryViewController()<UITableViewDelegate,UITableViewDataSource,BUIconActionSheetDelegate,MFMailComposeViewControllerDelegate,MFMessageComposeViewControllerDelegate>

@property (nonatomic, strong) RouteVO                      * route;
@property (nonatomic, assign) NSInteger                    routeId;
@property (nonatomic, strong) UITextView                   * headerText;
@property (nonatomic, strong) RouteSegmentViewController * routeSegmentViewcontroller;
@property (nonatomic, weak) IBOutlet CopyLabel             * routeidLabel;
@property (nonatomic, strong) IBOutlet MultiLabelLine               * readoutLineOne;
@property (nonatomic, weak) IBOutlet LayoutBox             * readoutContainer;
@property (nonatomic, weak) IBOutlet UITableView           * tableView;
@property (nonatomic,strong) CSRouteDetailsViewController   *routeSummary;
@end


@implementation ItineraryViewController


#pragma mark - Notifications
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


#pragma mark - Data request/response
//
/***********************************************
 * @description			DATA UPDATING
 ***********************************************/
//

-(void)refreshUIFromDataProvider{
	
	BetterLog(@"");
	
	self.route=[RouteManager sharedInstance].selectedRoute;
    self.routeId = [_route.routeid integerValue];
	
	_routeidLabel.text=[_route routeid];
	
	_readoutLineOne.labels=[NSMutableArray arrayWithObjects:@"Length:",_route.lengthString,
							@"Estimated time:",_route.timeString,nil];
	[_readoutLineOne drawUI];
	
	[_tableView reloadData];
	
}


#pragma mark - UIView
//
/***********************************************
 * @description			UI CREATION
 ***********************************************/
//

- (void)viewDidLoad {
    
    [super viewDidLoad];
	
	[_tableView registerNib:[ItineraryCellView nib] forCellReuseIdentifier:[ItineraryCellView cellIdentifier]];
	_tableView.rowHeight=UITableViewAutomaticDimension;
	_tableView.estimatedRowHeight=44;
    
    [self createPersistentUI];
	
	[self refreshUIFromDataProvider];
	
}


-(void)createPersistentUI{
	
	
	_readoutLineOne.colors=[NSMutableArray arrayWithObjects:UIColorFromRGB(0x804000),UIColorFromRGB(0x5F5F5F),UIColorFromRGB(0x804000),UIColorFromRGB(0x5F5F5F),nil];
	_readoutLineOne.fonts=[NSMutableArray arrayWithObjects:[UIFont boldSystemFontOfSize:13],[UIFont systemFontOfSize:13],[UIFont boldSystemFontOfSize:13],[UIFont systemFontOfSize:13],nil];

	
	[self createNavigationBarUI];
}


-(void)viewWillAppear:(BOOL)animated{
	
	[super viewWillAppear:animated];
	
	[self createNonPersistentUI];
	
	[super deSelectRowForTableView:_tableView];
	
}

-(void)createNonPersistentUI{
	
	BetterLog(@"");
	
	
	if(_route==nil){
		
		
		[self showNoActiveRouteView:YES];
		
		self.navigationItem.rightBarButtonItem.enabled=NO;
		
		
	}else {
		
		[self showNoActiveRouteView:NO];
		
		
		
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


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
   return [_route numSegments];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	ItineraryCellView *cell = [_tableView dequeueReusableCellWithIdentifier:[ItineraryCellView cellIdentifier]];
	
	SegmentVO *segment = [_route segmentAtIndex:indexPath.row];
	cell.dataProvider=segment;
	[cell populate];
	
    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	[self performSegueWithIdentifier:@"RouteSegmentSegue" sender:self context:@{DATAPROVIDER: _route,INDEX:@([indexPath row])}];
	 
}



#pragma mark - UI events
//
/***********************************************
 * @description		UI EVENTS
 ***********************************************/
//

-(IBAction)didSelectRouteDetailsButton:(id)sender{
	
	if (self.routeSummary == nil) {
		self.routeSummary = [[CSRouteDetailsViewController alloc]init];
	}
	self.routeSummary.route = _route;
	_routeSummary.dataType=SavedRoutesDataTypeItinerary;
	[self showUniqueViewController:_routeSummary];
	
	
}



#define kItineraryPlanView 9001
-(void)showNoActiveRouteView:(BOOL)show{
	
	if(show==YES){
		
		GradientView *errorView;
		LayoutBox *contentContainer;
		
		errorView = (GradientView*)[self.view viewWithTag:kItineraryPlanView];
		
		if(errorView!=nil)
			[errorView removeFromSuperview];
		
		contentContainer=[[LayoutBox alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, self.view.height)];
		errorView=[[GradientView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, self.view.height)];
		
		[errorView setColoursWithCGColors:UIColorFromRGB(0xFFFFFF).CGColor :UIColorFromRGB(0xDDDDDD).CGColor];
		errorView.tag=kItineraryPlanView;
		contentContainer.layoutMode=BUVerticalLayoutMode;
        contentContainer.itemPadding=20;
        contentContainer.fixedWidth=YES;
        contentContainer.alignMode=BUCenterAlignMode;
		
		ExpandedUILabel *titlelabel=[[ExpandedUILabel alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width-40, 10)];
		[AppStyling applyStyleFor:titlelabel key:AppStyleUISubtitleLabel];
		titlelabel.text=@"You have no route active currently.";
		[contentContainer addSubview:titlelabel];					
		
		ExpandedUILabel *infolabel=[[ExpandedUILabel alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width-40, 10)];
		[AppStyling applyStyleFor:infolabel key:AppStyleUIMessageLabel];
		infolabel.text=@"Once you have loaded a route, the itinerary will be shown here.";
		[contentContainer addSubview:infolabel];					
		
		UIButton *routeButton=[ButtonUtilities UIPixateButtonWithWidth:120 height:32 styleId:@"greenButton" text:@"Plan route"];
		[routeButton addTarget:self action:@selector(swapToMapView) forControlEvents:UIControlEventTouchUpInside];
		[contentContainer addSubview:routeButton];
		
		UIButton *savedButton=[ButtonUtilities UIPixateButtonWithWidth:120 height:32 styleId:@"greenButton" text:@"Saved routes"];
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
	
	AppDelegate *appDelegate=[UIApplication sharedApplication].delegate;
	[appDelegate showTabBarViewControllerByName:TABBAR_MAP];
}

-(IBAction)swapToSavedRoutesView{
	AppDelegate *appDelegate=[UIApplication sharedApplication].delegate;
	[appDelegate showTabBarViewControllerByName:TABBAR_ROUTES];
}



#pragma mark - Share sheet



-(IBAction)shareButtonSelected:(id)sender{
	
	NSArray *activitites;
	
	
	
	if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
		
		UIActivityViewController *activity=[[UIActivityViewController alloc] initWithActivityItems:@[[NSURL URLWithString:[NSString stringWithFormat:@"cyclestreets://route/%@",_route.routeid]]] applicationActivities:nil];
		activity.excludedActivityTypes = @[UIActivityTypeSaveToCameraRoll, UIActivityTypePrint, UIActivityTypePostToWeibo];
		
		[self presentViewController:activity animated:YES completion:nil];
		[activity setCompletionHandler:^(NSString *activityType, BOOL completed){
			
			if(completed==YES){
				
				
				
			}
			
		}];
		
		
		
	}else{
		
		
		activitites=@[@(BUIconActionSheetIconTypeTwitter),@(BUIconActionSheetIconTypeMail),@(BUIconActionSheetIconTypeSMS),@(BUIconActionSheetIconTypeCopy)];
		
		BUIconActionSheet *iconSheet=[[BUIconActionSheet alloc] initWithButtons:activitites andTitle:@"Share this CycleStreets route"];
		iconSheet.delegate=self;
		
		[iconSheet show:YES];
		
		
	}
	
	
}

-(void)actionSheetClickedButtonWithType:(BUIconActionSheetIconType)type{
	
	
	switch (type) {
		case BUIconActionSheetIconTypeTwitter:
			
			if ([TWTweetComposeViewController canSendTweet]) {
				
				TWTweetComposeViewController *tweetViewController = [[TWTweetComposeViewController alloc] init];
				[tweetViewController setInitialText:[NSString stringWithFormat:@"Just planned this cycle journey on @CycleStreets: %@",_route.csBrowserRouteurlString]];
				
				//[tweetViewController addURL:[NSURL URLWithString:_route.csBrowserRouteurlString]];
				
				[self presentViewController:tweetViewController animated:YES completion:nil];
				[tweetViewController setCompletionHandler:^(SLComposeViewControllerResult result){
					
					[self dismissModalViewControllerAnimated:YES];
					
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
			[picker setSubject:[NSString stringWithFormat:@"CycleStreets route %@",_route.routeid]];
			
			NSString *body=[NSString stringWithFormat:@"%@ <br><br>%@",
							[NSString stringWithFormat:@" I've planned this cycle route on CycleStreets:<br><a href=%@>%@</a>",_route.csBrowserRouteurlString,_route.csBrowserRouteurlString],
							[NSString stringWithFormat:@"If you have an iOS device, you can open it in the CycleStreets app: <a href=%@>%@</a>",_route.csiOSRouteurlString,_route.csiOSRouteurlString]];
			
			[picker setMessageBody:body isHTML:YES];
			
			if(picker!=nil)
				[self presentModalViewController:picker animated:YES];
		}
			break;
			
		case BUIconActionSheetIconTypeSMS:
		{
			
			MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
			picker.messageComposeDelegate = self;
			picker.body=[NSString stringWithFormat:@"CycleStreets route %@",_route.csBrowserRouteurlString];
			
			if(picker!=nil)
				[self presentModalViewController:picker animated:YES];
			
		}
			
			break;
			
		case BUIconActionSheetIconTypeCopy:
		{
			[[UIPasteboard generalPasteboard] setString:_route.csBrowserRouteurlString];
		}
			
			break;
		default:
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




#pragma mark - Segues

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
	
	if([segue.identifier isEqualToString:@"RouteSegmentSegue"]){
		
		RouteSegmentViewController *controller=segue.destinationViewController;
		NSDictionary *context=segue.context;
		controller.route=context[DATAPROVIDER];
		controller.index=[context[INDEX] integerValue];
		
	}
	
	
}



//
/***********************************************
 * @description			GENERIC METHODS
 ***********************************************/
//

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
	
}




@end
