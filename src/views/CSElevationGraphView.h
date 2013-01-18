//
//  CSElevationGraphView.h
//  CycleStreets
//
//  Created by Neil Edwards on 07/12/2012.
//  Copyright (c) 2012 CycleStreets Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RouteVO.h"
#import "CSGraphView.h"


@protocol CSElevationGraphViewDelegate <NSObject>

@optional
-(void)touchInGraph:(BOOL)touched;

@end


@interface CSElevationGraphView : UIView<CSGraphViewDelegate>

@property(nonatomic,strong)  RouteVO							*dataProvider;
@property(nonatomic,strong)  UIColor							*lineColor;
@property(nonatomic,strong)  UIColor							*fillColor;

@property (nonatomic, unsafe_unretained) id<CSElevationGraphViewDelegate>		 delegate;


-(void)update;

@end
