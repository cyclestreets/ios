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

@import PureLayout;


@interface RouteSegmentFooterView()

@property (nonatomic,strong)  NSMutableArray *fonts;
@property (nonatomic,strong)  NSMutableArray *colors;



@end

@implementation RouteSegmentFooterView



-(void)initialise{
	
	self.fonts=[NSMutableArray arrayWithObjects:[UIFont boldSystemFontOfSize:12],[UIFont systemFontOfSize:12],nil];
	self.colors=[NSMutableArray arrayWithObjects:UIColorFromRGB(0x542600),UIColorFromRGB(0x404040),nil];
	
}




-(void)updateLayout{
	
	
	
}

@end
