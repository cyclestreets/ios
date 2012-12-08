//
//  ItineraryInfoContainer.m
//  CycleStreets
//
//  Created by Neil Edwards on 07/12/2012.
//  Copyright (c) 2012 CycleStreets Ltd. All rights reserved.
//

#import "ItineraryInfoContainer.h"
#import "MultiLabelLine.h"
#import "ExpandedUILabel.h"

@interface ItineraryInfoContainer()

@property (nonatomic, strong) MultiLabelLine		* readoutLineOne;
@property (nonatomic, strong) MultiLabelLine		* readoutLineTwo;
@property (nonatomic, strong) MultiLabelLine		* readoutLineThree;

@end

@implementation ItineraryInfoContainer

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialise];
    }
    return self;
}


-(void)initialise{
	
	self.paddingTop=5;
	self.itemPadding=4;
	self.layoutMode=BUVerticalLayoutMode;
	self.alignMode=BUCenterAlignMode;
	self.fixedWidth=YES;
	self.fixedHeight=YES;
	self.backgroundColor=UIColorFromRGB(0xE5E5E5);
	
	
	self.readoutLineOne=[[MultiLabelLine alloc]initWithFrame:CGRectMake(0, 0, UIWIDTH, 15)];
	_readoutLineOne.showShadow=YES;
	_readoutLineOne.colors=[NSArray arrayWithObjects:UIColorFromRGB(0x804000),UIColorFromRGB(0x000000),UIColorFromRGB(0x804000),UIColorFromRGB(0x000000),nil];
	_readoutLineOne.fonts=[NSArray arrayWithObjects:[UIFont boldSystemFontOfSize:13],[UIFont systemFontOfSize:13],[UIFont boldSystemFontOfSize:13],[UIFont systemFontOfSize:13],nil];
	
	self.readoutLineTwo=[[MultiLabelLine alloc]initWithFrame:CGRectMake(0, 0, UIWIDTH, 15)];
	_readoutLineTwo.showShadow=YES;
	_readoutLineTwo.colors=[NSArray arrayWithObjects:UIColorFromRGB(0x804000),UIColorFromRGB(0x000000),UIColorFromRGB(0x804000),UIColorFromRGB(0x000000),nil];
	_readoutLineTwo.fonts=[NSArray arrayWithObjects:[UIFont boldSystemFontOfSize:13],[UIFont systemFontOfSize:13],[UIFont boldSystemFontOfSize:13],[UIFont systemFontOfSize:13],nil];
	
	self.readoutLineThree=[[MultiLabelLine alloc]initWithFrame:CGRectMake(0, 0, UIWIDTH, 15)];
	_readoutLineThree.showShadow=YES;
	_readoutLineThree.colors=[NSArray arrayWithObjects:UIColorFromRGB(0x804000),UIColorFromRGB(0x000000),UIColorFromRGB(0x804000),UIColorFromRGB(0x000000),nil];
	_readoutLineThree.fonts=[NSArray arrayWithObjects:[UIFont boldSystemFontOfSize:13],[UIFont systemFontOfSize:13],[UIFont boldSystemFontOfSize:13],[UIFont systemFontOfSize:13],nil];
	
	
	ExpandedUILabel *readoutlabel=[[ExpandedUILabel alloc] initWithFrame:CGRectMake(0, 0, UIWIDTH, 10)];
	readoutlabel.font=[UIFont systemFontOfSize:12];
	readoutlabel.textColor=UIColorFromRGB(0x666666);
	readoutlabel.shadowColor=[UIColor whiteColor];
	readoutlabel.shadowOffset=CGSizeMake(0, 1);
	readoutlabel.text=@"Select any segment to view the map & details for it.";
	
	
	[self addSubViewsFromArray:[NSArray arrayWithObjects:_readoutLineOne,_readoutLineTwo,_readoutLineThree,readoutlabel, nil]];
	
	
}


-(void)layoutSubviews{
		
	_readoutLineOne.labels=[NSArray arrayWithObjects:@"Length:",_dataProvider.lengthString,
						   @"Estimated time:",_dataProvider.timeString,nil];
	[_readoutLineOne drawUI];
	
	_readoutLineTwo.labels=[NSArray arrayWithObjects:@"Planned speed:",_dataProvider.speedString,
						   @"Strategy:",_dataProvider.planString,nil];
	[_readoutLineTwo drawUI];
	
	_readoutLineThree.labels=[NSArray arrayWithObjects:@"Calories:",_dataProvider.calorieString,
							 @"CO2 saved:",_dataProvider.coString,nil];
	[_readoutLineThree drawUI];
	
	[self refresh];
	
}


@end
