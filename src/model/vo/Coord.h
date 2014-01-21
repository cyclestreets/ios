//
//  Coord.h
//  Cycle Atlanta
//
//  Created by Guo Anhong on 13-2-26.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Trip;

@interface Coord : NSManagedObject

@property (nonatomic, retain) NSNumber * hAccuracy;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSNumber * vAccuracy;
@property (nonatomic, retain) NSNumber * speed;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSDate * recorded;
@property (nonatomic, retain) NSNumber * altitude;
@property (nonatomic, retain) Trip *trip;

@end
