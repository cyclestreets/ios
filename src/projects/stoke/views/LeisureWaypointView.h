//
//  LeisureWaypointView.h
//  CycleStreets
//
//  Created by Neil Edwards on 27/10/2014.
//  Copyright (c) 2014 CycleStreets Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GenericConstants.h"
#import "BUHorizontalMenuView.h"

@class WayPointVO;

@interface LeisureWaypointView : UIView<BUHorizontalMenuItem>

@property (nonatomic,strong)  WayPointVO						*dataProvider;


@property (nonatomic,copy)  GenericEventBlock                   touchBlock;


-(void)setSelected:(BOOL)selected;

-(void)populate;

@end
