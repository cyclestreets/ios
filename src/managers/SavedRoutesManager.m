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
			
			RouteVO *route=[[RouteManager sharedInstance] loadRouteForID:[routeid intValue]];
			
			
			if(route!=nil){
				[recentsdataProvider addObject:route];
				[routeidarr addObject:routeid];
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
-(void)addRouteToDataProvider:(RouteVO*)route dp:(NSString*)type{
	
	if([type isEqualToString:SAVEDROUTE_FAVS]){
		[favouritesdataProvider insertObject:route atIndex:0];
	}else{
		[recentsdataProvider insertObject:route atIndex:0];
	}
	
	NSMutableArray *arr=[routeidStore objectForKey:type];
	[arr addObject:route.routeid];
	
	[self saveIndicies];
	
}

//
/***********************************************
 * @description			handles Route movement from Recents <> favourites
 ***********************************************/
//
-(void)moveRouteToDataProvider:(RouteVO*)route dp:(NSString*)type{
	
    NSString *key=[self findRouteType:route];
    
    if([key isEqualToString:@"NotFound"]){
        // this should not occur!
    }else{
        
        NSMutableArray *arr;
        if([type isEqualToString:SAVEDROUTE_FAVS]){
            arr=favouritesdataProvider;
        }else{
            arr=recentsdataProvider;
        }
        
        int index=[arr indexOfObjectIdenticalTo:route];
        [arr removeObjectAtIndex:index];
        
        if([type isEqualToString:SAVEDROUTE_FAVS]){
            [recentsdataProvider insertObject:route atIndex:0];
        }else{
            [favouritesdataProvider insertObject:route atIndex:0];
        }
		
		// update id arrs
		NSMutableArray *newidarr=[routeidStore objectForKey:type];
		NSMutableArray *idarr=[routeidStore objectForKey:[SavedRoutesManager returnRouteTypeInvert:type]];
		[newidarr addObject:route.routeid];
		[idarr removeObject:route.routeid];
		
		[self saveIndicies];
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
	
	NSMutableArray *idarr=[routeidStore objectForKey:type];
	[idarr removeObject:route.routeid];
	
	[self saveIndicies];
    
}

-(void)removeRoute:(RouteVO*)route{
	
	for(NSString *key in routeidStore){
		
		NSMutableArray *routes=[routeidStore objectForKey:key];
		
		int index=[routes indexOfObjectIdenticalTo:route];
		
		if(index!=-1 && index!=0){
			[routes removeObjectAtIndex:index];
			[[RouteManager sharedInstance] removeRouteForID:[route.routeid intValue]];
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
 * @description			Utility
 ***********************************************/
//

// locates a route and move it to top of its dp, occurs when a route is selected by user
-(void)promoteRouteToTopOfDataProvider:(RouteVO*)route{
	
	for(NSString *key in routeidStore){
		
		NSMutableArray *routes=[routeidStore objectForKey:key];
		
		int index=[routes indexOfObject:route.routeid];
		
		if(index!=NSNotFound && index!=0){
			[routes exchangeObjectAtIndex:0 withObjectAtIndex:index];
		}
		
	}
	
}


-(NSString*)findRouteType:(RouteVO*)route{
	
	for(NSString *key in routeidStore){
		
		NSMutableArray *routes=[routeidStore objectForKey:key];
		
		int index=[routes indexOfObjectIdenticalTo:route.routeid];
		
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
		
		int index=[routes indexOfObjectIdenticalTo:routeid];
		
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
	
	BOOL result=[routeidStore writeToFile:[self indiciesFile] atomically:YES];
	BetterLog(@"did save=%i",result);
}


-(void)purgeOrphanedRoutes:(NSMutableArray*)arr{
	
	for (NSString *routeid in arr){
		[[RouteManager sharedInstance] removeRoute:routeid];
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
