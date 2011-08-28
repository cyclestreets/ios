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

@interface RoutesViewContoller : SuperViewController <BUSegmentedControlDelegate>{
	
	IBOutlet		UIView				*titleHeaderView;
	IBOutlet		BorderView			*controlView;
	BUSegmentedControl					*routeTypeControl;
	
	NSMutableArray						*subViewsArray;
	NSMutableArray						*classArray;
	NSMutableArray						*nibArray;
	NSMutableArray						*dataTypeArray;
	UIView								*contentView;
	int									activeIndex;

}
@property (nonatomic, retain)		IBOutlet UIView		* titleHeaderView;
@property (nonatomic, retain)		IBOutlet BorderView		* controlView;
@property (nonatomic, retain)		BUSegmentedControl		* routeTypeControl;
@property (nonatomic, retain)		NSMutableArray		* subViewsArray;
@property (nonatomic, retain)		NSMutableArray		* classArray;
@property (nonatomic, retain)		NSMutableArray		* nibArray;
@property (nonatomic, retain)		NSMutableArray		* dataTypeArray;
@property (nonatomic, retain)		IBOutlet UIView		* contentView;
@property (nonatomic)		int		 activeIndex;

@end
