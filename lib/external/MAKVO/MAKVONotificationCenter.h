//
//  MAKVONotificationCenter.h
//  MAKVONotificationCenter
//
//  Created by Michael Ash on 10/15/08.
//

#import <Foundation/Foundation.h>

@class _MAKVONotificationHelper;


@interface MAKVONotificationCenter : NSObject
{
	NSMutableDictionary*	_observerHelpers;
	NSMutableDictionary*	_kvoHelpers;
}

+ (id)defaultCenter;

// selector should have the following signature:
// - (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)target change:(NSDictionary *)change userInfo:(id)userInfo;
- (void)addObserver:(id)observer object:(id)target keyPath:(NSString *)keyPath selector:(SEL)selector userInfo:(id)userInfo options:(NSKeyValueObservingOptions)options;
- (void)removeObserver:(id)observer object:(id)target keyPath:(NSString *)keyPath selector:(SEL)selector;

-(void)removeAllPropertiesForObserver:(NSMutableDictionary*)observerdict;
-(void)removePropertyForObserver:(NSMutableDictionary*)observerDict forKeyPath:(NSString*)keyPath;
-(void)removeAllTargetsForObserver:(id)observer;
-(void)removeAllObserversForTarget:(id)target;
-(void)addEntryForHelper:(_MAKVONotificationHelper*)helper;
-(void)removeEntryForHelper:(_MAKVONotificationHelper*)helper;
-(void)removeObserver:(id)observer forTarget:(id)target forProperty:(NSString*)keyPath;


@end

@interface NSObject (MAKVONotification)

- (void)addObserver:(id)observer forKeyPath:(NSString *)keyPath selector:(SEL)selector userInfo:(id)userInfo options:(NSKeyValueObservingOptions)options;
- (void)removeObserver:(id)observer keyPath:(NSString *)keyPath selector:(SEL)selector;

@end