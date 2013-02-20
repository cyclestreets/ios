//
//  ItineraryViewController.h
//  CycleStreets
//
//  Created by Neil Edwards on 09/03/2011.
//  Copyright 2011 CycleStreets Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SuperViewController.h"
#import "RouteSegmentViewController.h"
#import "RouteSummary.h"
@class RouteVO;

@interface ItineraryViewController : SuperViewController <UITableViewDelegate,UITableViewDataSource>{
	
	RouteVO                         *route;
	NSInteger                       routeId;
	UITextView                      *headerText;
	
	RouteSegmentViewController							*routeSegmentViewcontroller;
	RouteSummary										*routeSummaryViewcontroller;
	
	
	
	IBOutlet	UITableView			*tableView;
	NSMutableArray					*rowHeightsArray;
	
	

}
@property (nonatomic, strong) RouteVO		* route;
@property (nonatomic, assign) NSInteger		 routeId;
@property (nonatomic, strong) UITextView		* headerText;
@property (nonatomic, strong) RouteSegmentViewController		* routeSegmentViewcontroller;
@property (nonatomic, strong) RouteSummary						* routeSummaryViewcontroller;


@property (nonatomic, strong) IBOutlet UITableView		* tableView;
@property (nonatomic, strong) NSMutableArray		* rowHeightsArray;

-(void)createRowHeightsArray;
-(void)showNoActiveRouteView:(BOOL)show;
@end
