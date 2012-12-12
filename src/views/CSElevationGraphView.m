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
#import "ViewUtilities.h"
#import "ExpandedUILabel.h"
#import "SegmentVO.h"

#define graphHeight 80
@interface CSElevationGraphView()

@property(nonatomic,strong)  UIView					*graphView;
@property(nonatomic,strong)  CAShapeLayer			*graphMaskLayer;
@property(nonatomic,strong)  UIBezierPath			*graphPath;


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
	
	ExpandedUILabel *ylabel=[[ExpandedUILabel alloc]initWithFrame:CGRectMake(0, 0, 25, 15)];
	ylabel.textColor=[UIColor whiteColor];
	ylabel.font=[UIFont systemFontOfSize:13];
	ylabel.textAlignment=UITextAlignmentCenter;
	ylabel.layer.cornerRadius=4;
	ylabel.backgroundColor=UIColorFromRGB(0xF76117);
	ylabel.text=@"m";
	[self addSubview:ylabel];
	
	ExpandedUILabel *xlabel=[[ExpandedUILabel alloc]initWithFrame:CGRectMake(20, self.height, 25, 15)];
	xlabel.textColor=[UIColor whiteColor];
	xlabel.font=[UIFont systemFontOfSize:13];
	xlabel.textAlignment=UITextAlignmentCenter;
	xlabel.layer.cornerRadius=4;
	xlabel.backgroundColor=UIColorFromRGB(0xF76117);
	xlabel.text=@"km";
	[self addSubview:xlabel];
	
	[ViewUtilities alignView:xlabel withView:self :BURightAlignMode :BUBottomAlignMode];
	
	
	self.graphView=[[UIView alloc] initWithFrame:CGRectMake(0, 20, UIWIDTH, graphHeight)];
	_graphView.backgroundColor=UIColorFromRGB(0x509720);
	
	self.graphMaskLayer = [CAShapeLayer layer];
	[_graphMaskLayer setFrame:CGRectMake(0, 0, UIWIDTH, graphHeight)];
	_graphView.layer.mask = _graphMaskLayer;
	
	[self addSubview:_graphView];
	
	UITapGestureRecognizer *singleFingerTap =
	[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
	[_graphView addGestureRecognizer:singleFingerTap];
	
	
	
	// draw callout base
	
}


//The event handling method
- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
	
	CGPoint location = [recognizer locationInView:recognizer.view];
	
	if ([_graphPath containsPoint:location]) {
		NSLog(@"hit");
		
		// update callout values
		
		// posiiton callout
		
	}
	
}


-(void)update{
	
	
	// update labels for distance properties
	
	// calculate points based on segments
	// will be percent of high/low point for graphHeight
	
	UIBezierPath *path = [UIBezierPath bezierPath];
	
	[path moveToPoint:CGPointMake(0, _graphView.height)];
	
	int elevationcount=_dataProvider.elevationsCount; // will be count of elevation points for route
	int minelevation=0;
	int maxelevation=[_dataProvider maxElevation]; // max elevation for all segemnts
	
	
	// TODO: cant exceed uiwidth value for number of points
	// TODO: should be max value from each segment maybe
	// this can be wrong if count>280, graph will extend beyond extents at a min of 1px
	int xincrement=MAX(UIWIDTH,elevationcount)/elevationcount;
	
	
	
	[path addLineToPoint:CGPointMake(0, minelevation)];
	int index=0;
	for (SegmentVO *segment in _dataProvider.segments) {
		
		for(NSString *strvalue in segment.segmentElevations){
			
			int value=[strvalue intValue];
			
			float percent=(float)value/(float)maxelevation;
			value=graphHeight*percent;
			
			[path addLineToPoint:CGPointMake(index*xincrement, value)];
			
			index++;
		}
		
				
	}
	[path addLineToPoint:CGPointMake(UIWIDTH, _graphView.height)];
	
	/*
	[path addLineToPoint:CGPointMake(80, 40)];
	[path addLineToPoint:CGPointMake(170, 65)];
	[path addLineToPoint:CGPointMake(200, 40)];
	[path addLineToPoint:CGPointMake(240, 30)];
	[path addLineToPoint:CGPointMake(UIWIDTH, 60)];
	*/
	
	self.graphPath=path;
	
	[_graphMaskLayer setPath:path.CGPath];
	
}




@end
