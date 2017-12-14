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
#import "ButtonUtilities.h"
#import "LayoutBox.h"
#import "RouteManager.h"

@import PureLayout;


enum  {
	CSElevationUIStateActive, 
	CSElevationUIStateInActive
};
typedef int CSElevationUIState;




#define graphHeight 80


@interface CSElevationGraphView()

@property(nonatomic,strong)  UIStackView				*inactiveView;
@property(nonatomic,strong)  UIView						*activeView;
@property(nonatomic,assign)  CSElevationUIState			uiState;


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
	
	
	
	// active UI
	
	self.activeView=[[UIView alloc]initForAutoLayout];
	[self addSubview:_activeView];
	[_activeView autoPinEdgesToSuperviewEdges];
	
	self.yAxisLabel=[[ExpandedUILabel alloc]initForAutoLayout];
	_yAxisLabel.textColor=[UIColor whiteColor];
	_yAxisLabel.font=[UIFont systemFontOfSize:13];
	_yAxisLabel.textAlignment=UITextAlignmentCenter;
	_yAxisLabel.layer.cornerRadius=4;
	_yAxisLabel.numberOfLines=1;
	_yAxisLabel.insetValue=3;
	_yAxisLabel.backgroundColor=UIColorFromRGB(0xF76117);
	_yAxisLabel.text=@"m";
	[_activeView addSubview:_yAxisLabel];
	[_yAxisLabel autoPinEdgeToSuperviewEdge:ALEdgeTop];
	[_yAxisLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft];
	[_yAxisLabel autoSetDimension:ALDimensionHeight toSize:15];
	
	
	
	self.graphView=[[CSGraphView alloc] initForAutoLayout];
	_graphView.delegate=self;
	_graphView.backgroundColor=UIColorFromRGB(0x509720);
	
	
	
	[_activeView addSubview:_graphView];
	[_graphView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_yAxisLabel withOffset:10];
	[_graphView autoPinEdgeToSuperviewEdge:ALEdgeRight];
	[_graphView autoPinEdgeToSuperviewEdge:ALEdgeLeft];
	[_graphView autoSetDimension:ALDimensionHeight toSize:graphHeight];
	
	
	self.xAxisLabel=[[ExpandedUILabel alloc]initForAutoLayout];
	_xAxisLabel.textColor=[UIColor whiteColor];
	_xAxisLabel.numberOfLines=1;
	_xAxisLabel.insetValue=3;
	_xAxisLabel.font=[UIFont systemFontOfSize:13];
	_xAxisLabel.textAlignment=NSTextAlignmentRight;
	_xAxisLabel.layer.cornerRadius=4;
	_xAxisLabel.layer.masksToBounds=YES;
	_xAxisLabel.backgroundColor=UIColorFromRGB(0xF76117);
	_xAxisLabel.text=@"km";
	[_activeView addSubview:_xAxisLabel];
	[_xAxisLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_graphView withOffset:10];
	[_xAxisLabel autoPinEdgeToSuperviewEdge:ALEdgeRight];
	[_xAxisLabel autoSetDimension:ALDimensionHeight toSize:15];
	
	
	
	self.calloutView=[[BUCalloutView alloc]initWithFrame:CGRectMake(20, 0, 80, 30)];
	_calloutView.fillColor=UIColorFromRGB(0x006EA6);
	_calloutView.cornerRadius=6;
	_calloutView.minX=0;
	_calloutView.maxX=_graphView.width;
	_calloutView.visible=NO;
	[_calloutView updateTitleLabel:@"0"];
	[_activeView addSubview:_calloutView];
	
	
	UILabel *infoLabel=[[UILabel alloc]initForAutoLayout];
	infoLabel.numberOfLines=0;
	infoLabel.textColor=[UIColor darkGrayColor];
	infoLabel.font=[UIFont systemFontOfSize:12];
	infoLabel.text=@"CycleStreets routes automatically avoid going up hills or inclines where a reasonable alternative exists.";
	[_activeView addSubview:infoLabel];
	
	[infoLabel autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, 0, 0, 0) excludingEdge:ALEdgeTop];
	
	
	// inactive UI 
	[self createInactiveView];
	

}


-(void)createInactiveView{
	
	
	self.inactiveView=[[UIStackView alloc] initForAutoLayout];
	_inactiveView.axis=BUVerticalLayoutMode;
	_inactiveView.spacing=10;
	_inactiveView.alignment=UIStackViewAlignmentCenter;
	
	UILabel *inactiveLabel=[[UILabel alloc]initForAutoLayout];
	inactiveLabel.textColor=[UIColor darkGrayColor];
	inactiveLabel.numberOfLines=0;
	inactiveLabel.font=[UIFont systemFontOfSize:14];
	inactiveLabel.text=@"There is no elevation data currently in this route, please press Update to get this data from the server.";
	[_inactiveView addArrangedSubview:inactiveLabel];
	
	UIButton *button=[ButtonUtilities UIPixateButtonWithWidth:200 height:30 styleId:@"orangeButton" text:@"Update" ];
	[button addTarget:self action:@selector(updateRoute:) forControlEvents:UIControlEventTouchUpInside];
	[_inactiveView addArrangedSubview:button];
	
	[self addSubview:_inactiveView];
	[_inactiveView autoPinEdgesToSuperviewMargins];
	
}


-(void)handleTouchInGraph:(CGPoint)point{
	
		
	if(_calloutView.isHidden==YES){
		
		_calloutView.visible=YES;
		_calloutView.alpha=0;
		
		self.touchedBlock(YES);
		
		
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
	
	self.touchedBlock(NO);
	
}


// toggle active/inactive view
// inactive view contains ui for updating route data to include elevation
-(void)updateUIState:(CSElevationUIState)state{
	
	self.uiState=state;
		
	switch (_uiState) {
		case CSElevationUIStateActive:
			_inactiveView.visible=NO;
			_activeView.visible=YES;
		break;
		case CSElevationUIStateInActive:
			_inactiveView.visible=YES;
			_activeView.visible=NO;
		break;
	}
	
	
}


-(void)update{
	
	self.graphMaskLayer = [CAShapeLayer layer];
	[_graphMaskLayer setFrame:CGRectMake(0, 0, self.width, graphHeight)];
	_graphView.layer.mask = _graphMaskLayer;
	_calloutView.maxX=_graphView.width;
	
	
	if(_dataProvider.hasElevationData==NO){
		[self updateUIState:CSElevationUIStateInActive];
		return;
	}else{
		[self updateUIState:CSElevationUIStateActive];
	}
	
	
	
	if(_elevationArray==nil)
		self.elevationArray=[NSMutableArray array];
	[_elevationArray removeAllObjects];
	
	[_graphView removeAllSubViews];
	
	UIBezierPath *path = [UIBezierPath bezierPath];
	[path moveToPoint:CGPointMake(0, _graphView.height)];
	
	// 
	int maxelevation=[_dataProvider maxElevation]; 
	int index=0;
	int xpos=0;
	float currentDistance=0;
	//
	
	
	_yAxisLabel.text=[NSString stringWithFormat:@"%i m",maxelevation];
	_xAxisLabel.text=_dataProvider.lengthString;
	//[ViewUtilities alignView:_xAxisLabel withView:self :BURightAlignMode :BUNoneAlignMode];
	
	
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
		xpos=_graphView.width*xpercent;
		
		// callout values
		float insetindex=xpercent*100.0f;
		[_elevationArray addObject:@{@"xpercent" : BOX_FLOAT(insetindex), @"yvalue" : BOX_INT(value)}];
		
		// ensures last point is max x, handles rounding errors
		if (index==_dataProvider.segments.count-1) {
			xpos=_graphView.width;
		}

		[path addLineToPoint:CGPointMake(xpos, ypos)];
			
		index++;
				
	}
	
	[path addLineToPoint:CGPointMake(_graphView.width, _graphView.height)];
	 
	self.graphPath=path;
	[_graphMaskLayer setPath:path.CGPath];
	
}



-(IBAction)updateRoute:(id)sender{
	
	BetterLog(@"");
	
	[[RouteManager sharedInstance] updateRoute:_dataProvider];
	
}


@end
