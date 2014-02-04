//
//  Trip.h
//  Cycle Atlanta
//
//  Created by Guo Anhong on 13-2-26.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "NSManagedObject+Boost.h"

@class Coord, User;

@interface Trip : NSManagedObject

@property (nonatomic, retain) NSNumber				* distance;
@property (nonatomic, retain) NSDate				* start;
@property (nonatomic, retain) NSString				* notes;
@property (nonatomic, retain) NSDate				* uploaded;
@property (nonatomic, retain) NSString				* purpose;
@property (nonatomic, retain) NSNumber				* duration;
@property (nonatomic, retain) NSDate				* saved;
@property (nonatomic, retain) NSOrderedSet			*coords;
@property (nonatomic, retain) NSData				* thumbnail;
@property (nonatomic, retain) User					*user;
@end

@interface Trip (CoreDataGeneratedAccessors)

- (void)addCoordsObject:(Coord *)value;
- (void)removeCoordsObject:(Coord *)value;
- (void)addCoords:(NSOrderedSet *)values;
- (void)removeCoords:(NSOrderedSet *)values;


// utility

@property(nonatomic,readonly)  BOOL         isUploaded;

-(NSString*)durationString;
-(NSString*)caloriesUsedString;
-(NSString*)co2SavedString;
-(NSString*)longdateString;

-(NSString*)lengthString;
-(NSString*)speedString;

-(NSString*)timeString;


@end
