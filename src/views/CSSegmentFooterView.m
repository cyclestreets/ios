//
//  CSSegmentFooterView.m
//  CycleStreets
//
//  Created by Neil Edwards on 23/03/2011.
//  Copyright 2011 CycleStreets Ltd. All rights reserved.
//

#import "CSSegmentFooterView.h"
#import "AppConstants.h"
#import "SegmentVO.h"
#import "ViewUtilities.h"
#import "ExpandedUILabel.h"
#import "MultiLabelLine.h"
#import "GlobalUtilities.h"
#import <QuartzCore/QuartzCore.h>

static NSDictionary *segmentDirectionsIcons;


@interface CSSegmentFooterView()

@property (nonatomic)	BOOL                            hasCapitalizedTurn;
@property (nonatomic, strong)	LayoutBox               * contentContainer;
@property (nonatomic, strong)	ExpandedUILabel         * roadNameLabel;
@property (nonatomic, strong)	ExpandedUILabel         * roadTypeLabel;
@property (nonatomic, strong)	ExpandedUILabel         * capitalizedTurnLabel;
@property (nonatomic, strong)	LayoutBox               * readoutContainer;
@property (nonatomic, strong)	MultiLabelLine          * timeLabel;
@property (nonatomic, strong)	MultiLabelLine          * distLabel;
@property (nonatomic, strong)	MultiLabelLine          * totalLabel;

@property (nonatomic, strong)	 UIImageView    * iconView;
@property (nonatomic, strong)	 UIImageView    * roadTypeiconView;

@property (nonatomic,strong)  UISwipeGestureRecognizer					*footerSwipeGesture;


+ (NSString *)segmentDirectionIcon:(NSString *)segmentDirectionType;

@end


@implementation CSSegmentFooterView


- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
		self.hasCapitalizedTurn=NO;
        self.fixedWidth=YES;
		self.clipsToBounds=NO;
		[self initialise];
    }
    return self;
}


-(void)initialise{
	
	
	self.layoutMode=BUHorizontalLayoutMode;
	self.fixedWidth=YES;
	self.itemPadding=10;
	self.paddingLeft=10;
	self.paddingTop=5;
	self.paddingBottom=5;
	self.backgroundColor=UIColorFromRGB(0xECE9E8);
	
	if ([self.layer respondsToSelector:@selector(setShadowColor:)]) {
		self.layer.shadowColor = [UIColor blackColor].CGColor;
		self.layer.shadowOpacity = 0.4f;
		self.layer.shadowOffset = CGSizeMake(0, -3);
		self.layer.shadowRadius = 3.0f;
		self.layer.masksToBounds = NO;
	}
	
	UIView *iconcontainer=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 32, 69)];
	self.iconView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 32, 32)];
	[iconcontainer addSubview:_iconView];
	self.roadTypeiconView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 37, 32, 32)];
	[iconcontainer addSubview:_roadTypeiconView];
	[self addSubview:iconcontainer];
	
	// vertical lb for main text
	_contentContainer=[[LayoutBox alloc] initWithFrame:CGRectMake(0, 0, 200, 10)];
	_contentContainer.fixedWidth=YES;
	_contentContainer.clipsToBounds=NO;
	_contentContainer.layoutMode=BUVerticalLayoutMode;
	_contentContainer.itemPadding=2;
	
	
	_roadNameLabel=[[ExpandedUILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 16)];
	_roadNameLabel.fixedWidth=YES;
	_roadNameLabel.textAlignment=UITextAlignmentLeft;
	_roadNameLabel.multiline=YES;
	_roadNameLabel.textColor=UIColorFromRGB(0x404040);
	_roadNameLabel.font=[UIFont boldSystemFontOfSize:13];
	[_contentContainer addSubview:_roadNameLabel];
	
	_roadTypeLabel=[[ExpandedUILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 16)];
	_roadTypeLabel.textAlignment=UITextAlignmentLeft;
	_roadTypeLabel.multiline=YES;
	_roadTypeLabel.textColor=UIColorFromRGB(0x7F7F7F);
	_roadTypeLabel.font=[UIFont systemFontOfSize:13];
	[_contentContainer addSubview:_roadTypeLabel];
	
	// horizontal lb for reaout labels
	_readoutContainer=[[LayoutBox alloc] initWithFrame:CGRectMake(0, 0, UIWIDTH, 10)];
	_readoutContainer.itemPadding=7;
	
	NSMutableArray *fonts=[NSMutableArray arrayWithObjects:[UIFont boldSystemFontOfSize:12],[UIFont systemFontOfSize:12],nil];
	NSMutableArray *colors=[NSMutableArray arrayWithObjects:UIColorFromRGB(0x542600),UIColorFromRGB(0x404040),nil];
	
	_timeLabel=[[MultiLabelLine alloc] initWithFrame:CGRectMake(0, 0, 50, 16)];
	_timeLabel.itemPadding=2;
	_timeLabel.fonts=fonts;
	_timeLabel.colors=colors;
	[_readoutContainer addSubview:_timeLabel];
	
	_distLabel=[[MultiLabelLine alloc] initWithFrame:CGRectMake(0, 0, 50, 16)];
	_distLabel.itemPadding=2;
	_distLabel.fonts=fonts;
	_distLabel.colors=colors;
	[_readoutContainer addSubview:_distLabel];
	
	_totalLabel=[[MultiLabelLine alloc] initWithFrame:CGRectMake(0, 0, 80, 16)];
	_totalLabel.itemPadding=2;
	_totalLabel.fonts=fonts;
	_totalLabel.colors=colors;
	[_readoutContainer addSubview:_totalLabel];
	
	[_contentContainer addSubview:_readoutContainer];
	[self addSubview:_contentContainer];
	
	_segmentIndexLabel=[[ExpandedUILabel alloc]initWithFrame:CGRectMake(0, 0, 50, 16)];
	_segmentIndexLabel.textAlignment=UITextAlignmentRight;
	_segmentIndexLabel.textColor=UIColorFromRGB(0x92140B);
	_segmentIndexLabel.font=[UIFont boldSystemFontOfSize:13];
	[self addSubview:_segmentIndexLabel];
	
	
	
}

-(void)updateLayout{
	
	BOOL hasCapitalizedTurnEntry=[_dataProvider.infoStringDictionary objectForKey:@"capitalizedTurn"]!=nil;
	
	if(hasCapitalizedTurnEntry==NO){
		if(_hasCapitalizedTurn==YES){
			[_contentContainer removeSubviewAtIndex:0];
			_capitalizedTurnLabel=nil;
		}
		_hasCapitalizedTurn=NO;
	}else {
		
		
		if(_hasCapitalizedTurn==NO){
			_capitalizedTurnLabel=[[ExpandedUILabel alloc]initWithFrame:CGRectMake(0, 0, _contentContainer.width, 16)];
			_capitalizedTurnLabel.textAlignment=UITextAlignmentLeft;
			_capitalizedTurnLabel.multiline=YES;
			_capitalizedTurnLabel.textColor=UIColorFromRGB(0x31620E);
			_capitalizedTurnLabel.font=[UIFont boldSystemFontOfSize:13];
			[_contentContainer insertSubview:_capitalizedTurnLabel atIndex:0];
		}
		_capitalizedTurnLabel.text=[[_dataProvider.infoStringDictionary objectForKey:@"capitalizedTurn"] uppercaseString];
		
		_hasCapitalizedTurn=YES;
		 
	}
	
	_iconView.image=[UIImage imageNamed:[CSSegmentFooterView segmentDirectionIcon:[[_dataProvider.infoStringDictionary objectForKey:@"capitalizedTurn"] lowercaseString]]];
	_roadTypeiconView.image=[UIImage imageNamed:_dataProvider.provisionIcon];


	_roadNameLabel.text=[_dataProvider.infoStringDictionary objectForKey:@"roadname"];
	
	if(_dataProvider.isWalkingSection==YES){
		_roadTypeLabel.text=@"Walking section";
		_roadTypeLabel.textColor=UIColorFromRGB(0xc20000);
	}else{
		_roadTypeLabel.text=[_dataProvider.infoStringDictionary objectForKey:@"provisionName"];
		_roadTypeLabel.textColor=UIColorFromRGB(0x7F7F7F);
	}
	
	
	
	
	_timeLabel.labels=[NSMutableArray arrayWithObjects:@"Time:",[_dataProvider.infoStringDictionary objectForKey:@"hm"],nil];
	[_timeLabel drawUI];
	_distLabel.labels=[NSMutableArray arrayWithObjects:@"Dist:",[_dataProvider.infoStringDictionary objectForKey:@"distance"],nil];
	[_distLabel drawUI];
	_totalLabel.labels=[NSMutableArray arrayWithObjects:@"Total:",[_dataProvider.infoStringDictionary objectForKey:@"total"],nil];
	[_totalLabel drawUI];
	[_readoutContainer refresh];
	
	
	[_contentContainer refresh];
	[self refresh];
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
