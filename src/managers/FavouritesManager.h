//
//  FavouritesManager.h
//  CycleStreets
//
//  Created by neil on 22/02/2011.
//  Copyright 2011 CycleStreets Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SynthesizeSingleton.h"

@interface FavouritesManager : NSObject {
	
	NSMutableArray				*dataProvider;
	
	
}
SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(FavouritesManager);
@property (nonatomic, retain)	NSMutableArray	*dataProvider;

-(void)removeDataFile;

@end
