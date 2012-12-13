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
#import "BUCalloutView.h"

#define graphHeight 80
@interface CSElevationGraphView()

@property(nonatomic,strong)  UIView					*graphView;
@property(nonatomic,strong)  CAShapeLayer			*graphMaskLayer;
@property(nonatomic,strong)  UIBezierPath			*graphPath;

@property(nonatomic,strong)  BUCalloutView			*calloutView;


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
	
	
	self.calloutView=[[BUCalloutView alloc]initWithFrame:CGRectMake(200, 0, 80, 30)];
	_calloutView.fillColor=UIColorFromRGB(0x006EA6);
	_calloutView.cornerRadius=6;
	[_calloutView updateTitleLabel:@"25 miles"];
	[self addSubview:_calloutView];
	
	


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
	
	
	[_graphView removeAllSubViews];
	
	UIBezierPath *path = [UIBezierPath bezierPath];
	[path moveToPoint:CGPointMake(0, _graphView.height)];
	
	// temp
	int maxelevation=[_dataProvider maxElevation]; // max elevation for all segemnts
	int index=0;
	int xpos=0;
	float currentDistance=0;
	
	// startpoint
	SegmentVO *segment=_dataProvider.segments[0];
	float startpercent=(float)segment.segmentElevation/(float)maxelevation;
	startpercent=1-startpercent;
	int startypos=graphHeight*startpercent;
	[path addLineToPoint:CGPointMake(0, startypos)];
	//
	
	
	for (SegmentVO *segment in _dataProvider.segments) {
		
		// y value
		int value=segment.segmentElevation;
		float ypercent=(float)value/(float)maxelevation;
		ypercent=1-ypercent;
		int ypos=graphHeight*ypercent;
		
		// x value
		currentDistance+=[segment segmentDistance];
		float xpercent=currentDistance/[_dataProvider.length floatValue];
		xpos=UIWIDTH*xpercent;
		
		// ensures last point is max x, handles rounding errors
		if (index==_dataProvider.segments.count-1) {
			xpos=UIWIDTH;
		}
		
		BetterLog(@"point %i, ypos: %i  xpos:%i (xp: %i= %f)",index,value,xpos,[segment segmentDistance],xpercent);
		
		// debug only
		ExpandedUILabel *label=[[ExpandedUILabel alloc] initWithFrame:CGRectMake(xpos-1, ypos-1, 14,14)];
		label.backgroundColor=[UIColor clearColor];
		label.font=[UIFont systemFontOfSize:11];
		label.text=[NSString stringWithFormat:@"%i",index];
		[_graphView addSubview:label];
		//

		[path addLineToPoint:CGPointMake(xpos, ypos)];
			
		index++;
				
	}
	
	[path addLineToPoint:CGPointMake(UIWIDTH, _graphView.height)];
	 
	 
	self.graphPath=path;
	[_graphMaskLayer setPath:path.CGPath];
	
}




@end
