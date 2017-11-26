//
//  ItineraryCellView.m
//  CycleStreets
//
//  Created by Neil Edwards on 09/03/2011.
//  Copyright 2011 CycleStreets Ltd. All rights reserved.
//

#import "ItineraryCellView.h"
#import "AppConstants.h"
#import "ViewUtilities.h"
#import "SegmentVO.h"
#import "LayoutBox.h"
#import "MultiLabelLine.h"
#import "ExpandedUILabel.h"
#import "CycleStreets.h"
#import "ViewUtilities.h"

@import PureLayout;

@interface ItineraryCellView()

@property (nonatomic, weak)		IBOutlet UILabel		* nameLabel;
@property (nonatomic, weak)		IBOutlet UIStackView	* labelContainer;
@property (nonatomic, weak)		IBOutlet UIImageView	* icon;

@property (nonatomic,strong)  NSMutableArray 			*fonts;
@property (nonatomic,strong)  NSMutableArray 			*colors;

@property (nonatomic,strong)  NSMutableArray			*labels;

@end


@implementation ItineraryCellView



-(void)initialise{
	
	self.fonts=[NSMutableArray arrayWithObjects:[UIFont boldSystemFontOfSize:13],[UIFont systemFontOfSize:13],[UIFont systemFontOfSize:13],nil];
	self.colors=[NSMutableArray arrayWithObjects:UIColorFromRGB(0xFF8000),UIColorFromRGB(0x007F00),UIColorFromRGB(0x404040),nil];
	

}

-(void)populate{
	
	_nameLabel.text=[_dataProvider roadName];
	
	NSMutableArray *arr=[[NSMutableArray alloc] init];
	
	[arr addObject:[_dataProvider timeString]];
	[arr addObject:[CycleStreets formattedDistanceString:[_dataProvider segmentDistance]]];
	[arr addObject:[CycleStreets formattedDistanceString:([_dataProvider startDistance]+[_dataProvider segmentDistance])]];
	
	_icon.image=[UIImage imageNamed:_dataProvider.provisionIcon];
	
	
	if(_labels==nil){
		[self createUILabels:arr];
	}
	
	for(int x=0;x<arr.count;x++){
		UILabel *label=_labels[x];
		if(label){
			label.text=arr[x];
		}
	}
	

}


-(void)createUILabels:(NSMutableArray*)arr{
	
	self.labels=[NSMutableArray array];
	
	for(int x=0;x<arr.count;x++){
		
		UILabel *label=[[UILabel alloc]initForAutoLayout];
		label.numberOfLines=0;
		label.font=_fonts[x];
		label.textColor=_colors[x];
		if (x==arr.count-1) {
			[label setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
		}else{
			[label setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
		}
		
		[_labels addObject:label];
		
		[_labelContainer addArrangedSubview:label];
	}
	
}


@end
