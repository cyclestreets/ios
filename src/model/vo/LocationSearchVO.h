/*

Copyright (C) 2010  CycleStreets Ltd

//  LocationSearchVO
//  CycleStreets
//

// NE: Value object for map location search results
 
 */

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface LocationSearchVO : NSObject

@property (nonatomic, assign) CLLocationCoordinate2D		 locationCoords;
@property (nonatomic, strong) NSString		* name;
@property (nonatomic, strong) NSString		* near;
@property (nonatomic, strong) NSString		*distance;


// getters
@property (nonatomic, readonly) NSString		 *distanceString;
@property (nonatomic, readonly) NSNumber		 *distanceInt;

- (id)initWithDictionary:(NSDictionary *)fields;

@end
