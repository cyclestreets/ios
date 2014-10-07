//
//  CSSegmentFooterView.h
//  CycleStreets
//
//  Created by Neil Edwards on 23/03/2011.
//  Copyright 2011 CycleStreets Ltd. All rights reserved.
//

// readout view for RouteSegmentViewController map view (RouteSegmentViewController.h)

#import <UIKit/UIKit.h>
#import "LayoutBox.h"


@class SegmentVO,ExpandedUILabel;

@interface CSSegmentFooterView : LayoutBox {

}
@property (nonatomic, strong)	SegmentVO		*dataProvider;
@property (nonatomic, strong)	ExpandedUILabel         * segmentIndexLabel;

-(void)initialise;
-(void)updateLayout;


@end
