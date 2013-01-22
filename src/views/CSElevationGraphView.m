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

@property(nonatomic,strong)  CSGraphView				*graphView;
@property(nonatomic,strong)  CAShapeLayer				*graphMaskLayer;
@property(nonatomic,strong)  UIBezierPath				*graphPath;

@property(nonatomic,strong)  ExpandedUILabel			*yAxisLabel;
@property(nonatomic,strong)  ExpandedUILabel			*xAxisLabel;


@property(nonatomic,strong)  BUCalloutView				*calloutView;

@property(nonatomic,strong)  NSMutableArray				*elevationArray;


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
	
	self.yAxisLabel=[[ExpandedUILabel alloc]initWithFrame:CGRectMake(0, 0, 25, 15)];
	_yAxisLabel.textColor=[UIColor whiteColor];
	_yAxisLabel.font=[UIFont systemFontOfSize:13];
	_yAxisLabel.textAlignment=UITextAlignmentCenter;
	_yAxisLabel.layer.cornerRadius=4;
	_yAxisLabel.multiline=NO;
	_yAxisLabel.insetValue=3;
	_yAxisLabel.backgroundColor=UIColorFromRGB(0xF76117);
	_yAxisLabel.text=@"m";
	[self addSubview:_yAxisLabel];
	
	self.xAxisLabel=[[ExpandedUILabel alloc]initWithFrame:CGRectMake(20, graphHeight+25, 25, 15)];
	_xAxisLabel.textColor=[UIColor whiteColor];
	_xAxisLabel.multiline=NO;
	_xAxisLabel.insetValue=3;
	_xAxisLabel.font=[UIFont systemFontOfSize:13];
	_xAxisLabel.textAlignment=UITextAlignmentCenter;
	_xAxisLabel.layer.cornerRadius=4;
	_xAxisLabel.backgroundColor=UIColorFromRGB(0xF76117);
	_xAxisLabel.text=@"km";
	[self addSubview:_xAxisLabel];
	
	[ViewUtilities alignView:_xAxisLabel withView:self :BURightAlignMode :BUNoneAlignMode];
	
	
	
	self.graphView=[[CSGraphView alloc] initWithFrame:CGRectMake(0, 20, UIWIDTH, graphHeight)];
	_graphView.delegate=self;
	_graphView.backgroundColor=UIColorFromRGB(0x509720);
	
	self.graphMaskLayer = [CAShapeLayer layer];
	[_graphMaskLayer setFrame:CGRectMake(0, 0, UIWIDTH, graphHeight)];
	_graphView.layer.mask = _graphMaskLayer;
	
	[self addSubview:_graphView];
	
	
	self.calloutView=[[BUCalloutView alloc]initWithFrame:CGRectMake(20, 0, 80, 30)];
	_calloutView.fillColor=UIColorFromRGB(0x006EA6);
	_calloutView.cornerRadius=6;
	_calloutView.minX=0;
	_calloutView.maxX=_graphView.width;
	_calloutView.visible=NO;
	[_calloutView updateTitleLabel:@"0"];
	[self addSubview:_calloutView];
	
	
	ExpandedUILabel *infoLabel=[[ExpandedUILabel alloc]initWithFrame:CGRectMake(0, self.height, UIWIDTH, 15)];
	infoLabel.fixedWidth=YES;
	infoLabel.textColor=[UIColor darkGrayColor];
	infoLabel.multiline=YES;
	infoLabel.font=[UIFont systemFontOfSize:12];
	infoLabel.text=@"CycleStreets routes automatically avoid going up hills or inclines where a reasonable alternative exists.";
	[self addSubview:infoLabel];
	
	[ViewUtilities alignView:infoLabel withView:self :BUNoneAlignMode :BUBottomAlignMode];

}


-(void)handleTouchInGraph:(CGPoint)point{
	
		
	if(_calloutView.isHidden==YES){
		
		_calloutView.visible=YES;
		_calloutView.alpha=0;
		
		[self.delegate touchInGraph:YES];
		
		[UIView animateWithDuration:0.3 animations:^{
			_calloutView.alpha=1;
		} completion:^(BOOL finished) {
			
		}];
	}
	
	float xpos=point.x;
	float xpercent=MAX(MIN((float)xpos/(float)_graphView.width,1),0);
	int yvalue=[self findyValueForxPercent:(xpercent*100)];
	
	[_calloutView updateTitleLabel:[NSString stringWithFormat:@"%im %@",yvalue,[_dataProvider lengthPercentStringForPercent:xpercent]]];
	
	float calloutxpos=(_graphView.x+xpos);
	[_calloutView updatePosition:CGPointMake(calloutxpos, _calloutView.y)];
	
}



-(int)findyValueForxPercent:(float)xpercent{
	
	for( int i=0;i<_elevationArray.count;i++ ){
		
		NSDictionary *dict=_elevationArray[i];
		
		float xvalue=[dict[@"xpercent"] floatValue];
		
		if(xpercent>xvalue){
			
			int index=i+1;
			
			if(index==_elevationArray.count){
				
				NSDictionary *ydict=_elevationArray[index-1];
				return [ydict[@"yvalue"] intValue];
			}
			
			NSDictionary *nextdict=_elevationArray[index];
			float nextxvalue=[nextdict[@"xpercent"] floatValue];
			
			if(nextxvalue>xpercent){
				return [dict[@"yvalue"] intValue];
			}
			
		}else{
			
			NSDictionary *ydict=_elevationArray[0];
			return [ydict[@"yvalue"] intValue];
			
			
		}
		
	}
	
	return 0;
}


-(void)cancelTouchInGraph{
	
	if(_calloutView.isHidden==NO){
		
		[UIView animateWithDuration:0.3 animations:^{
			_calloutView.alpha=0;
		} completion:^(BOOL finished) {
			_calloutView.visible=NO;
			
		}];
		
	}
	
	[self.delegate touchInGraph:NO];
	
}



-(void)update{
	
	if(_elevationArray==nil)
		self.elevationArray=[NSMutableArray array];
	[_elevationArray removeAllObjects];
	
	
	[_graphView removeAllSubViews];
	
	UIBezierPath *path = [UIBezierPath bezierPath];
	[path moveToPoint:CGPointMake(0, _graphView.height)];
	
	// temp
	int maxelevation=[_dataProvider maxElevation]; // max elevation for all segemnts
	int index=0;
	int xpos=0;
	float currentDistance=0;
	
	
	_yAxisLabel.text=[NSString stringWithFormat:@"%i m",maxelevation];
	_xAxisLabel.text=_dataProvider.lengthString;
	[ViewUtilities alignView:_xAxisLabel withView:self :BURightAlignMode :BUNoneAlignMode];
	
	// startpoint
	SegmentVO *segment=_dataProvider.segments[0];
	float startpercent=(float)segment.segmentElevation/(float)maxelevation;
	startpercent=1-startpercent;
	int startypos=graphHeight*startpercent;
	[path addLineToPoint:CGPointMake(0, startypos)];
	//
	
	
	// ideal form is method to reduce >280 data sets to 280 across all segments
	// less than 280 can be used as is with per segment distance increment
	
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
		
		// callout values
		float insetindex=xpercent*100.0f;
		[_elevationArray addObject:@{@"xpercent" : BOX_FLOAT(insetindex), @"yvalue" : BOX_INT(value)}];
		
		// ensures last point is max x, handles rounding errors
		if (index==_dataProvider.segments.count-1) {
			xpos=UIWIDTH;
		}
		
		BetterLog(@"point %i, ypos: %i  xpos:%i (xp: %i= %f)",index,ypos,xpos,[segment segmentDistance],xpercent);
		
		// debug only
		
		/*
		ExpandedUILabel *label=[[ExpandedUILabel alloc] initWithFrame:CGRectMake(xpos-1, ypos-1, 14,14)];
		label.backgroundColor=[UIColor clearColor];
		label.font=[UIFont systemFontOfSize:11];
		label.text=[NSString stringWithFormat:@"%i",index];
		[_graphView addSubview:label];
		 */
		 
		//

		[path addLineToPoint:CGPointMake(xpos, ypos)];
			
		index++;
				
	}
	
	[path addLineToPoint:CGPointMake(UIWIDTH, _graphView.height)];
	
	BetterLog(@"%@",_elevationArray);

	 
	self.graphPath=path;
	[_graphMaskLayer setPath:path.CGPath];
	
}




@end
