//
//  RouteCellView.h
//  CycleStreets
//
//  Created by neil on 17/03/2011.
//  Copyright 2011 CycleStreets Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SuperCellView.h"
#import "RouteVO.h"

@interface RouteCellView : SuperCellView {

	RouteVO *dataProvider;
	
}
@property (nonatomic, retain)	RouteVO	*dataProvider;

@end
