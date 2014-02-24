//
//  WayPointCellView.h
//  CycleStreets
//
//  Created by Neil Edwards on 05/11/2012.
//  Copyright (c) 2012 CycleStreets Ltd. All rights reserved.
//

#import "BUTableCellView.h"

@class WayPointVO;

@interface WayPointCellView : BUTableCellView

@property(nonatomic,strong)  WayPointVO				*dataProvider;
@property(nonatomic,assign)  int					waypointIndex;


// FMMoveTable support
- (void)prepareForMove;

@end
