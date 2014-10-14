//
//  CSOverlayTransitionAnimator.h
//

#import <Foundation/Foundation.h>


@protocol CSOverlayTransitionProtocol <NSObject>

@optional
-(void)didDismissWithTouch:(UITapGestureRecognizer*)gestureRecogniser;

-(CGSize)sizeToPresent;

@end


@interface CSOverlayTransitionAnimator : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign, getter = isPresenting) BOOL presenting;

@end
