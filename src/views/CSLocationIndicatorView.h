//
//  CSLocationIndicatorView.h
//  CycleStreets
//
//  Created by Neil Edwards on 09/07/2013.
//  Copyright (c) 2013 CycleStreets Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SVPulsingAnnotationView.h"


@interface CSLocationIndicatorView : UIView

@property (nonatomic, strong) NSObject <GPSLocationProvider> *locationProvider;

	
@end

