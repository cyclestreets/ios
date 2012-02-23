//
//  RouteCellView.h
//  CycleStreets
//
//  Created by neil on 17/03/2011.
//  Copyright 2011 CycleStreets Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MultiLabelLine.h"
#import "BUTableCellView.h"
#import "RouteVO.h"
#import "LayoutBox.h"
#import "ExpandedUILabel.h"

@interface RouteCellView : BUTableCellView {
	
	RouteVO							*dataProvider;
	
	IBOutlet	LayoutBox			*viewContainer;
	IBOutlet ExpandedUILabel		*nameLabel;
	IBOutlet MultiLabelLine			*readoutLabel;
	
	IBOutlet UIImageView			*icon;
	
	BOOL							isSelectedRoute;
	IBOutlet UIImageView						*selectedRouteIcon;
	
}
@property (nonatomic, retain)	RouteVO		*dataProvider;
@property (nonatomic, retain)	IBOutlet LayoutBox		*viewContainer;
@property (nonatomic, retain)	IBOutlet ExpandedUILabel		*nameLabel;
@property (nonatomic, retain)	IBOutlet MultiLabelLine		*readoutLabel;
@property (nonatomic, retain)	IBOutlet UIImageView		*icon;
@property (nonatomic)	BOOL		isSelectedRoute;
@property (nonatomic, retain)	IBOutlet UIImageView		*selectedRouteIcon;


+(NSNumber*)heightForCellWithDataProvider:(RouteVO*)route;
-(void)updateCellUILabels;

@end
