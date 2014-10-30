//
//  UITableViewController+BUAdditions.m
//  Seamless
//
//  Created by Neil Edwards on 16/09/2014.
//  Copyright (c) 2014 Neil Edwards. All rights reserved.
//

#import "UIViewController+BUAdditions.h"
#import "ViewUtilities.h"
#import "BUInlineErrorView.h"
#import "UIView+Additions.h"
#import <objc/runtime.h>

static const char *inlineErrorViewKey = "inlineErrorViewKey";

@implementation UIViewController (BUAdditions)


-(void)showInlineErrorForType:(NSString*)errorType  show:(BOOL)show addtionalMessage:(NSString*)message offset:(CGPoint)offset{
    
    BUInlineErrorView *inlineErrorView = objc_getAssociatedObject(self, inlineErrorViewKey);
    if (!inlineErrorView)
    {
        inlineErrorView=[ViewUtilities loadInstanceOfView:[BUInlineErrorView class] fromNibNamed:@"BUInlineErrorView"];
        objc_setAssociatedObject(self, inlineErrorViewKey, inlineErrorView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    if(show==YES){
        
        [inlineErrorView showInlineErrorForType:errorType show:show addtionalMessage:message targetView:self.view offset:offset];
        inlineErrorView.width=self.view.width;
        
    }else{
        
        [self hideErrorOverlay];
        
    }
    
}


-(void)hideErrorOverlay{
    
    BUInlineErrorView *inlineErrorView = objc_getAssociatedObject(self, inlineErrorViewKey);
    if(inlineErrorView!=nil){
        [inlineErrorView hideError:YES];
    }
    
}


- (UIView *)viewForTransitionContext:(id<UIViewControllerContextTransitioning>)transitionContext
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
	if ([transitionContext respondsToSelector:@selector(viewForKey:)]) {
		NSString *key = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey] == self ? UITransitionContextFromViewKey : UITransitionContextToViewKey;
		return [transitionContext viewForKey:key];
	} else {
		return self.view;
	}
#else
	return self.view;
#endif
}


@end
