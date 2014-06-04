//
//  CSMapSource.h
//  CycleStreets
//
//  Created by Neil Edwards on 04/06/2014.
//  Copyright (c) 2014 CycleStreets Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CSMapSource : NSObject

/** A short version of the tile source's name. */
@property (nonatomic, readonly) NSString *shortName;

/** An extended version of the tile source's description. */
@property (nonatomic, readonly) NSString *longDescription;

/** A short version of the tile source's attribution string. */
@property (nonatomic, readonly) NSString *shortAttribution;

/** An extended version of the tile source's attribution string. */
@property (nonatomic, readonly) NSString *longAttribution;

@property (nonatomic, readonly) NSString *uniqueTilecacheKey;



@property (nonatomic, readonly) NSString *tileTemplate;

@property (nonatomic, readonly) int		maxZoom;
@property (nonatomic, readonly) int		minZoom;

@end
