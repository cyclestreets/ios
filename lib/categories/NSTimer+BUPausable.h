//
//  NSTimer+BUPausable.h
//  CycleStreets
//
//  Created by Neil Edwards on 11/02/2014.
//  Copyright (c) 2014 CycleStreets Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSTimer (BUPausable)

@property (nonatomic) NSDate				*startDate; // initial start date

- (void)pauseOrResume;
- (BOOL)isPaused;


@end
