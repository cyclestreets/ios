//
//  GANTracker.h
//  Google Analytics iPhone SDK.
//  Version: 1.1
//
//  Copyright 2009 Google Inc. All rights reserved.
//

extern NSString* const kGANTrackerErrorDomain;
extern NSInteger const kGANTrackerNotStartedError;
extern NSInteger const kGANTrackerInvalidInputError;
extern NSInteger const kGANTrackerEventsPerSessionLimitError;

@protocol GANTrackerDelegate;
typedef struct __GANTrackerPrivate GANTrackerPrivate;

// Google Analytics tracker interface. Tracked pageviews and events are stored
// in a persistent store and dispatched in the background to the server.
@interface GANTracker : NSObject {
 @private
  GANTrackerPrivate *private_;
}

// Singleton instance of this class for convenience.
+ (GANTracker *)sharedTracker;

// Start the tracker by specifying a Google Analytics account ID and a
// dispatch period (in seconds) to dispatch events to the server
// (or -1 to dispatch manually). An optional delegate may be
// supplied.
- (void)startTrackerWithAccountID:(NSString *)accountID
                   dispatchPeriod:(NSInteger)dispatchPeriod
                         delegate:(id<GANTrackerDelegate>)delegate;

// Stop the tracker.
- (void)stopTracker;

// Track a page view. The pageURL must start with a forward
// slash '/'. Returns YES on success or NO on error (with outErrorOrNULL
// set to the specific error).
- (BOOL)trackPageview:(NSString *)pageURL
            withError:(NSError **)error;

// Track an event. The category and action are required. The label and
// value are optional (specify nil for no label and -1 or any negative integer
// for no value). Returns YES on success or NO on error (with outErrorOrNULL
// set to the specific error).
- (BOOL)trackEvent:(NSString *)category
            action:(NSString *)action
             label:(NSString *)label
             value:(NSInteger)value
         withError:(NSError **)error;

// Manually dispatch pageviews/events to the server. Returns YES if
// a new dispatch starts.
- (BOOL)dispatch;

@end

@protocol GANTrackerDelegate <NSObject>

// Invoked when a dispatch completes. Reports the number of events
// dispatched and the number of events that failed to dispatch. Failed
// events will be retried on next dispatch.
- (void)trackerDispatchDidComplete:(GANTracker *)tracker
                  eventsDispatched:(NSUInteger)eventsDispatched
              eventsFailedDispatch:(NSUInteger)eventsFailedDispatch;

@end
