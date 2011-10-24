//
//  FavouritesManager.m
//  CycleStreets
//
//  Created by neil on 22/02/2011.
//  Copyright 2011 CycleStreets Ltd. All rights reserved.
//

#import "SavedRoutesManager.h"
#import "CycleStreets.h"
#import "RouteVO.h"
#import "Files.h"
#import "CycleStreetsAppDelegate.h"
#import "RouteManager.h"

@interface SavedRoutesManager(Private)

- (NSMutableDictionary *) loadIndicies;
- (NSString *) indiciesFile;
-(void)purgeOrphanedRoutes:(NSMutableArray*)arr;
-(void)promoteRouteToTopOfDataProvider:(RouteVO*)route;

@end



@implementation SavedRoutesManager
SYNTHESIZE_SINGLETON_FOR_CLASS(SavedRoutesManager);
@synthesize routeidStore;
@synthesize favouritesdataProvider;
@synthesize recentsdataProvider;

//=========================================================== 
// dealloc
//=========================================================== 
- (void)dealloc
{
    [routeidStore release], routeidStore = nil;
    [favouritesdataProvider release], favouritesdataProvider = nil;
    [recentsdataProvider release], recentsdataProvider = nil;
	
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
        self.routeidStore = [self loadIndicies];
		[self loadSavedRoutes];
    }
    return self;
}


-(void)loadSavedRoutes{
	
	
	NSMutableArray *favarr=[[NSMutableArray alloc]init];
	NSMutableArray *recentarr=[[NSMutableArray alloc]init];
	NSMutableArray *orphanarr=[[NSMutableArray alloc]init];
	
	for(NSString *key in routeidStore){
		
		NSArray *routes=[routeidStore objectForKey:key];
		
		for(NSString *routeid in routes){
		
			RouteVO *route=[[RouteManager sharedInstance] loadRouteForID:[routeid intValue]];
			
			if(route!=nil){
				if([key isEqualToString:@"Favourites"]){
					[favarr addObject:route];
				}else{
					[recentarr addObject:route];
				}
			}else{
				[orphanarr addObject:routeid];
			}
		
		}
		
	}
	
	self.favouritesdataProvider=favarr;
	[favarr release];
	self.recentsdataProvider=recentarr;
	[recentarr release];
	
	[self purgeOrphanedRoutes:orphanarr];
	
}




-(void)addRouteToDataProvider:(RouteVO*)route dp:(NSString*)type{
	
	if([type isEqualToString:@"Favourites"]){
		[favouritesdataProvider insertObject:route atIndex:0];
	}else{
		[recentsdataProvider insertObject:route atIndex:0];
	}
	
}


-(void)moveRouteToDataProvider:(RouteVO*)route dp:(NSString*)type{
	
	
	// move an existing route to a different dp
	
	
	
	
}


-(void)removeRoute:(RouteVO*)route{
	

	for(NSString *key in routeidStore){
		
		NSMutableArray *routes=[routeidStore objectForKey:key];
		
		int index=[routes indexOfObjectIdenticalTo:route.routeid];
		
		if(index!=-1 && index!=0){
			[routes removeObjectAtIndex:index];
			[[RouteManager sharedInstance] removeRouteForID:[route.routeid intValue]];
		}
		
	}
	
	
}


// called as result of RouteManager select Route
- (void) selectRoute:(RouteVO *)route {
	
	[self promoteRouteToTopOfDataProvider:route];
	
}


//
/***********************************************
 * @description			Utility
 ***********************************************/
//

// locates a route and move it to top of its dp, occurs when a route is selected by user
-(void)promoteRouteToTopOfDataProvider:(RouteVO*)route{
	
	for(NSString *key in routeidStore){
		
		NSMutableArray *routes=[routeidStore objectForKey:key];
		
		int index=[routes indexOfObjectIdenticalTo:route.routeid];
		
		if(index!=-1 && index!=0){
			[routes exchangeObjectAtIndex:0 withObjectAtIndex:index];
		}
		
	}
	
}


-(BOOL)findRoute:(RouteVO*)route{
	
	for(NSString *key in routeidStore){
		
		NSMutableArray *routes=[routeidStore objectForKey:key];
		
		int index=[routes indexOfObjectIdenticalTo:route.routeid];
		
		if(index!=-1 && index!=0){
			return YES;
		}
		
	}
	
	return NO;
	
}


//
/***********************************************
 * @description			File I/O
 ***********************************************/
//

- (NSMutableDictionary *) loadIndicies {
	NSMutableDictionary *result = [NSMutableDictionary dictionaryWithContentsOfFile:[self indiciesFile]];
	if (nil == result) {
		self.routeidStore = [NSMutableDictionary dictionary];
	}
	return result;	
}




-(void)purgeOrphanedRoutes:(NSMutableArray*)arr{
	
	for (NSString *routeid in arr){
		[[RouteManager sharedInstance] removeRequestID:routeid];
	}
	
}


- (NSString *) indiciesFile {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [[paths objectAtIndex:0] copy];
	return [documentsDirectory stringByAppendingPathComponent:SAVEDROUTESARCHIVEPATH];
}

@end
