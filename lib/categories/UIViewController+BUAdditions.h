//
//  UITableViewController+BUAdditions.h
//  Seamless
//
//  Created by Neil Edwards on 16/09/2014.
//  Copyright (c) 2014 Neil Edwards. All rights reserved.
//

#import <UIKit/UIKit.h>

// Add some of the helper methods of BUViewcontroller so we can use static TableViewControllers

@interface UIViewController (BUAdditions)


-(void)showInlineErrorForType:(NSString*)errorType  show:(BOOL)show addtionalMessage:(NSString*)message offset:(CGPoint)offset;


- (UIView *)viewForTransitionContext:(id<UIViewControllerContextTransitioning>)transitionContext;

@end
