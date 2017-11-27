//
//  RouteSegmentFooterView.m
//  CycleStreets
//
//  Created by Neil Edwards on 24/11/2017.
//  Copyright © 2017 CycleStreets Ltd. All rights reserved.
//

#import "RouteSegmentFooterView.h"
#import "AppConstants.h"
#import "GlobalUtilities.h"
#import "SegmentVO.h"

@import PureLayout;


static NSDictionary *segmentDirectionsIcons;


@interface RouteSegmentFooterView()

@property (nonatomic)	BOOL                            hasCapitalizedTurn;

@property (nonatomic,strong)  NSMutableArray 			*fonts;
@property (nonatomic,strong)  NSMutableArray 			*colors;
@property (nonatomic,strong)  NSMutableArray			*labels;



@property(nonatomic,strong) IBOutlet UILabel		*segmentDescriptionLabel;
@property(nonatomic,weak) IBOutlet UILabel			*segmentNameLabel;
@property(nonatomic,weak) IBOutlet UILabel			*roadTypeLabel;
@property(nonatomic,weak) IBOutlet UIStackView		*labelContainer;


@property(nonatomic,weak) IBOutlet UILabel         *segmentNumberLabel;


@property(nonatomic,weak) IBOutlet UIStackView		*readoutContainer;


@property(nonatomic,weak) IBOutlet UIImageView         *segmentTypeIcon;
@property(nonatomic,weak) IBOutlet UIImageView         *segmentRoadTypeIcon;

@property (nonatomic,strong)  UISwipeGestureRecognizer					*footerSwipeGesture;


+ (NSString *)segmentDirectionIcon:(NSString *)segmentDirectionType;


@end

@implementation RouteSegmentFooterView



-(void)initialise{
	
	self.fonts=[NSMutableArray arrayWithObjects:[UIFont boldSystemFontOfSize:12],[UIFont systemFontOfSize:12],nil];
	self.colors=[NSMutableArray arrayWithObjects:UIColorFromRGB(0x542600),UIColorFromRGB(0x404040),nil];
	
}




-(void)updateLayout{
	
	BOOL hasCapitalizedTurnEntry=[_dataProvider.infoStringDictionary objectForKey:@"capitalizedTurn"]!=nil;
	
	if(hasCapitalizedTurnEntry==NO){
		if(_hasCapitalizedTurn==YES){
			[_labelContainer removeArrangedSubview:_segmentDescriptionLabel];
		}
		_hasCapitalizedTurn=NO;
	}else {
		
		
		if(_hasCapitalizedTurn==NO){
			
			[_labelContainer insertArrangedSubview:_segmentDescriptionLabel atIndex:0];
		}
		_segmentDescriptionLabel.text=[[_dataProvider.infoStringDictionary objectForKey:@"capitalizedTurn"] uppercaseString];
		
		_hasCapitalizedTurn=YES;
		
	}
	
	
	_segmentTypeIcon.image=[UIImage imageNamed:[RouteSegmentFooterView segmentDirectionIcon:[[_dataProvider.infoStringDictionary objectForKey:@"capitalizedTurn"] lowercaseString]]];
	_segmentRoadTypeIcon.image=[UIImage imageNamed:_dataProvider.provisionIcon];
	
	_segmentNameLabel.text=[_dataProvider.infoStringDictionary objectForKey:@"roadname"];
	
	[self updateWalkingUI];
	
	[self updateReadoutView];
	
}


-(void)updateWalkingUI{
	
	if(_dataProvider.isWalkingSection==YES){
		_roadTypeLabel.text=@"Walking section";
		_roadTypeLabel.textColor=UIColorFromRGB(0xc20000);
	}else{
		_roadTypeLabel.text=[_dataProvider.infoStringDictionary objectForKey:@"provisionName"];
		_roadTypeLabel.textColor=UIColorFromRGB(0x7F7F7F);
	}
	
}

-(void)updateReadoutView{
	
	/*
	 _timeLabel.labels=[NSMutableArray arrayWithObjects:@"Time:",[_dataProvider.infoStringDictionary objectForKey:@"hm"],nil];
	 [_timeLabel drawUI];
	 _distLabel.labels=[NSMutableArray arrayWithObjects:@"Dist:",[CycleStreets formattedDistanceString:[[_dataProvider.infoStringDictionary objectForKey:@"distance"] doubleValue]],nil];
	 [_distLabel drawUI];
	 _totalLabel.labels=[NSMutableArray arrayWithObjects:@"Total:",[CycleStreets formattedDistanceString:[[_dataProvider.infoStringDictionary objectForKey:@"total"] doubleValue]],nil];
	 [_totalLabel drawUI];
	 [_readoutContainer refresh];
	 
	 */
	
	
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


+ (NSString *)segmentDirectionIcon:(NSString *)segmentDirectionType {
	
	BetterLog(@"segmentDirectionIcon=%@",segmentDirectionType);
	
	if (segmentDirectionsIcons==nil) {
		
		segmentDirectionsIcons = [NSDictionary dictionaryWithObjectsAndKeys:
								  @"UIIcon_straight_on.png", @"straight on",
								  @"UIIcon_bear_left.png", @"bear left",
								  @"UIIcon_bear_right.png", @"bear right",
								  @"UIIcon_turn_left.png", @"turn left",
								  @"UIIcon_turn_left.png", @"sharp left",
								  @"UIIcon_turn_right.png", @"turn right",
								  @"UIIcon_turn_right.png", @"sharp right",
								  nil];
	}
	
	NSString *iconType=[segmentDirectionsIcons valueForKey:segmentDirectionType];
	
	if(iconType==nil)
		iconType=@"UIIcon_straight_on.png";
	
	return iconType;
}

@end
