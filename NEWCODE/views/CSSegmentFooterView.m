//
//  CSSegmentFooterView.m
//  CycleStreets
//
//  Created by Neil Edwards on 23/03/2011.
//  Copyright 2011 CycleStreets Ltd. All rights reserved.
//

#import "CSSegmentFooterView.h"
#import "AppConstants.h"
#import <QuartzCore/QuartzCore.h>

static NSDictionary *segmentDirectionsIcons;

@implementation CSSegmentFooterView
@synthesize dataProvider;
@synthesize hasCapitalizedTurn;
@synthesize contentContainer;
@synthesize roadNameLabel;
@synthesize roadTypeLabel;
@synthesize capitalizedTurnLabel;
@synthesize readoutContainer;
@synthesize timeLabel;
@synthesize distLabel;
@synthesize totalLabel;
@synthesize iconView;

//=========================================================== 
// dealloc
//=========================================================== 
- (void)dealloc
{
    [dataProvider release], dataProvider = nil;
    [contentContainer release], contentContainer = nil;
    [roadNameLabel release], roadNameLabel = nil;
    [roadTypeLabel release], roadTypeLabel = nil;
    [capitalizedTurnLabel release], capitalizedTurnLabel = nil;
    [readoutContainer release], readoutContainer = nil;
    [timeLabel release], timeLabel = nil;
    [distLabel release], distLabel = nil;
    [totalLabel release], totalLabel = nil;
    [iconView release], iconView = nil;
	
    [super dealloc];
}





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
	
	self.layer.shadowColor = [UIColor blackColor].CGColor;
	self.layer.shadowOpacity = 0.4f;
	self.layer.shadowOffset = CGSizeMake(0, -3);
	self.layer.shadowRadius = 3.0f;
	self.layer.masksToBounds = NO;
	
	
	iconView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 32, 32)];
	iconView.image=[UIImage imageNamed:@"UIIcon_straight_on.png"];
	[self addSubview:iconView];
	
	// vertical lb for main text
	contentContainer=[[LayoutBox alloc] initWithFrame:CGRectMake(0, 0, 150, 10)];
	contentContainer.fixedWidth=YES;
	contentContainer.layoutMode=BUVerticalLayoutMode;
	contentContainer.itemPadding=0;
	
	
	roadNameLabel=[[ExpandedUILabel alloc]initWithFrame:CGRectMake(0, 0, UIWIDTH, 16)];
	roadNameLabel.textAlignment=UITextAlignmentLeft;
	roadNameLabel.multiline=YES;
	roadNameLabel.textColor=UIColorFromRGB(0x404040);
	roadNameLabel.font=[UIFont boldSystemFontOfSize:13];
	roadNameLabel.hasShadow=YES;
	[contentContainer addSubview:roadNameLabel];
	
	roadTypeLabel=[[ExpandedUILabel alloc]initWithFrame:CGRectMake(0, 0, UIWIDTH-20, 16)];
	roadTypeLabel.textAlignment=UITextAlignmentLeft;
	roadTypeLabel.multiline=YES;
	roadTypeLabel.textColor=UIColorFromRGB(0x7F7F7F);
	roadTypeLabel.font=[UIFont systemFontOfSize:13];
	roadTypeLabel.hasShadow=YES;
	[contentContainer addSubview:roadTypeLabel];
	
	// horizontal lb for reaout labels
	readoutContainer=[[LayoutBox alloc] initWithFrame:CGRectMake(0, 0, UIWIDTH, 10)];
	readoutContainer.itemPadding=7;
	
	NSMutableArray *fonts=[NSMutableArray arrayWithObjects:[UIFont boldSystemFontOfSize:12],[UIFont systemFontOfSize:12],nil];
	NSMutableArray *colors=[NSMutableArray arrayWithObjects:UIColorFromRGB(0x542600),UIColorFromRGB(0x404040),nil];
	
	timeLabel=[[MultiLabelLine alloc] initWithFrame:CGRectMake(0, 0, 50, 16)];
	timeLabel.itemPadding=2;
	timeLabel.fonts=fonts;
	timeLabel.colors=colors;
	[readoutContainer addSubview:timeLabel];
	
	distLabel=[[MultiLabelLine alloc] initWithFrame:CGRectMake(0, 0, 50, 16)];
	distLabel.itemPadding=2;
	distLabel.fonts=fonts;
	distLabel.colors=colors;
	[readoutContainer addSubview:distLabel];
	
	totalLabel=[[MultiLabelLine alloc] initWithFrame:CGRectMake(0, 0, 50, 16)];
	totalLabel.itemPadding=2;
	totalLabel.fonts=fonts;
	totalLabel.colors=colors;
	[readoutContainer addSubview:totalLabel];
	
	[contentContainer addSubview:readoutContainer];
	[self addSubview:contentContainer];
	
}

-(void)updateLayout{
	
	BOOL hasCapitalizedTurnEntry=[dataProvider objectForKey:@"capitalizedTurn"]!=nil;
	
	if(hasCapitalizedTurnEntry==NO){
		if(hasCapitalizedTurn==YES){
			[contentContainer removeSubviewAtIndex:0];
			capitalizedTurnLabel=nil;
		}
		hasCapitalizedTurn=NO;
	}else {
		
		
		if(hasCapitalizedTurn==NO){
			capitalizedTurnLabel=[[ExpandedUILabel alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 16)];
			capitalizedTurnLabel.textAlignment=UITextAlignmentCenter;
			capitalizedTurnLabel.multiline=YES;
			capitalizedTurnLabel.textColor=UIColorFromRGB(0x31620E);
			capitalizedTurnLabel.font=[UIFont boldSystemFontOfSize:13];
			capitalizedTurnLabel.hasShadow=YES;
			[contentContainer insertSubview:capitalizedTurnLabel atIndex:0];
		}
		capitalizedTurnLabel.text=[[dataProvider objectForKey:@"capitalizedTurn"] uppercaseString];
		
		hasCapitalizedTurn=YES;
		 
	}
	
	//iconView.image=[UIImage imageNamed:[CSSegmentFooterView segmentDirectionIcon:[dataProvider objectForKey:@"capitalizedTurn"]]];
	
	// if we support road type here too
	//roadTypeiconView.image=[SegmentVO provisionIcon:[dataProvider objectForKey:@"provisionName"]];


	roadNameLabel.text=[dataProvider objectForKey:@"roadname"];
	roadTypeLabel.text=[dataProvider objectForKey:@"provisionName"];
	
	
	timeLabel.labels=[NSMutableArray arrayWithObjects:@"Time:",[dataProvider objectForKey:@"hm"],nil];
	[timeLabel drawUI];
	distLabel.labels=[NSMutableArray arrayWithObjects:@"Dist:",[dataProvider objectForKey:@"distance"],nil];
	[distLabel drawUI];
	totalLabel.labels=[NSMutableArray arrayWithObjects:@"Total:",[dataProvider objectForKey:@"total"],nil];
	[totalLabel drawUI];
	[readoutContainer refresh];
	
	
	[contentContainer refresh];
	[self refresh];
}
					

+ (NSString *)segmentDirectionIcon:(NSString *)segmentDirectionType {
	if (segmentDirectionsIcons==nil) {
		//TODO the association of symbols to types could be improved
		segmentDirectionsIcons = [[NSDictionary dictionaryWithObjectsAndKeys:
					  @"UIIcon_straight_on.png", @"straight on", 
					  @"UIIcon_bear_left.png", @"bear left", 
					  @"UIIcon_bear_right.png", @"bear right", 
					  @"UIIcon_turn_left.png", @"turn left", 
					  @"UIIcon_turn_right.png", @"turn right",
					  nil] retain];
	}
	return [segmentDirectionsIcons valueForKey:segmentDirectionType];
}





@end
