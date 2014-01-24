//
//  Note.h
//  Cycle Atlanta
//
//  Created by Guo Anhong on 13-2-26.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "NSManagedObject+Boost.h"

@class User;

@interface Note : NSManagedObject

@property (nonatomic, retain) NSString * details;
@property (nonatomic, retain) NSNumber * speed;
@property (nonatomic, retain) NSNumber * vAccuracy;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * image_url;
@property (nonatomic, retain) NSNumber * note_type;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * hAccuracy;
@property (nonatomic, retain) NSDate * recorded;
@property (nonatomic, retain) NSNumber * altitude;
@property (nonatomic, retain) NSData * image_data;
@property (nonatomic, retain) NSData * thumbnail;
@property (nonatomic, retain) NSDate * uploaded;
@property (nonatomic, retain) User *user;

@end
