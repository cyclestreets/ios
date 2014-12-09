//
//  UserRouteCellView.h
//  CycleStreets
//
//  Created by Neil Edwards on 09/12/2014.
//  Copyright (c) 2014 CycleStreets Ltd. All rights reserved.
//

#import "BUTableCellView.h"
@class CSUserRouteVO;

@interface UserRouteCellView : BUTableCellView

@property (nonatomic,strong)  CSUserRouteVO                 *dataProvider;

@end
