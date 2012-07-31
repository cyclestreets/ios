//
//  ExpandedTabBarController.m
//  RedNoseDay
//
//  Created by Neil Edwards on 10/11/2010.
//  Copyright 2010 buffer. All rights reserved.
//

//  ExpandedTabBarController.m

#import "ExpandedTabBarController.h"
#import "GlobalUtilities.h"


@implementation ExpandedTabBarController
@synthesize customView;
@synthesize container;
@synthesize customViewFrame;
@synthesize containerFrame;
@synthesize tabBarFrame;
@synthesize delegate;
@synthesize willReplaceTabBar;
@synthesize isCustomViewShown;

/***********************************************************/
// dealloc
/***********************************************************/
- (void)dealloc
{
    delegate = nil;
	
}





- (void)viewDidLoad {
	
	self.view.backgroundColor=[UIColor blackColor];
	
    [super viewDidLoad];
	
	
	CGRect initFrame=self.tabBar.frame;
	if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad){
		// oddness, even if iPad is in landscape the tabbars frame will be it's portrait value so we need override
		self.tabBarFrame=CGRectMake(initFrame.origin.x, DEVICESCREEN_HEIGHT-initFrame.size.height, DEVICESCREEN_WIDTH, initFrame.size.height);
	}else {
		self.tabBarFrame=initFrame;
	}

	willReplaceTabBar=NO;
	isCustomViewShown=NO;
	
	// A UITabBarController's view has two subviews: the UITabBar and a container UITransitionView that is
	// used to hold the child views. Save a reference to the container.
	for (UIView *view in self.view.subviews) {
		if (![view isKindOfClass:[UITabBar class]]) {
			self.container = view;
			self.containerFrame = view.frame;
		}
	}
}

- (void)viewDidUnload {
	self.customView = nil;
	self.delegate = nil;
	self.container = nil;
	[super viewDidUnload];
}



-(void)assignCustomView:(UIView*)iview{
	self.customView = iview;
	self.customViewFrame = customView.frame;
}


- (void)showCustomView:(BOOL)animated {
	
	if (isCustomViewShown==YES)
		return;
		
	if (willReplaceTabBar==NO) {
		
		CGFloat containerHeight = containerFrame.size.height;
		CGFloat customViewHeight = customViewFrame.size.height;
		
		CGRect cframe=CGRectMake(0.0,containerHeight,DEVICESCREEN_WIDTH,customViewHeight);
		customView.frame = cframe;
		[self.view insertSubview:customView atIndex:1];
		
		if(animated==YES){
			[UIView beginAnimations:nil context:nil];
			[UIView setAnimationBeginsFromCurrentState:YES];
			[UIView setAnimationDuration:0.4];
			[UIView setAnimationDidStopSelector:@selector(showComplete: finished: context:)];
		}
		
		// Resize the frame of the container to add space for the customView
		container.frame = CGRectMake(0.0,0.0,DEVICESCREEN_WIDTH,containerHeight - 42);
		// Place the customView above the tab bar but below the container
		customView.frame = CGRectMake(0.0,containerHeight - customViewHeight,DEVICESCREEN_WIDTH,customViewHeight);
		if(animated==YES)
		[UIView commitAnimations];
		
	}else {
		
		
		CGFloat customViewHeight = customViewFrame.size.height;
		CGRect customframe=CGRectMake(0.0,tabBarFrame.origin.y+tabBarFrame.size.height,DEVICESCREEN_WIDTH,customViewHeight);
		customView.frame = customframe;
		[self.view insertSubview:customView atIndex:1];
		
		if(animated==YES){
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationBeginsFromCurrentState:YES];
		[UIView setAnimationDuration:0.4];
		[UIView setAnimationDidStopSelector:@selector(showComplete: finished: context:)];
		}
		
		CGRect cframe=CGRectMake(0.0,tabBarFrame.origin.y,DEVICESCREEN_WIDTH,customViewHeight);
		CGRect tframe=CGRectMake(0.0,tabBarFrame.origin.y+tabBarFrame.size.height,tabBarFrame.size.width,tabBarFrame.size.height);
		customView.frame=cframe;
		self.tabBar.frame=tframe;
		
		if(animated==YES)
		[UIView commitAnimations];
		
		
	}
	
	isCustomViewShown=YES;

}

- (void)hideCustomView:(BOOL)animated {
	
	if(isCustomViewShown==NO)
		return;
	
	if (willReplaceTabBar==NO) {
		if(animated==YES){
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationBeginsFromCurrentState:YES];
		[UIView setAnimationDuration:0.4];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(hideComplete: finished: context:)];
		}
		
		container.frame = CGRectMake(0.0,0.0,DEVICESCREEN_WIDTH,containerFrame.size.height);
		customView.frame = CGRectMake(0.0,DEVICESCREEN_HEIGHT,DEVICESCREEN_WIDTH,customViewFrame.size.height);
		if(animated==YES)
		[UIView commitAnimations];
		
	}else {
		if(animated==YES){
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationBeginsFromCurrentState:YES];
		[UIView setAnimationDuration:0.4];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(hideComplete: finished: context:)];
		}
		
		self.tabBar.frame = tabBarFrame;
		customView.frame = CGRectMake(0.0,tabBarFrame.origin.y+tabBarFrame.size.height,DEVICESCREEN_WIDTH,customViewFrame.size.height);
		
		if(animated==YES)
		[UIView commitAnimations];
		
		if(animated==NO)
			isCustomViewShown=NO;
	}

	
	
}

-(void)showComplete:(NSString *)animationID finished:(BOOL)finished context:(void *)context{
	isCustomViewShown=YES;
}

-(void)hideComplete:(NSString *)animationID finished:(BOOL)finished context:(void *)context{
	isCustomViewShown=NO;
	// Remove the customView, might be not required
	[customView removeFromSuperview];
	
}


@end