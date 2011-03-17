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
@class Route;

@interface ItineraryViewController : SuperViewController <UITableViewDelegate,UITableViewDataSource>{
	
	Route *route;
	NSInteger routeId;
	UITextView *headerText;
	
	
	IBOutlet	UILabel				*routeidLabel;
	IBOutlet	MultiLabelLine		*readoutLineOne;
	IBOutlet	MultiLabelLine		*readoutLineTwo;
	IBOutlet	LayoutBox			*readoutContainer;
	
	IBOutlet	UITableView			*tableView;

}
@property (nonatomic, retain)	Route	*route;
@property (nonatomic, assign)	NSInteger	routeId;
@property (nonatomic, retain)	IBOutlet UITextView	*headerText;
@property (nonatomic, retain)	IBOutlet UILabel	*routeidLabel;
@property (nonatomic, retain)	IBOutlet MultiLabelLine	*readoutLineOne;
@property (nonatomic, retain)	IBOutlet MultiLabelLine	*readoutLineTwo;
@property (nonatomic, retain)	IBOutlet LayoutBox	*readoutContainer;
@property (nonatomic, retain)	IBOutlet UITableView	*tableView;

@end
