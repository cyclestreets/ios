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

@implementation SettingsManager
SYNTHESIZE_SINGLETON_FOR_CLASS(SettingsManager);
@synthesize dataProvider;

/***********************************************************/
// dealloc
/***********************************************************/
- (void)dealloc
{
    
    [dataProvider release], dataProvider = nil;
	
    [super dealloc];
}


//=========================================================== 
// - (id)init
//
//=========================================================== 
- (id)init
{
    self = [super init];
    if (self) {
		[self loadData];
    }
    return self;
}





-(void)loadData{
	
	NSDictionary *dict = [(Files*)[CycleStreets sharedInstance].files settings];
	
	BetterLog(@"dict=%@",dict);
	
	self.dataProvider=[[SettingsVO alloc]init];
	
	if([dict count]>0){
		
		for (NSString *key in dict){
			if([dict valueForKey:key]!=nil)
				[dataProvider setValue:[dict valueForKey:key] forKey:key];
		}
			
	}
	
}

-(void)saveData{
	
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
	
	[dict setObject:dataProvider.imageSize forKey:@"imageSize"];
	[dict setObject:dataProvider.mapStyle forKey:@"mapStyle"];
	[dict setObject:dataProvider.plan forKey:@"plan"];
	[dict setObject:dataProvider.routeUnit forKey:@"routeUnit"];
	[dict setObject:dataProvider.speed forKey:@"speed"];
	
	BetterLog(@"dict=%@",dict);
	
	CycleStreets *cycleStreets = [CycleStreets sharedInstance];
	[cycleStreets.files setSettings:dict];	
	[dict release];
	
}

@end
