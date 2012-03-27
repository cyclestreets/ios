//
//  ItineraryViewController.h
//  CycleStreets
//
//  Created by Neil Edwards on 09/03/2011.
//  Copyright 2011 CycleStreets Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SuperViewController.h"
#import "MultiLabelLine.h"
#import "LayoutBox.h"
#import "Stage.h"
#import "CopyLabel.h"
@class RouteVO;

@interface ItineraryViewController : SuperViewController <UITableViewDelegate,UITableViewDataSource>{
	
	RouteVO                         *route;
	NSInteger                       routeId;
	UITextView                      *headerText;
	
	Stage							*stageViewcontroller;
	
	
	IBOutlet	CopyLabel			*routeidLabel;
				MultiLabelLine		*readoutLineOne;
				MultiLabelLine		*readoutLineTwo;
	IBOutlet	LayoutBox			*readoutContainer;
	
	IBOutlet	UITableView			*tableView;
	NSMutableArray					*rowHeightsArray;
	
	

}
@property (nonatomic, retain)	RouteVO		*route;
@property (nonatomic)	NSInteger		routeId;
@property (nonatomic, retain)	UITextView		*headerText;
@property (nonatomic, retain)	Stage		*stageViewcontroller;
@property (nonatomic, retain)	IBOutlet CopyLabel		*routeidLabel;
@property (nonatomic, retain)	MultiLabelLine		*readoutLineOne;
@property (nonatomic, retain)	MultiLabelLine		*readoutLineTwo;
@property (nonatomic, retain)	IBOutlet LayoutBox		*readoutContainer;
@property (nonatomic, retain)	IBOutlet UITableView		*tableView;
@property (nonatomic, retain)	NSMutableArray		*rowHeightsArray;

-(void)createRowHeightsArray;
-(void)showNoActiveRouteView:(BOOL)show;
@end
