//
//  PhotoCategoryManager.h
//  CycleStreets
//
//  Created by Gaby Jones on 17/04/2012.
//  Copyright (c) 2012 CycleStreets Ltd. All rights reserved.
//

#import "FrameworkObject.h"
#import "SynthesizeSingleton.h"
#import "PhotoCategoryVO.h"

@interface PhotoCategoryManager : FrameworkObject{
	
	NSMutableDictionary					*dataProvider;
	
	NSString							*validUntilTimeStamp;
	
}
@property (nonatomic, strong) NSMutableDictionary		* dataProvider;
@property (nonatomic, strong) NSString		* validUntilTimeStamp;


SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(PhotoCategoryManager);


-(PhotoCategoryVO*)valueObjectForType:(NSString*)type atIndex:(int)index;
@end
