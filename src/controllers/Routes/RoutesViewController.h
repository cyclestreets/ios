//
//  RoutesViewContoller.h
//  CycleStreets
//
//  Created by Neil Edwards on 09/03/2011.
//  Copyright 2011 CycleStreets Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SuperViewController.h"
#import "BUSegmentedControl.h"
#import "BorderView.h"
#import "RouteSummary.h"

@interface RoutesViewController : SuperViewController <BUSegmentedControlDelegate>{
	
	IBOutlet		UIView				*titleHeaderView;
	IBOutlet		BorderView			*controlView;
	BUSegmentedControl					*routeTypeControl;
    IBOutlet        UIButton            *selectedRouteButton;
	
	NSMutableArray						*subViewsArray;
	NSMutableArray						*classArray;
	NSMutableArray						*nibArray;
	NSMutableArray						*dataTypeArray;
	UIView								*contentView;
	int									activeIndex;
    
    RouteSummary                        *routeSummary;


}
@property (nonatomic, retain)	IBOutlet UIView			*titleHeaderView;
@property (nonatomic, retain)	IBOutlet BorderView			*controlView;
@property (nonatomic, retain)	BUSegmentedControl			*routeTypeControl;
@property (nonatomic, retain)	IBOutlet UIButton			*selectedRouteButton;
@property (nonatomic, retain)	NSMutableArray			*subViewsArray;
@property (nonatomic, retain)	NSMutableArray			*classArray;
@property (nonatomic, retain)	NSMutableArray			*nibArray;
@property (nonatomic, retain)	NSMutableArray			*dataTypeArray;
@property (nonatomic, retain)	IBOutlet UIView			*contentView;
@property (nonatomic, assign)	int			activeIndex;
@property (nonatomic, retain)	RouteSummary			*routeSummary;

@end
