//
//  CSElevationGraphView.h
//  CycleStreets
//
//  Created by Neil Edwards on 07/12/2012.
//  Copyright (c) 2012 CycleStreets Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RouteVO.h"

@interface CSElevationGraphView : UIView

@property(nonatomic,strong)  RouteVO							*dataProvider;
@property(nonatomic,strong)  UIColor							*lineColor;
@property(nonatomic,strong)  UIColor							*fillColor;


-(void)update;

@end
