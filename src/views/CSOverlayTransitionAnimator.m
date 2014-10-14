//
//  CSOverlayTransitionAnimator.m

#import "CSOverlayTransitionAnimator.h"

#import "UIView+Additions.h"
#import "ViewUtilities.h"

@implementation CSOverlayTransitionAnimator

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return 0.4f;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
	
    // Grab the from and to view controllers from the context
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController<CSOverlayTransitionProtocol> *toViewController =(UIViewController<CSOverlayTransitionProtocol>*)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
	
    if (self.presenting) {
		
		
        fromViewController.view.userInteractionEnabled = NO;
        
        [transitionContext.containerView addSubview:fromViewController.view];
		
		UIView *touchView=[[UIView alloc]initWithFrame:fromViewController.view.frame];
		touchView.backgroundColor=[UIColor blackColor];
		touchView.alpha=0;
		UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:toViewController action:@selector(didDismissWithTouch:)];
		[touchView addGestureRecognizer:tapGestureRecognizer];
		[transitionContext.containerView addSubview:touchView];
		
        [transitionContext.containerView addSubview:toViewController.view];
		
		toViewController.view.size=[toViewController sizeToPresent];
		[ViewUtilities alignView:toViewController.view inRect:fromViewController.view.frame :BUCenterAlignMode :BUCenterAlignMode];
		toViewController.view.x+=320;
		
		[UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
			fromViewController.view.tintAdjustmentMode = UIViewTintAdjustmentModeDimmed;
			[ViewUtilities alignView:toViewController.view inRect:fromViewController.view.frame :BUCenterAlignMode :BUCenterAlignMode];
			touchView.alpha=0.3;
		} completion:^(BOOL finished) {
			[transitionContext completeTransition:YES];
		}];
        
		
		
    }else {
		
        
        [transitionContext.containerView addSubview:toViewController.view];
		
		UIView *touchView=[[UIView alloc]initWithFrame:toViewController.view.frame];
		touchView.backgroundColor=[UIColor blackColor];
		touchView.alpha=0.3;
		[transitionContext.containerView addSubview:touchView];
		
        [transitionContext.containerView addSubview:fromViewController.view];
		
		CGRect finalFrame=fromViewController.view.frame;
        finalFrame.origin.x += 320;
		
		[UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0 options:UIViewAnimationOptionCurveLinear animations:^{
			toViewController.view.tintAdjustmentMode = UIViewTintAdjustmentModeAutomatic;
			fromViewController.view.frame = finalFrame;
			touchView.alpha=0;
		} completion:^(BOOL finished) {
			toViewController.view.userInteractionEnabled = YES;
			[transitionContext completeTransition:YES];
		}];
		
	}
}

@end