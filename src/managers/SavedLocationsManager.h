//
//  SavedLocationsManager.h
//  CycleStreets
//
//  Created by Neil Edwards on 14/10/2014.
//  Copyright (c) 2014 CycleStreets Ltd. All rights reserved.
//

#import "FrameworkObject.h"
#import "SynthesizeSingleton.h"

@class SavedLocationVO;

@interface SavedLocationsManager : FrameworkObject
SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(SavedLocationsManager);


@property (nonatomic,readonly)  NSMutableArray								*dataProvider;



-(void)addSavedLocation:(SavedLocationVO*)location;

-(void)removeSavedLocation:(SavedLocationVO*)location;


-(void)saveLocations;

@end
