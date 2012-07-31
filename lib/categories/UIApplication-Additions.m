//
//  UIApplication-Additions.m
//
//
//  Created by Neil Edwards on 07/10/2010.
//  Copyright 2010 Buffer. All rights reserved.
//

#import "UIApplication-Additions.h"


static NSInteger __activityCount = 0;

@implementation UIApplication (Additions)
- (void)showNetworkActivityIndicator {
    if ( __activityCount == 0 ) {
        [self setNetworkActivityIndicatorVisible:YES];
    }
    __activityCount++;
}
- (void)hideNetworkActivityIndicator {
    __activityCount--;
    if ( __activityCount == 0 ) {
        [self setNetworkActivityIndicatorVisible:NO];
    }    
}
@end
