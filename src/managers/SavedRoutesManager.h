//
//  FavouritesManager.h
//  CycleStreets
//
//  Created by neil on 22/02/2011.
//  Copyright 2011 CycleStreets Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SynthesizeSingleton.h"
#import "RouteVO.h"

enum  {
	SavedRoutesDataTypeRecent,
	SavedRoutesDataTypeFavourite
};
typedef int SavedRoutesDataType;

#define SAVEDROUTESARCHIVEPATH @"savedroutes"

@interface SavedRoutesManager : NSObject {
	
	NSMutableDictionary				*routeidStore; // keyed dict of favs & recents
	NSMutableArray					*favouritesdataProvider; // array of Routes use has favorited
	NSMutableArray					*recentsdataProvider; // array of all other routes, only stores x number
	
}
SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(SavedRoutesManager);
@property (nonatomic, strong)	NSMutableDictionary		*routeidStore;
@property (nonatomic, strong)	NSMutableArray		*favouritesdataProvider;
@property (nonatomic, strong)	NSMutableArray		*recentsdataProvider;

-(void)removeRoute:(RouteVO*)route;
-(void)removeRoute:(RouteVO*)route fromDataProvider:(NSString*)type;
-(void)loadSavedRoutes;
- (void) selectRoute:(RouteVO *)route;

-(void)moveRoute:(RouteVO*)route toDataProvider:(NSString*)type;
-(void)addRoute:(RouteVO*)route toDataProvider:(NSString*)type;

-(NSMutableArray*)dataProviderForType:(NSString*)type;

-(void)saveRouteChangesForRoute:(RouteVO*)route;

-(BOOL)findRouteWithId:(NSString*)routeid andPlan:(NSString*)plan;


@end
