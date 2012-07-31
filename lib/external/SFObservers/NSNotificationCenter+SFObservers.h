//
//  Created by krzysztof.zablocki on 3/23/12.
//
//
//
#import <Foundation/Foundation.h>
#import "SFObservers.h"

@interface NSNotificationCenter (SFObservers)

- (BOOL)sf_removeObserver:(id)observer name:(NSString *)aName object:(id)anObject registeredNotifications:(NSMutableDictionary *)registeredNotifications;
@end