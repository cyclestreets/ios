//
//  SettingsManager.m
//  CycleStreets
//
//  Created by neil on 22/02/2011.
//  Copyright 2011 CycleStreets Ltd. All rights reserved.
//

#import "SettingsManager.h"
#import "CycleStreets.h"

@implementation SettingsManager
SYNTHESIZE_SINGLETON_FOR_CLASS(SettingsManager);
@synthesize plan;
@synthesize speed;
@synthesize mapStyle;
@synthesize imageSize;
@synthesize routeUnit;

//=========================================================== 
// dealloc
//=========================================================== 
- (void)dealloc
{
    [plan release], plan = nil;
    [speed release], speed = nil;
    [mapStyle release], mapStyle = nil;
    [imageSize release], imageSize = nil;
    [routeUnit release], routeUnit = nil;
	
    [super dealloc];
}



-(void)loadData{
	
	self.dataProvider = [[CycleStreets sharedInstance].files settings];
	self.speed = [dict valueForKey:@"speed"];
	self.plan = [dict valueForKey:@"plan"];
	self.mapStyle = [dict valueForKey:@"mapStyle"];
	self.imageSize = [dict valueForKey:@"imageSize"];
	self.routeUnit = [dict valueForKey:@"routeUnit"];
	
}

@end
