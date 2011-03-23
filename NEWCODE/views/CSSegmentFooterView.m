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

@implementation CSSegmentFooterView
@synthesize dataProvider;
@synthesize hasCapitalizedTurn;
@synthesize roadNameLabel;
@synthesize roadTypeLabel;
@synthesize capitalizedTurnLabel;
@synthesize readoutContainer;
@synthesize timeLabel;
@synthesize distLabel;
@synthesize totalLabel;

/***********************************************************/
// dealloc
/***********************************************************/
- (void)dealloc
{
    [dataProvider release], dataProvider = nil;
    [roadNameLabel release], roadNameLabel = nil;
    [roadTypeLabel release], roadTypeLabel = nil;
    [capitalizedTurnLabel release], capitalizedTurnLabel = nil;
    [readoutContainer release], readoutContainer = nil;
    [timeLabel release], timeLabel = nil;
    [distLabel release], distLabel = nil;
    [totalLabel release], totalLabel = nil;
	
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
	
	
	self.layoutMode=BUVerticalLayoutMode;
	self.alignMode=BUCenterAlignMode;
	self.itemPadding=0;
	self.paddingTop=5;
	self.paddingBottom=5;
	self.backgroundColor=UIColorFromRGB(0xECE9E8);
	
	UIView	*gradiantlayer=[[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 20)];
	gradiantlayer.layer.shadowColor = [UIColor blackColor].CGColor;
	gradiantlayer.layer.shadowOpacity = 0.5f;
	gradiantlayer.layer.shadowOffset = CGSizeMake(5, -6);
	gradiantlayer.layer.shadowRadius = 5.0f;
	gradiantlayer.layer.masksToBounds = NO;
	 
	[self.layer insertSublayer:gradiantlayer.layer atIndex:0];
	[gradiantlayer release];
	
	roadNameLabel=[[ExpandedUILabel alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 16)];
	roadNameLabel.textAlignment=UITextAlignmentCenter;
	roadNameLabel.multiline=YES;
	roadNameLabel.textColor=UIColorFromRGB(0x404040);
	roadNameLabel.font=[UIFont boldSystemFontOfSize:13];
	roadNameLabel.hasShadow=YES;
	[self addSubview:roadNameLabel];
	
	roadTypeLabel=[[ExpandedUILabel alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH-20, 16)];
	roadTypeLabel.textAlignment=UITextAlignmentCenter;
	roadTypeLabel.multiline=YES;
	roadTypeLabel.textColor=UIColorFromRGB(0x7F7F7F);
	roadTypeLabel.font=[UIFont systemFontOfSize:13];
	roadTypeLabel.hasShadow=YES;
	[self addSubview:roadTypeLabel];
	
	readoutContainer=[[LayoutBox alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 10)];
	readoutContainer.itemPadding=5;
	
	NSMutableArray *fonts=[NSMutableArray arrayWithObjects:[UIFont boldSystemFontOfSize:12],[UIFont systemFontOfSize:12],nil];
	NSMutableArray *colors=[NSMutableArray arrayWithObjects:UIColorFromRGB(0x542600),UIColorFromRGB(0x404040),nil];
	
	
	
	
	timeLabel=[[MultiLabelLine alloc] initWithFrame:CGRectMake(0, 0, 50, 16)];
	timeLabel.fonts=fonts;
	timeLabel.colors=colors;
	[readoutContainer addSubview:timeLabel];
	
	distLabel=[[MultiLabelLine alloc] initWithFrame:CGRectMake(0, 0, 50, 16)];
	distLabel.fonts=fonts;
	distLabel.colors=colors;
	[readoutContainer addSubview:distLabel];
	
	totalLabel=[[MultiLabelLine alloc] initWithFrame:CGRectMake(0, 0, 50, 16)];
	totalLabel.fonts=fonts;
	totalLabel.colors=colors;
	[readoutContainer addSubview:totalLabel];
	
	[self addSubview:readoutContainer];
	
	
}

-(void)updateLayout{
	
	BOOL hasCapitalizedTurnEntry=[dataProvider objectForKey:@"capitalizedTurn"]!=nil;
	
	if(hasCapitalizedTurnEntry==NO){
		if(hasCapitalizedTurn==YES){
			//[self removeSubviewAtIndex:0];
			capitalizedTurnLabel=nil;
		}
		hasCapitalizedTurn=NO;
	}else {
		
		/*
		if(hasCapitalizedTurn==NO){
			capitalizedTurnLabel=[[ExpandedUILabel alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 16)];
			capitalizedTurnLabel.textAlignment=UITextAlignmentCenter;
			capitalizedTurnLabel.multiline=YES;
			capitalizedTurnLabel.textColor=UIColorFromRGB(0x31620E);
			capitalizedTurnLabel.font=[UIFont boldSystemFontOfSize:13];
			capitalizedTurnLabel.hasShadow=YES;
			[self insertSubview:capitalizedTurnLabel atIndex:0];
		}
		capitalizedTurnLabel.text=[[dataProvider objectForKey:@"capitalizedTurn"] uppercaseString];
		
		hasCapitalizedTurn=YES;
		 */
	}

	roadNameLabel.text=[dataProvider objectForKey:@"roadname"];
	roadTypeLabel.text=[dataProvider objectForKey:@"provisionName"];
	
	
	timeLabel.labels=[NSMutableArray arrayWithObjects:@"Time:",[dataProvider objectForKey:@"hm"],nil];
	[timeLabel drawUI];
	distLabel.labels=[NSMutableArray arrayWithObjects:@"Dist:",[dataProvider objectForKey:@"distance"],nil];
	[distLabel drawUI];
	totalLabel.labels=[NSMutableArray arrayWithObjects:@"Total:",[dataProvider objectForKey:@"total"],nil];
	[totalLabel drawUI];
	[readoutContainer refresh];
	
	
	[self refresh];
}


@end
