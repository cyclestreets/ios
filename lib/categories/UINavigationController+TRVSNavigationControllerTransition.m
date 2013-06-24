//
//  UINavigationController+TRVSNavigationControllerTranslation.m
//  Daft Co.
//
//  Created by Travis Jeffery on 2012-10-21.
//
//

#import <QuartzCore/QuartzCore.h>
#import "UINavigationController+TRVSNavigationControllerTransition.h"

static CALayer *kTRVSCurrentLayer = nil;
static CALayer *kTRVSNextLayer = nil;
static NSTimeInterval const kTransitionDuration = .3f;

@interface TRVSNavigationControllerTransitionAnimiationDelegate : NSObject
- (void)animationDidStop:(CAAnimation *)animation finished:(BOOL)flag;
+ (TRVSNavigationControllerTransitionAnimiationDelegate *)sharedDelegate;
@end

@implementation TRVSNavigationControllerTransitionAnimiationDelegate

- (void)animationDidStop:(CAAnimation *)animation finished:(BOOL)flag
{
    [kTRVSCurrentLayer removeFromSuperlayer];
    [kTRVSNextLayer removeFromSuperlayer];
}

+ (TRVSNavigationControllerTransitionAnimiationDelegate *)sharedDelegate
{
    static dispatch_once_t onceToken;
    __strong static id _sharedDelegate = nil;
    dispatch_once(&onceToken, ^{
        _sharedDelegate = [[self alloc] init];
    });
    return _sharedDelegate;
}

@end


@implementation UINavigationController (TRVSNavigationControllerTransition)

- (void)pushViewControllerWithNavigationControllerTransition:(UIViewController *)viewController
{
    kTRVSCurrentLayer = [self _layerSnapshotWithTransform:CATransform3DIdentity];
    
    [self pushViewController:viewController animated:NO];
    
    kTRVSNextLayer = [self _layerSnapshotWithTransform:CATransform3DIdentity];
    kTRVSNextLayer.frame = (CGRect){{CGRectGetWidth(self.view.bounds), CGRectGetMinY(self.view.bounds)}, self.view.bounds.size};
    
    [self.view.layer addSublayer:kTRVSCurrentLayer];
    [self.view.layer addSublayer:kTRVSNextLayer];
    
    [CATransaction flush];
    
    [kTRVSCurrentLayer addAnimation:[self _animationWithTranslation:-CGRectGetWidth(self.view.bounds)] forKey:nil];
    [kTRVSNextLayer addAnimation:[self _animationWithTranslation:-CGRectGetWidth(self.view.bounds)] forKey:nil];
}

- (void)popViewControllerWithNavigationControllerTransition
{
    kTRVSCurrentLayer = [self _layerSnapshotWithTransform:CATransform3DIdentity];
    
    [self popViewControllerAnimated:NO];
    
    kTRVSNextLayer = [self _layerSnapshotWithTransform:CATransform3DIdentity];
    kTRVSNextLayer.frame = (CGRect){{-CGRectGetWidth(self.view.bounds), CGRectGetMinY(self.view.bounds)}, self.view.bounds.size};
    
    [self.view.layer addSublayer:kTRVSCurrentLayer];
    [self.view.layer addSublayer:kTRVSNextLayer];
    
    [CATransaction flush];
    
    [kTRVSCurrentLayer addAnimation:[self _animationWithTranslation:CGRectGetWidth(self.view.bounds)] forKey:nil];
    [kTRVSNextLayer addAnimation:[self _animationWithTranslation:CGRectGetWidth(self.view.bounds)] forKey:nil];
}

- (CABasicAnimation *)_animationWithTranslation:(CGFloat)translation
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    animation.toValue = [NSValue valueWithCATransform3D:CATransform3DTranslate(CATransform3DIdentity, translation, 0.f, 0.f)];
    animation.duration = kTransitionDuration;
    animation.delegate = [TRVSNavigationControllerTransitionAnimiationDelegate sharedDelegate];
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    return animation;
}

- (CALayer *)_layerSnapshotWithTransform:(CATransform3D)transform
{
	if (UIGraphicsBeginImageContextWithOptions){
        UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, NO, [UIScreen mainScreen].scale);
    }
	else {
        UIGraphicsBeginImageContext(self.view.bounds.size);
    }
	
	[self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *snapshot = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
    CALayer *snapshotLayer = [CALayer layer];
	snapshotLayer.transform = transform;
    snapshotLayer.anchorPoint = CGPointMake(1.f, 1.f);
    snapshotLayer.frame = self.view.bounds;
	snapshotLayer.contents = (id)snapshot.CGImage;
    return snapshotLayer;
}


@end
