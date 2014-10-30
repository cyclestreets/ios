//
//  CSOverlayTransitionAnimator.m

#import "CSOverlayTransitionAnimator.h"

#import "UIView+Additions.h"
#import "ViewUtilities.h"
#import "UIViewController+BUAdditions.h"
#import "GenericConstants.h"

#import <QuartzCore/QuartzCore.h>

@implementation CSOverlayTransitionAnimator

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return 0.4f;
}

#define kTouchViewTag 7777
- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
	
    // Grab the from and to view controllers from the context
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController<CSOverlayTransitionProtocol> *toViewController =(UIViewController<CSOverlayTransitionProtocol>*)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
	
	UIView *fromView=[fromViewController viewForTransitionContext:transitionContext];
	UIView *toView=[toViewController viewForTransitionContext:transitionContext];
	
	UIView *touchView;
	
    if (self.presenting) {
		
		// from
        fromViewController.view.userInteractionEnabled = NO;
        [transitionContext.containerView addSubview:fromView];
		
		// background touchview
		touchView=[[UIView alloc]initWithFrame:fromViewController.view.frame];
		touchView.backgroundColor=[UIColor blackColor];
		touchView.tag=kTouchViewTag;
		touchView.alpha=0;
		UISwipeGestureRecognizer *swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:toViewController action:@selector(didDismissWithTouch:)];
		UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:toViewController action:@selector(didDismissWithTouch:)];
		swipeGestureRecognizer.direction=UISwipeGestureRecognizerDirectionRight;
		[touchView addGestureRecognizer:tapGestureRecognizer];
		[touchView addGestureRecognizer:swipeGestureRecognizer];
		[transitionContext.containerView addSubview:touchView];
		
		// to
		toView.layer.cornerRadius=6;
		toView.size=[toViewController preferredContentSize];
		[ViewUtilities alignView:toView inRect:fromViewController.view.frame :BUCenterAlignMode :BUCenterAlignMode];
		toViewController.view.x+=SCREENWIDTH;
		[transitionContext.containerView addSubview:toView];
		
		
		// animation
		[UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
			fromViewController.view.tintAdjustmentMode = UIViewTintAdjustmentModeDimmed;
			[ViewUtilities alignView:toView inRect:fromViewController.view.frame :BUCenterAlignMode :BUCenterAlignMode];
			touchView.alpha=0.3;
		} completion:^(BOOL finished) {
			[transitionContext completeTransition:YES];
		}];
        
		
		
    }else {
		
        
        [transitionContext.containerView addSubview:toView];
		
		touchView=[[transitionContext containerView] viewWithTag:kTouchViewTag];
		
        [transitionContext.containerView addSubview:fromView];
		
		CGRect finalFrame=fromView.frame;
        finalFrame.origin.x += SCREENWIDTH;
		
		[UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0 options:UIViewAnimationOptionCurveLinear animations:^{
			toViewController.view.tintAdjustmentMode = UIViewTintAdjustmentModeAutomatic;
			fromView.frame = finalFrame;
			touchView.alpha=0;
		} completion:^(BOOL finished) {
			toViewController.view.userInteractionEnabled = YES;
			[transitionContext completeTransition:YES];
		}];
		
	}
}

@end