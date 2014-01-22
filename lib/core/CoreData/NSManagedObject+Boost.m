//
//  NSManagedObject+Boost.m
//  iBoost
//
//  Created by John Blanco on 8/13/11.
//  Copyright 2011 Double Encore. All rights reserved.
//

#import "NSManagedObject+Boost.h"
#import <objc/runtime.h>
#import "CoreDataStore.h"

@class CoreDataStore;

@implementation NSManagedObject (Boost)

+ (id)create {
    return [self createInStore:[CoreDataStore mainStore]];
}

+ (id)createInStore:(CoreDataStore *)store {
    return [store createNewEntityByName:NSStringFromClass(self.class)];
}

+ (NSArray *)all {
    return [self allInStore:[CoreDataStore mainStore]];
}

+ (NSArray *)allForPredicate:(NSPredicate *)predicate {
    return [self allForPredicate:predicate inStore:[CoreDataStore mainStore]];
}

+ (NSArray *)allForPredicate:(NSPredicate *)predicate orderBy:(NSString *)key ascending:(BOOL)ascending {
    return [self allForPredicate:predicate orderBy:key ascending:ascending inStore:[CoreDataStore mainStore]];
}

+ (NSArray *)allOrderedBy:(NSString *)key ascending:(BOOL)ascending {
    return [self allOrderedBy:key ascending:ascending inStore:[CoreDataStore mainStore]];
}

+ (NSArray *)allInStore:(CoreDataStore *)store {
    NSError *error = nil;
    return [store allForEntity:NSStringFromClass(self.class) error:&error];    
}

+ (NSArray *)allForPredicate:(NSPredicate *)predicate inStore:(CoreDataStore *)store {
    NSError *error = nil;
    return [store allForEntity:NSStringFromClass(self.class) predicate:predicate error:&error];
}

+ (NSArray *)allForPredicate:(NSPredicate *)predicate orderBy:(NSString *)key ascending:(BOOL)ascending inStore:(CoreDataStore *)store {
    NSError *error = nil;
    return [store allForEntity:NSStringFromClass(self.class) predicate:predicate orderBy:key ascending:ascending error:&error];    
}

+ (NSArray *)allOrderedBy:(NSString *)key ascending:(BOOL)ascending inStore:(CoreDataStore *)store {
    NSError *error = nil;
    return [store allForEntity:NSStringFromClass(self.class) orderBy:key ascending:ascending error:&error];
}

+ (id)first {
    return [self firstInStore:[CoreDataStore mainStore]];
}

+ (id)firstWithKey:(NSString *)key value:(NSObject *)value {
    return [self firstWithKey:key value:value inStore:[CoreDataStore mainStore]];
}

+ (id)firstInStore:(CoreDataStore *)store {
    NSError *error = nil;
    return [store entityByName:NSStringFromClass(self.class) error:&error];    
}

+ (id)firstWithKey:(NSString *)key value:(NSObject *)value inStore:(CoreDataStore *)store {
    NSError *error = nil;
    return [store entityByName:NSStringFromClass(self.class) key:key value:value error:&error];    
}

- (void)destroy {
    [[CoreDataStore mainStore] removeEntity:self];
}

+ (void)destroyAll {
    return [self destroyAllInStore:[CoreDataStore mainStore]];
}

+ (void)destroyAllInStore:(CoreDataStore *)store {
    return [store removeAllEntitiesByName:NSStringFromClass(self.class)];
}

@end
