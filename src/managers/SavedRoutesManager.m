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
-(NSString*)findRoute:(RouteVO*)route;

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
				if([key isEqualToString:SAVEDROUTE_FAVS]){
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



-(NSMutableArray*)dataProviderForType:(NSString*)type{
    
    if([type isEqualToString:SAVEDROUTE_FAVS]){
		return favouritesdataProvider;
	}else{
		return recentsdataProvider;
	}
}



-(void)addRouteToDataProvider:(RouteVO*)route dp:(NSString*)type{
	
	if([type isEqualToString:SAVEDROUTE_FAVS]){
		[favouritesdataProvider insertObject:route atIndex:0];
	}else{
		[recentsdataProvider insertObject:route atIndex:0];
	}
	
}


-(void)moveRouteToDataProvider:(RouteVO*)route dp:(NSString*)type{
	
    NSString *founddp=[self findRoute:route];
    
    if([founddp isEqualToString:@"NotFound"]){
        // this should not occur!
    }else{
        
        NSMutableArray *arr;
        if([type isEqualToString:SAVEDROUTE_FAVS]){
            arr=favouritesdataProvider;
        }else{
            arr=recentsdataProvider;
        }
        
        int index=[arr indexOfObjectIdenticalTo:route.routeid];
        [arr removeObjectAtIndex:index];
        
        if([type isEqualToString:SAVEDROUTE_FAVS]){
            [recentsdataProvider insertObject:route atIndex:0];
        }else{
            [favouritesdataProvider insertObject:route atIndex:0];
        }
    }
	
	
}


-(void)removeRoute:(RouteVO*)route fromDataProvider:(NSString*)type{
    
    NSMutableArray *arr;
    if([type isEqualToString:SAVEDROUTE_FAVS]){
        arr=favouritesdataProvider;
    }else{
        arr=recentsdataProvider;
    }
    
    int index=[arr indexOfObjectIdenticalTo:route.routeid];
    [arr removeObjectAtIndex:index];
    
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
	
    // TODO: this should only occur if its in the Fav array
    // if in the Recents should be moved to selectedRoute header
    // alternatively both dps could have selectedRoute key which appears at top of table
    // if sr is it
    // OR have separate button in UI that shows the RouteSummary with the selected route
    // always, then no need for this odd re-organising
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


-(NSString*)findRoute:(RouteVO*)route{
	
	for(NSString *key in routeidStore){
		
		NSMutableArray *routes=[routeidStore objectForKey:key];
		
		int index=[routes indexOfObjectIdenticalTo:route.routeid];
		
		if(index!=-1 && index!=0){
			return key;
		}
		
	}
	
	return @"NotFound";
	
}


//
/***********************************************
 * @description			File I/O
 ***********************************************/
//

- (NSMutableDictionary *) loadIndicies {
	NSMutableDictionary *result = [NSMutableDictionary dictionaryWithContentsOfFile:[self indiciesFile]];
	if (nil == result) {
		self.routeidStore = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSNull null], SAVEDROUTE_FAVS,[NSNull null],SAVEDROUTE_RECENTS,nil];
	}
	return result;	
}




-(void)purgeOrphanedRoutes:(NSMutableArray*)arr{
	
	for (NSString *routeid in arr){
		[[RouteManager sharedInstance] removeRoute:routeid];
	}
	
}


- (NSString *) indiciesFile {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [[paths objectAtIndex:0] copy];
	return [documentsDirectory stringByAppendingPathComponent:SAVEDROUTESARCHIVEPATH];
}

@end
