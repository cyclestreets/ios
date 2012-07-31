//
//  ExpandedTabBarController.h
//  RedNoseDay
//
//  Created by Neil Edwards on 10/11/2010.
//  Copyright 2010 buffer. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ExpandedTabBarControllerDelegate <UITabBarControllerDelegate>

@optional
- (UIView *)getcustomView;
@end

// UITabBarController that has room for a persistent UIView above or replacing the TabBar
@interface ExpandedTabBarController : UITabBarController {
	UIView								*customView;
	UIView								*container;
	CGRect								customViewFrame;
	CGRect								containerFrame;
	CGRect								tabBarFrame;
	id <ExpandedTabBarControllerDelegate> __unsafe_unretained delegate;
	BOOL								willReplaceTabBar;
	BOOL								isCustomViewShown;
}

@property (nonatomic, strong)		IBOutlet UIView		* customView;
@property (nonatomic, strong)		IBOutlet UIView		* container;
@property (nonatomic)		CGRect		 customViewFrame;
@property (nonatomic)		CGRect		 containerFrame;
@property (nonatomic)		CGRect		 tabBarFrame;
@property (nonatomic, unsafe_unretained)		id <ExpandedTabBarControllerDelegate>		 delegate;
@property (nonatomic)		BOOL		 willReplaceTabBar;
@property (nonatomic)		BOOL		 isCustomViewShown;

// Shows the customView
- (void)showCustomView:(BOOL)animated;
// Hides the customView. 
- (void)hideCustomView:(BOOL)animated;

-(void)assignCustomView:(UIView*)iview;
@end
