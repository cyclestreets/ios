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
#import "RouteSegmentViewController.h"
#import "CopyLabel.h"


@interface ItineraryViewController : SuperViewController <UITableViewDelegate,UITableViewDataSource>{
	
	
}


-(void)createRowHeightsArray;
-(void)showNoActiveRouteView:(BOOL)show;
@end
