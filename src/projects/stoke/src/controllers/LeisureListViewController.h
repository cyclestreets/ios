//
//  LeisureListViewController.h
//  CycleStreets
//
//  Created by Neil Edwards on 25/11/2014.
//  Copyright (c) 2014 CycleStreets Ltd. All rights reserved.
//

#import "SuperViewController.h"

#import "CSOverlayTransitionAnimator.h"

@interface LeisureListViewController : SuperViewController<CSOverlayTransitionProtocol>


-(void)didDismissWithTouch:(UIGestureRecognizer*)gestureRecogniser;


@end
