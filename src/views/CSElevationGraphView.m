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

@property(nonatomic,strong)  UIView					*calloutView;


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
	
	
	// this should be separate uiview
	
	self.calloutView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 80, 30)];
	_calloutView.backgroundColor=UIColorFromRGB(0xFF0000);
	UIBezierPath *cpath=[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 80, 20) cornerRadius:6];
	UIBezierPath *tpath=[UIBezierPath bezierPath];
	[tpath moveToPoint:CGPointMake(35, 20)];
	[tpath addLineToPoint:CGPointMake(45, 20)];
	[tpath addLineToPoint:CGPointMake(40, 30)];
	
	[cpath appendPath:tpath];
	
	CAShapeLayer *sl= [CAShapeLayer layer];
	[sl setFrame:CGRectMake(0, 0, _calloutView.width, _calloutView.height)];
	_calloutView.layer.mask = sl;
	[sl setPath:cpath.CGPath];
	[self addSubview:_calloutView];
	
	//
	UIView *gradiantlayer=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 80, 30)];
	gradiantlayer.layer.shadowColor = [UIColor blackColor].CGColor;
	gradiantlayer.layer.shadowOpacity = 0.5f;
	gradiantlayer.layer.shadowOffset = CGSizeMake(5, 6.0f);
	gradiantlayer.layer.shadowRadius = 5.0f;
	gradiantlayer.layer.shadowPath = cpath.CGPath;
	gradiantlayer.layer.masksToBounds = NO;
	[_calloutView.layer insertSublayer:gradiantlayer.layer atIndex:0];
	


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
	
	int elevationcount=_dataProvider.segments.count; // will be count of elevation points for route
	int minelevation=0;
	int maxelevation=[_dataProvider maxElevation]; // max elevation for all segemnts
	
	
	// TODO: cant exceed uiwidth value for number of points
	// TODO: should be max value from each segment maybe
	// this can be wrong if count>280, graph will extend beyond extents at a min of 1px
	int xincrement=MAX(UIWIDTH,elevationcount)/elevationcount;
	
	
	
	[path addLineToPoint:CGPointMake(0, minelevation)];
	int index=0;
	for (SegmentVO *segment in _dataProvider.segments) {
		
		int value=segment.segmentElevation;
		
		float percent=(float)value/(float)maxelevation;
		value=graphHeight*percent;
			
		int xpos=ceil(index*xincrement);
		if (index==_dataProvider.segments.count-1) {
			xpos=UIWIDTH;
		}
		[path addLineToPoint:CGPointMake(xpos, value)];
			
		index++;
				
	}
	[path addLineToPoint:CGPointMake(UIWIDTH, _graphView.height)];
	
	self.graphPath=path;
	
	[_graphMaskLayer setPath:path.CGPath];
	
}




@end
