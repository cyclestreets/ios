//
//  HCSUserDetailsViewController.h
//  CycleStreets
//
//  Created by Neil Edwards on 27/01/2014.
//  Copyright (c) 2014 CycleStreets Ltd. All rights reserved.
//

#import "SuperViewController.h"
#import "TripPurposeDelegate.h"

enum  {
	HCSUserDetailsViewModeShow,
	HCSUserDetailsViewModeSave
	
};
typedef int HCSUserDetailsViewMode;

@interface HCSUserDetailsViewController : SuperViewController


@property (nonatomic, assign) id <TripPurposeDelegate>				tripDelegate;

@property (nonatomic,assign)  HCSUserDetailsViewMode				viewMode;

@end
