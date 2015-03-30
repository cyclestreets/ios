//
//  CSBingSatelliteMapSource.h
//  CycleStreets
//
//  Created by Neil Edwards on 16/01/2015.
//  Copyright (c) 2015 CycleStreets Ltd. All rights reserved.
//

#import "CSMapSource.h"

#import "SynthesizeSingleton.h"

@interface CSBingSatelliteAuthentication : NSObject
SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(CSBingSatelliteAuthentication);

@property(nonatomic,readonly)  NSString         *mapTileURL;
@property(nonatomic,readonly)  int				mapTileZoom;

@end

@interface CSBingSatelliteMapSource : CSMapSource

@end
