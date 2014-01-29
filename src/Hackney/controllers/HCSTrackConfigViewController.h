//
//  HCSTrackConfigViewController.h
//  CycleStreets
//
//  Created by Neil Edwards on 20/01/2014.
//  Copyright (c) 2014 CycleStreets Ltd. All rights reserved.
//

#import "SuperViewController.h"
#import "TripPurposeDelegate.h"

@interface HCSTrackConfigViewController : SuperViewController<TripPurposeDelegate>



- (void)displayUploadedTripMap;

@end
