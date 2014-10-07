//
//  RouteCellView.h
//  CycleStreets
//
//  Created by neil on 17/03/2011.
//  Copyright 2011 CycleStreets Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BUTableCellView.h"

@class RouteVO;


@interface RouteCellView : BUTableCellView {
	
	
}
@property (nonatomic, strong)	RouteVO						*dataProvider;
@property (nonatomic)	BOOL                                isSelectedRoute;

@end
