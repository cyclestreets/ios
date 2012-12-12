//
//  CSElevationGraphView.m
//  CycleStreets
//
//  Created by Neil Edwards on 07/12/2012.
//  Copyright (c) 2012 CycleStreets Ltd. All rights reserved.
//

#import "CSElevationGraphView.h"
#import "CSPointVO.h"
#import "UIView+Additions.h"
#import <QuartzCore/QuartzCore.h>
#import "GlobalUtilities.h"

@interface CSElevationGraphView()

@property(nonatomic,strong)  UIView					*graphView;
@property(nonatomic,strong)  CAShapeLayer			*graphMaskLayer;


@end

@implementation CSElevationGraphView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialise];
    }
    return self;
}

-(void)initialise{
	
	
	self.graphView=[[UIView alloc] initWithFrame:CGRectMake(20, 0, UIWIDTH, 100)];
	_graphView.backgroundColor=UIColorFromRGB(0x509720);
	
	self.graphMaskLayer = [CAShapeLayer layer];
	[_graphMaskLayer setFrame:CGRectMake(0, 0, UIWIDTH, 100)];
	_graphView.layer.mask = _graphMaskLayer;
	
	[self addSubview:_graphView];
	
}


-(void)update{
	
	
	// update labels
	
	// calculate points
	
	UIBezierPath *path = [UIBezierPath bezierPath];
	
	[path moveToPoint:CGPointMake(0, _graphView.height)];
	[path addLineToPoint:CGPointMake(0, 0)];
	[path addLineToPoint:CGPointMake(80, 40)];
	[path addLineToPoint:CGPointMake(170, 65)];
	[path addLineToPoint:CGPointMake(200, 40)];
	[path addLineToPoint:CGPointMake(240, 20)];
	[path addLineToPoint:CGPointMake(UIWIDTH, 90)];
	[path addLineToPoint:CGPointMake(UIWIDTH, _graphView.height)];
	
	[_graphMaskLayer setPath:path.CGPath];
	
}




@end
