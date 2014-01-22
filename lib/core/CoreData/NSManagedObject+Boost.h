//
//  NSManagedObject+Boost.h
//  iBoost
//
//  Created by John Blanco on 8/13/11.
//  Copyright 2011 Double Encore. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "CoreDataStore.h"

@interface NSManagedObject (Boost)

// CREATION

+ (id)create;
+ (id)createInStore:(CoreDataStore *)store;

// QUERY

+ (NSArray *)all;
+ (NSArray *)allForPredicate:(NSPredicate *)predicate;
+ (NSArray *)allForPredicate:(NSPredicate *)predicate orderBy:(NSString *)key ascending:(BOOL)ascending;
+ (NSArray *)allOrderedBy:(NSString *)key ascending:(BOOL)ascending;
+ (NSArray *)allInStore:(CoreDataStore *)store;
+ (NSArray *)allForPredicate:(NSPredicate *)predicate inStore:(CoreDataStore *)store;
+ (NSArray *)allForPredicate:(NSPredicate *)predicate orderBy:(NSString *)key ascending:(BOOL)ascending inStore:(CoreDataStore *)store;
+ (NSArray *)allOrderedBy:(NSString *)key ascending:(BOOL)ascending inStore:(CoreDataStore *)store;

+ (id)first;
+ (id)firstWithKey:(NSString *)key value:(NSObject *)value;

+ (id)firstInStore:(CoreDataStore *)store;
+ (id)firstWithKey:(NSString *)key value:(NSObject *)value inStore:(CoreDataStore *)store;

// DELETE/DESTROY

+ (void)destroyAll;
+ (void)destroyAllInStore:(CoreDataStore *)store;

- (void)destroy;

@end
