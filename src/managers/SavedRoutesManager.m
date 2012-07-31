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
#import "AppDelegate.h"
#import "RouteManager.h"
#import "FavouritesManager.h"
#import "GlobalUtilities.h"


@interface SavedRoutesManager(Private)

-(void)transferOldFavouritesToRecents;

- (void) saveIndicies;
- (NSMutableDictionary *) loadIndicies;
- (NSString *) indiciesFile;

-(void)purgeOrphanedRoutes:(NSMutableArray*)arr;
-(void)promoteRouteToTopOfDataProvider:(RouteVO*)route;
-(NSString*)findRouteType:(RouteVO*)route;
-(int)findIndexOfRouteByID:(NSString*)routeid;

+(NSString*)returnRouteTypeInvert:(NSString*)type;

@end



@implementation SavedRoutesManager
SYNTHESIZE_SINGLETON_FOR_CLASS(SavedRoutesManager);
@synthesize routeidStore;
@synthesize favouritesdataProvider;
@synthesize recentsdataProvider;


//=========================================================== 
// - (id)init
//
//=========================================================== 
- (id)init
{
    self = [super init];
    if (self) {
        self.routeidStore = [self loadIndicies];
		if(routeidStore==nil){
			self.routeidStore = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSMutableArray array], SAVEDROUTE_FAVS,[NSMutableArray array],SAVEDROUTE_RECENTS,nil];
		}
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
		
			RouteVO *route=[[RouteManager sharedInstance] loadRouteForFileID:routeid];
			
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
	self.recentsdataProvider=recentarr;
	
	// v1>v2 transition method
	[self transferOldFavouritesToRecents];
	
	[self purgeOrphanedRoutes:orphanarr];
	
}


//
/***********************************************
 * @description			TODO:
 ***********************************************/
//
-(void)transferOldFavouritesToRecents{
	
	NSMutableArray *favourites=[FavouritesManager sharedInstance].dataProvider;
	
	NSMutableArray *routeidarr=[routeidStore objectForKey:SAVEDROUTE_RECENTS];
	
	if(favourites!=nil){
		
		for(NSString *routeid in favourites){
			
			RouteVO *route=[[RouteManager sharedInstance] legacyLoadRoute:routeid];
			
			
			if(route!=nil){
				[recentsdataProvider addObject:route];
				[routeidarr addObject:route.fileid];
			}
			
		}
		
		[[FavouritesManager sharedInstance] removeDataFile];
		
		[self saveIndicies];
		
	}

	
}




-(NSMutableArray*)dataProviderForType:(NSString*)type{
    
    if([type isEqualToString:SAVEDROUTE_FAVS]){
		return favouritesdataProvider;
	}else{
		return recentsdataProvider;
	}
}


//
/***********************************************
 * @description			adda new route to the temp stores and update the saved index file
 ***********************************************/
//
-(void)addRoute:(RouteVO*)route toDataProvider:(NSString*)type{
	
	if([type isEqualToString:SAVEDROUTE_FAVS]){
		[favouritesdataProvider insertObject:route atIndex:0];
	}else{
		[recentsdataProvider insertObject:route atIndex:0];
	}
	
	NSMutableArray *arr=[routeidStore objectForKey:type];
	[arr addObject:route.fileid];
	
	[self saveIndicies];
	
}

//
/***********************************************
 * @description			handles Route movement from Recents <> favourites
 ***********************************************/
//
-(void)moveRoute:(RouteVO*)route toDataProvider:(NSString*)type{
	
    NSString *key=[self findRouteType:route];
    
    if([key isEqualToString:@"NotFound"]){
        BetterLog(@"[ERROR] Unable to find current route in dataProvider");
    }else{
        
        NSMutableArray *fromArr;
        if([type isEqualToString:SAVEDROUTE_RECENTS]){
            fromArr=favouritesdataProvider;
        }else{
            fromArr=recentsdataProvider;
        }
        
        int index=[fromArr indexOfObjectIdenticalTo:route];
		if(index<[fromArr count])
			[fromArr removeObjectAtIndex:index];
        
        if([type isEqualToString:SAVEDROUTE_FAVS]){
            [favouritesdataProvider insertObject:route atIndex:0];
        }else{
            [recentsdataProvider insertObject:route atIndex:0];
        }
		
		// update id arrs
		NSMutableArray *newidarr=[routeidStore objectForKey:type];
		NSMutableArray *idarr=[routeidStore objectForKey:[SavedRoutesManager returnRouteTypeInvert:type]];
		[newidarr addObject:route.fileid];
		[idarr removeObject:route.fileid];
		
		[self saveIndicies];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:SAVEDROUTEUPDATE object:nil];
    }
	
	
}


-(void)removeRoute:(RouteVO*)route fromDataProvider:(NSString*)type{
    
    NSMutableArray *arr;
    if([type isEqualToString:SAVEDROUTE_FAVS]){
        arr=favouritesdataProvider;
    }else{
        arr=recentsdataProvider;
    }
    
    int index=[arr indexOfObjectIdenticalTo:route];
	
	if(index<[arr count]){
		
		[arr removeObjectAtIndex:index];
	
		NSMutableArray *idarr=[routeidStore objectForKey:type];
		[idarr removeObject:route.fileid];
	
		[self saveIndicies];
	}
    
}

-(void)removeRoute:(RouteVO*)route{
	
	for(NSString *key in routeidStore){
		
		NSMutableArray *routes=[routeidStore objectForKey:key];
		
		int index=[routes indexOfObjectIdenticalTo:route];
		
		if(index!=-1 && index!=0){
			[routes removeObjectAtIndex:index];
			[[RouteManager sharedInstance] removeRoute:route];
		}
		
	}
	
	
}


// called as result of RouteManager select Route
- (void) selectRoute:(RouteVO *)route {
	
    // TODO: this should only occur if its in the Fav array
   
    // OR have separate button in UI that shows the RouteSummary with the selected route
    // always, then no need for this odd re-organising
	[self promoteRouteToTopOfDataProvider:route];
	
}


//
/***********************************************
 * @description			Persists a route to disk and updates the UI
 ***********************************************/
//
-(void)saveRouteChangesForRoute:(RouteVO*)route{
	
	[[RouteManager sharedInstance] saveRoute:route];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:SAVEDROUTEUPDATE object:nil];
	
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
		
		int index=[routes indexOfObject:route.fileid];
		
		if(index!=NSNotFound && index!=0){
			[routes exchangeObjectAtIndex:0 withObjectAtIndex:index];
		}
		
	}
	
}


-(NSString*)findRouteType:(RouteVO*)route{
	
	for(NSString *key in routeidStore){
		
		NSMutableArray *routes=[routeidStore objectForKey:key];
		
		int index=[routes indexOfObject:route.fileid];
		
		if(index!=NSNotFound){
			return key;
		}
		
	}
	
	return @"NotFound";
	
}


-(int)findIndexOfRouteByID:(NSString*)routeid{
	
	int index=NSNotFound;
	
	for(NSString *key in routeidStore){
		
		NSMutableArray *routes=[routeidStore objectForKey:key];
		
		int index=[routes indexOfObject:routeid];
		
		if(index!=NSNotFound){
			break;
		}
		
	}
	
	return index;
}



//
/***********************************************
 * @description			File I/O
 ***********************************************/
//

- (NSMutableDictionary *) loadIndicies {
	
	NSMutableDictionary *result=[NSMutableDictionary dictionaryWithContentsOfFile:[self indiciesFile]];
	
	return result;	
}

- (void) saveIndicies {
	
	[routeidStore writeToFile:[self indiciesFile] atomically:YES];
	//BetterLog(@"did save=%i",result);
}


-(void)purgeOrphanedRoutes:(NSMutableArray*)arr{
	
	for (NSString *routeid in arr){
		[[RouteManager sharedInstance] legacyRemoveRouteFile:routeid];
	}
	
}

+(NSString*)returnRouteTypeInvert:(NSString*)type{
	if ([type isEqualToString:SAVEDROUTE_FAVS]) {
		return SAVEDROUTE_RECENTS;
	}
	return SAVEDROUTE_FAVS;
}


- (NSString *) indiciesFile {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [[paths objectAtIndex:0] copy];
	return [documentsDirectory stringByAppendingPathComponent:SAVEDROUTESARCHIVEPATH];
}

@end
