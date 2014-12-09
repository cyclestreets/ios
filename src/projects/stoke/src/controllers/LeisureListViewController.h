//
//  LeisureListViewController.h
//  CycleStreets
//
//  Created by Neil Edwards on 25/11/2014.
//  Copyright (c) 2014 CycleStreets Ltd. All rights reserved.
//

#import "SuperViewController.h"

#import "CSOverlayTransitionAnimator.h"

typedef NS_ENUM(NSUInteger, LeisureListViewMode) {
	LeisureListViewModeDefault,
	LeisureListViewModeModal
	
};

@interface LeisureListViewController : SuperViewController<CSOverlayTransitionProtocol>


@property (nonatomic,assign)  LeisureListViewMode						viewMode;


-(void)didDismissWithTouch:(UIGestureRecognizer*)gestureRecogniser;


@end
