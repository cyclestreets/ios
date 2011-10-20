//
//  FavouritesManager.m
//  CycleStreets
//
//  Created by neil on 22/02/2011.
//  Copyright 2011 CycleStreets Ltd. All rights reserved.
//

#import "FavouritesManager.h"
#import "CycleStreets.h"
#import "Route.h"
#import "Files.h"
#import "FavouritesViewController.h"
#import "CycleStreetsAppDelegate.h"

@implementation FavouritesManager
SYNTHESIZE_SINGLETON_FOR_CLASS(FavouritesManager);
@synthesize dataProvider;


//=========================================================== 
// dealloc
//=========================================================== 
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
        self.dataProvider = [(Files*)[CycleStreets sharedInstance].files favourites];
    }
    return self;
}




-(void)removeObjectFromDataProviderAtIndex:(NSUInteger)index{
	
	CycleStreets *cycleStreets = [CycleStreets sharedInstance];
	[dataProvider removeObjectAtIndex:index];
	[cycleStreets.files setFavourites:dataProvider];
	
}




//could listen for the route changing.
- (void) selectRoute:(Route *)route {
	
	NSInteger index=-1;
	index=[dataProvider indexOfObject:[route itinerary]];
	
	if(index!=-1 && index!=0){
		[dataProvider exchangeObjectAtIndex:0 withObjectAtIndex:index];
	}
	
	[[CycleStreets sharedInstance].files setMiscValue:[route itinerary] forKey:@"selectedroute"];
		
	//TODO: this ref should be rmoved form app delegate and this event should be a 
	// notification, FavouritesViewController needs conforming to SuperViewController before this can happen
	CycleStreetsAppDelegate *appdelegate = [CycleStreets sharedInstance].appDelegate;
	FavouritesViewController *favourites = appdelegate.favourites;
	[favourites clear];
	
	
}

@end
