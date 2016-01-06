//
//  LeisureViewController.m
//  CycleStreets
//
//  Created by Neil Edwards on 26/10/2014.
//  Copyright (c) 2014 CycleStreets Ltd. All rights reserved.
//

#import "LeisureViewController.h"
#import "RouteManager.h"
#import "LeisureRouteVO.h"
#import "WayPointVO.h"

#import "ViewUtilities.h"
#import "BUHorizontalMenuView.h"
#import "LeisureWaypointView.h"

#import "CSOverlayPushTransitionAnimator.h"
#import "POIListviewController.h"

#import <CoreLocation/CoreLocation.h>

@interface LeisureViewController ()<BUHorizontalMenuDataSource,BUHorizontalMenuDelegate,UIViewControllerTransitioningDelegate,CSOverlayPushTransitionAnimatorProtocol,POIListViewDelegate>

@property (weak, nonatomic) IBOutlet UISegmentedControl		*typeControl;

@property (weak, nonatomic) IBOutlet UISlider				*unitControl;
@property (weak, nonatomic) IBOutlet UILabel				*startLabel;
@property (weak, nonatomic) IBOutlet UILabel				*endLabel;
@property (weak, nonatomic) IBOutlet UILabel				*readoutLabel;
@property (weak, nonatomic) IBOutlet UILabel				*poiReadoutLabel;

@property (weak, nonatomic) IBOutlet BUHorizontalMenuView	*waypointControl;
@property (weak, nonatomic) IBOutlet UIButton				*calculateButton;


@property (nonatomic,strong)  NSString						*name;

// state
@property (nonatomic,strong) LeisureRouteVO					*dataProvider;


@end

@implementation LeisureViewController


//
/***********************************************
 * @description		NOTIFICATIONS
 ***********************************************/
//

-(void)listNotificationInterests{
	
	[self initialise];
	
	[self.notifications addObject: LEISUREROUTERESPONSE];
	
	
	[super listNotificationInterests];
	
}

-(void)didReceiveNotification:(NSNotification*)notification{
	
	NSString *name=notification.name;
	
	if([name isEqualToString:LEISUREROUTERESPONSE]){
		[self didDismissWithTouch:nil];
	}
	
}



#pragma mark UIView

- (void)viewDidLoad{
    
    [super viewDidLoad];
    
    [self createPersistentUI];
}

-(void)createPersistentUI{
	
	NSArray *typeArr=[LeisureRouteVO routeTypesStrings];
	[_typeControl removeAllSegments];
	[typeArr enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
		[_typeControl insertSegmentWithTitle:obj atIndex:idx animated:NO];
	}];
	_typeControl.selectedSegmentIndex=0;

}


-(void)viewWillAppear:(BOOL)animated{
    
    [self createNonPersistentUI];
    
    [super viewWillAppear:animated];
}


-(void)createNonPersistentUI{
    
	self.dataProvider=[[LeisureRouteVO alloc]init];
	
	_waypointControl.shouldScrollToSelectedItem=NO;
	[_waypointControl reloadData];
	[_waypointControl setSelectedIndex:0 animated:NO];
	
	_dataProvider.routeValue=_unitControl.value;
	
	[self updateUIForTypeChange];
	
	[self horizMenu:_waypointControl itemSelectedAtIndex:0];
    
}


-(void)updateUIForTypeChange{
	
	NSArray *typeRangeArray=[LeisureRouteVO typeRangeArrayForRouteType:_dataProvider.routeType];
	_startLabel.text=[NSString stringWithFormat:@"%@",typeRangeArray[0]];
	_endLabel.text=[NSString stringWithFormat:@"%@",typeRangeArray[1]];
	
	[self updateUIForUnitChange];
	
}

-(void)updateUIForUnitChange{
	
	_readoutLabel.text=[_dataProvider readoutString];
	
}


#pragma mark - unit UI

-(IBAction)didChangeTypeControl:(id)sender{
	
	[_dataProvider changeRouteType:_typeControl.selectedSegmentIndex];
	
	[self updateUIForTypeChange];
	
}



#pragma mark - Slider UI

-(IBAction)didUpdateValueSlider:(id)sender{
	
	_dataProvider.routeValue=_unitControl.value;
    
	[self updateUIForUnitChange];
	
}


#pragma mark - POI UI

-(void)updatePOIUI{
	
	if(_dataProvider.poiArray.count==0){
		
		_poiReadoutLabel.text=@"none selected";
		
	}else{
		
		_poiReadoutLabel.text=[NSString stringWithFormat:@"%lu selected",(unsigned long)_dataProvider.poiArray.count];
	}
	
	
}



#pragma mark - UI Events


-(void)dismissView{
	
	[self dismissViewControllerAnimated:YES completion:nil];
	
}



#pragma mark - validation

-(void)validate{
    
	BOOL isValid=[self isValid];
	
	_calculateButton.enabled=isValid;
}


-(BOOL)isValid{
	
	BOOL valid=YES;
	
	if(!_dataProvider.isValid)
		valid=NO;
	
	return valid;
	
}



#pragma mark - UI events

-(IBAction)didSelectCancelButton:(id)sender{
	
	[self dismissView];
}

-(IBAction)didSelectCalculateButton:(id)sender{
    
	[[RouteManager sharedInstance] loadRouteForLeisure:_dataProvider];
	
}

-(IBAction)didPOIButton:(id)sender{
	
	[self performSegueWithIdentifier:@"LeisurePOI_Segue" sender:self];
	
}



#pragma mark - POIListViewDelegate

-(void)didUpdateSelectedPOIs:(NSMutableArray*)poiArray{
	
	_dataProvider.poiArray=poiArray;
	
	[self updatePOIUI];
}





-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
	
	if([segue.identifier isEqualToString:@"LeisurePOI_Segue"]){
		
		POIListviewController *controller=(POIListviewController*)segue.destinationViewController;
		
		controller.viewMode=POIListViewMode_Leisure;
		controller.delegate=self;
		controller.selectedPOIArray=_dataProvider.poiArray;
		
		controller.transitioningDelegate = self;
		controller.modalPresentationStyle = UIModalPresentationCustom;
		
	}
	
}

#pragma mark - UIViewControllerTransitioningDelegate Methods

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
																  presentingController:(UIViewController *)presenting
																	  sourceController:(UIViewController *)source {
	
	CSOverlayPushTransitionAnimator *animator = [CSOverlayPushTransitionAnimator new];
	animator.presenting = YES;
	return animator;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
	CSOverlayPushTransitionAnimator *animator = [CSOverlayPushTransitionAnimator new];
	return animator;
}



#pragma mark - BUHorizontalmenu delegate


- (NSInteger) numberOfItemsForMenu:(BUHorizontalMenuView*) menuView{
	return _waypointArray.count;
}


-(UIView<BUHorizontalMenuItem>*)menuViewItemForIndex:(NSInteger)index{
	
	LeisureWaypointView *itemView=[ViewUtilities loadInstanceOfView:[LeisureWaypointView class] fromNibNamed:@"LeisureWaypointView"];
	
	WayPointVO *dp=_waypointArray[index];
	
	itemView.dataProvider=dp;
	
	[itemView populate];
	
	return itemView;
	
}


- (void)horizMenu:(BUHorizontalMenuView*) menuView itemSelectedAtIndex:(NSInteger) index{
	
	WayPointVO *dp=_waypointArray[index];
	
	_dataProvider.routeCoordinate=dp.coordinate;
	
	[self validate];
}



#pragma mark - CSOverlayTransitionProtocol

-(void)didDismissWithTouch:(UIGestureRecognizer*)gestureRecogniser{
	
	[self dismissView];
	
}

-(CGSize)preferredContentSize{
	
	return CGSizeMake(280,400);
}

-(CGRect)presentationContentFrame{
	
	return self.view.superview.frame;
}


@end
