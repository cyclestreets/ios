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
#import "CycleStreets.h"
#import "UIView+Additions.h"

@import PureLayout;


static NSDictionary *segmentDirectionsIcons;


@interface RouteSegmentFooterView()

@property (nonatomic)	BOOL                            hasCapitalizedTurn;

@property (nonatomic,strong)  NSMutableArray 			*fonts;
@property (nonatomic,strong)  NSMutableArray 			*colors;
@property (nonatomic,strong)  NSMutableArray			*labels;



@property(nonatomic,strong) IBOutlet UILabel			*segmentDescriptionLabel;
@property(nonatomic,weak) IBOutlet UILabel				*segmentNameLabel;
@property(nonatomic,weak) IBOutlet UILabel				*roadTypeLabel;
@property(nonatomic,weak) IBOutlet UIStackView			*labelContainer;



@property(nonatomic,weak) IBOutlet UIView				*readoutContainer;


@property(nonatomic,weak) IBOutlet UIImageView         *segmentTypeIcon;
@property(nonatomic,weak) IBOutlet UIImageView         *segmentRoadTypeIcon;

@property (nonatomic,strong)  UISwipeGestureRecognizer	*footerSwipeGesture;

@property (nonatomic,strong)  NSMutableDictionary 		*labelTargetDict;


+ (NSString *)segmentDirectionIcon:(NSString *)segmentDirectionType;


@end

@implementation RouteSegmentFooterView



-(void)awakeFromNib{
	[super awakeFromNib];
	[self initialise];
}


-(void)initialise{
	
	self.fonts=[NSMutableArray arrayWithObjects:[UIFont boldSystemFontOfSize:12],[UIFont systemFontOfSize:12],nil];
	self.colors=[NSMutableArray arrayWithObjects:UIColorFromRGB(0x542600),UIColorFromRGB(0x404040),nil];
	
	[self createUILabels];
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
	
	for (NSString *key in _labelTargetDict) {
		
		UILabel *label=_labelTargetDict[key];
		
		if([key isEqualToString:@"Time:"]){
			label.text=[_dataProvider.infoStringDictionary objectForKey:@"hm"];
		}else if ([key isEqualToString:@"Dist:"]){
			label.text=[CycleStreets formattedDistanceString:[[_dataProvider.infoStringDictionary objectForKey:@"distance"] doubleValue]];
		}else{
			label.text=[CycleStreets formattedDistanceString:[[_dataProvider.infoStringDictionary objectForKey:@"total"] doubleValue]];
		}
		
	}
	
	
}

-(void)createUILabels{
	
	NSArray *config=@[@"Time:",@"Dist:",@"Total:"];
	self.labelTargetDict=[NSMutableDictionary dictionary];
	
	
	for (NSString *key in config) {
		
		UIStackView *groupcontainer=[[UIStackView alloc]initForAutoLayout];
		groupcontainer.axis=UILayoutConstraintAxisHorizontal;
		groupcontainer.spacing=2;
		
		for(int x=0;x<_fonts.count;x++){
			
			UILabel *label=[[UILabel alloc]initForAutoLayout];
			label.numberOfLines=0;
			label.font=_fonts[x];
			label.textColor=_colors[x];
			if (x==1) {
				[label setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
			}else{
				label.text=key;
				[label setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
			}
			
			if(x==1)
				[_labelTargetDict setObject:label forKey:key];
				
			[groupcontainer addArrangedSubview:label];
			
		}
		
		[_readoutContainer addSubview:groupcontainer];
		
		
	}
	

	UIView *targetView=nil;
	for (UIStackView *stackView in _readoutContainer.subviews) {
		if(targetView==nil){
			[stackView autoPinEdgeToSuperviewEdge:ALEdgeLeft];
		}else{
			[stackView autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:targetView withOffset:5];
		}
		targetView=stackView;
		[targetView autoPinEdgeToSuperviewEdge:ALEdgeTop];
	}
	
	[_readoutContainer autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:targetView];
	[_readoutContainer autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:_labelContainer];
	
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
