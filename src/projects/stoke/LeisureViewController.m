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

#import <CoreLocation/CoreLocation.h>

@interface LeisureViewController ()<BUHorizontalMenuDataSource,BUHorizontalMenuDelegate>

@property (weak, nonatomic) IBOutlet UISegmentedControl		*typeControl;

@property (weak, nonatomic) IBOutlet UISlider				*unitControl;
@property (weak, nonatomic) IBOutlet UILabel				*startLabel;
@property (weak, nonatomic) IBOutlet UILabel				*endLabel;
@property (weak, nonatomic) IBOutlet UILabel				*readoutLabel;

@property (strong, nonatomic) IBOutlet BUHorizontalMenuView *waypointControl;

@property (weak, nonatomic) IBOutlet UIButton				*calculateButton;


// state
@property (nonatomic,strong) LeisureRouteVO					*dataProvider;


@end

@implementation LeisureViewController


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
	
	[self updateUIForTypeChange];
    
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


#pragma mark - UI Events


-(void)dismissView{
	
	[self dismissViewControllerAnimated:YES completion:nil];
	
}



#pragma mark - View action

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


-(IBAction)didSelectCalculateButton:(id)sender{
    
	[[RouteManager sharedInstance] loadRouteForLeisure:_dataProvider];
	
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
	
	return CGSizeMake(280,350);
}


@end
