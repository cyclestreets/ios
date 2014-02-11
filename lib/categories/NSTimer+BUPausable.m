//
//  NSTimer+BUPausable.m
//  CycleStreets
//
//  Created by Neil Edwards on 11/02/2014.
//  Copyright (c) 2014 CycleStreets Ltd. All rights reserved.
//

#import "NSTimer+BUPausable.h"
#import <objc/runtime.h>

@interface NSTimer (BUPausablePrivate)

@property (nonatomic) NSNumber				*timeDeltaNumber;  // paused value

@property (nonatomic) NSNumber				*currentRunningTime; // time offset when paused


@end



@implementation NSTimer (BUPausable)



- (NSNumber *)timeDeltaNumber{
	
    return objc_getAssociatedObject(self, @selector(timeDeltaNumber));
}

- (void)setTimeDeltaNumber:(NSNumber *)newtimeDeltaNumber{
	
    objc_setAssociatedObject(self, @selector(timeDeltaNumber), newtimeDeltaNumber, OBJC_ASSOCIATION_RETAIN);
}

- (NSNumber* )currentRunningTime{
	
    return objc_getAssociatedObject(self, @selector(currentRunningTime));
}

- (void)setCurrentRunningTime:(NSNumber *)newcurrentrunningtime{
	
    objc_setAssociatedObject(self, @selector(currentRunningTime), newcurrentrunningtime, OBJC_ASSOCIATION_RETAIN);
}


- (NSDate* )startDate{
	
    return objc_getAssociatedObject(self, @selector(startDate));
}

- (void)setStartDate:(NSDate *)newstartDate{
	
    objc_setAssociatedObject(self, @selector(startDate), newstartDate, OBJC_ASSOCIATION_RETAIN);
}


- (void)pauseOrResume
{
    if ([self isPaused]) {
        self.fireDate = [[NSDate date] dateByAddingTimeInterval:[self.timeDeltaNumber doubleValue]];
		self.startDate=[[NSDate date] dateByAddingTimeInterval:0-[self.currentRunningTime doubleValue]];
        self.timeDeltaNumber = nil;
    }
    else {
        NSTimeInterval interval = [[self fireDate] timeIntervalSinceNow];
		self.currentRunningTime=@([[NSDate date] timeIntervalSinceDate:self.startDate]);
        self.timeDeltaNumber = @(interval);
        self.fireDate = [NSDate distantFuture];
    }
}

- (BOOL)isPaused
{
    return (self.timeDeltaNumber != nil);
}




@end
