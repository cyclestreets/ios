//
//  SettingsManager.m
//  CycleStreets
//
//  Created by neil on 22/02/2011.
//  Copyright 2011 CycleStreets Ltd. All rights reserved.
//

#import "SettingsManager.h"
#import "CycleStreets.h"
#import "Files.h"

@implementation SettingsManager
SYNTHESIZE_SINGLETON_FOR_CLASS(SettingsManager);
@synthesize plan;
@synthesize speed;
@synthesize mapStyle;
@synthesize imageSize;
@synthesize routeUnit;
@synthesize dataProvider;

/***********************************************************/
// dealloc
/***********************************************************/
- (void)dealloc
{
    [plan release], plan = nil;
    [speed release], speed = nil;
    [mapStyle release], mapStyle = nil;
    [imageSize release], imageSize = nil;
    [routeUnit release], routeUnit = nil;
    [dataProvider release], dataProvider = nil;
	
    [super dealloc];
}





-(void)loadData{
	
	self.dataProvider = [(Files*)[CycleStreets sharedInstance].files settings];
	self.speed = [dataProvider valueForKey:@"speed"];
	self.plan = [dataProvider valueForKey:@"plan"];
	self.mapStyle = [dataProvider valueForKey:@"mapStyle"];
	self.imageSize = [dataProvider valueForKey:@"imageSize"];
	self.routeUnit = [dataProvider valueForKey:@"routeUnit"];
	
}

-(void)saveData:(NSDictionary*)dict{
	
	self.dataProvider=dict;
	[self loadData];
	
	CycleStreets *cycleStreets = [CycleStreets sharedInstance];
	[cycleStreets.files setSettings:dataProvider];	
	
}

@end
