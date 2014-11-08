//
//  CSOverlayPushTransitionAnimator.h
//  CycleStreets
//
//  Created by Neil Edwards on 06/11/2014.
//  Copyright (c) 2014 CycleStreets Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CSOverlayPushTransitionAnimatorProtocol <NSObject>

-(CGRect)presentationContentFrame;

@optional
-(void)didDismissWithTouch:(UIGestureRecognizer*)gestureRecogniser;

@end


@interface CSOverlayPushTransitionAnimator : NSObject<UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign, getter = isPresenting) BOOL presenting;

@end
