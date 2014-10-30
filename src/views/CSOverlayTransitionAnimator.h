//
//  CSOverlayTransitionAnimator.h
//

#import <Foundation/Foundation.h>


@protocol CSOverlayTransitionProtocol <NSObject>

@optional
-(void)didDismissWithTouch:(UIGestureRecognizer*)gestureRecogniser;

@end


@interface CSOverlayTransitionAnimator : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign, getter = isPresenting) BOOL presenting;

@end
