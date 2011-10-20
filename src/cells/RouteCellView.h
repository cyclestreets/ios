//
//  RouteCellView.h
//  CycleStreets
//
//  Created by neil on 17/03/2011.
//  Copyright 2011 CycleStreets Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BUTableCellView.h"
#import "RouteVO.h"

@interface RouteCellView : BUTableCellView {

	RouteVO *dataProvider;
	
}
@property (nonatomic, retain)	RouteVO	*dataProvider;

@end
