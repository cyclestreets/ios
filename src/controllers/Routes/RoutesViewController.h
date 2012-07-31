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
@property (nonatomic, strong)	IBOutlet UIView			*titleHeaderView;
@property (nonatomic, strong)	IBOutlet BorderView			*controlView;
@property (nonatomic, strong)	BUSegmentedControl			*routeTypeControl;
@property (nonatomic, strong)	IBOutlet UIButton			*selectedRouteButton;
@property (nonatomic, strong)	NSMutableArray			*subViewsArray;
@property (nonatomic, strong)	NSMutableArray			*classArray;
@property (nonatomic, strong)	NSMutableArray			*nibArray;
@property (nonatomic, strong)	NSMutableArray			*dataTypeArray;
@property (nonatomic, strong)	IBOutlet UIView			*contentView;
@property (nonatomic, assign)	int			activeIndex;
@property (nonatomic, strong)	RouteSummary			*routeSummary;

@end
