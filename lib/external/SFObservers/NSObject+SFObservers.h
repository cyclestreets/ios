//
//  Created by merowing2 on 3/25/12.
//
//
//
#import <Foundation/Foundation.h>
#import "SFObservers.h"

@interface NSObject (SFObservers)

- (BOOL)sf_removeObserver:(id)observer
forKeyPath:(NSString *)keyPath
context:(id)context
	   registeredKeyPaths:(NSMutableDictionary *)registeredKeyPaths;
@end