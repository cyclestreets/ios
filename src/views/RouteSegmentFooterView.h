//
//  RouteSegmentFooterView.h
//  CycleStreets
//
//  Created by Neil Edwards on 24/11/2017.
//  Copyright © 2017 CycleStreets Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SegmentVO;

@interface RouteSegmentFooterView : UIView

@property (nonatomic, strong)	SegmentVO		*dataProvider;

-(void)initialise;
-(void)updateLayout;

@end
