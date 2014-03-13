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
#import "GlobalUtilities.h"
#import "AppConstants.h"

@implementation SettingsManager
SYNTHESIZE_SINGLETON_FOR_CLASS(SettingsManager);
@synthesize dataProvider;


//=========================================================== 
// - (id)init
//
//=========================================================== 
- (instancetype)init
{
    self = [super init];
    if (self) {
		[self loadData];
    }
    return self;
}





-(void)loadData{
	
	NSDictionary *dict = [(Files*)[CycleStreets sharedInstance].files settings];
	
	self.dataProvider=[[SettingsVO alloc]init];
	
	// handle dict>dataprovider initialising
	if([dict count]>0){		
		[self updateDataProvider:dict];
	}
	
}


-(void)updateDataProvider:(NSDictionary*)dict{
	
	for (NSString *key in dict){
		if([dict valueForKey:key]!=nil){
			
			if([key isEqualToString:@"showRoutePoint"]){
				dataProvider.showRoutePoint=[[dict valueForKey:key] boolValue];
			}else {
				[dataProvider setValue:[dict valueForKey:key] forKey:key];
			}
		}
			
	}
	
}


-(void)saveData{
	
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
	
	// Temp: need to sort out NSObject enumeration
	[dict setObject:dataProvider.imageSize forKey:@"imageSize"];
	[dict setObject:dataProvider.mapStyle forKey:@"mapStyle"];
	[dict setObject:dataProvider.plan forKey:@"plan"];
	[dict setObject:dataProvider.routeUnit forKey:@"routeUnit"];
	[dict setObject:dataProvider.speed forKey:@"speed"];
	[dict setObject:[NSNumber numberWithBool:dataProvider.showRoutePoint] forKey:@"showRoutePoint"];
	
	CycleStreets *cycleStreets = [CycleStreets sharedInstance];
	[cycleStreets.files setSettings:dict];
	
	[self updateDataProvider:dict];
	
}



//
/***********************************************
 * @description			UTILITY
 ***********************************************/
//

-(BOOL)routeUnitisMiles{
	
	return [dataProvider.routeUnit isEqualToString:MILES];
	
}


@end
