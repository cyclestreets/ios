//
//  FavouritesManager.m
//  CycleStreets
//
//  Created by neil on 22/02/2011.
//  Copyright 2011 CycleStreets Ltd. All rights reserved.
//

#import "FavouritesManager.h"
#import "Files.h"
#import "CycleStreets.h"

@implementation FavouritesManager
SYNTHESIZE_SINGLETON_FOR_CLASS(FavouritesManager);
@synthesize dataProvider;



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


-(void)removeDataFile{
	
	[(Files*)[CycleStreets sharedInstance].files removeDataFileForType:@"favourites"];
}


@end
