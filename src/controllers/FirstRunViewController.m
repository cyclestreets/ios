//
//  FirstRunViewController.m
//  CycleStreets
//
//  Created by Neil Edwards on 05/01/2015.
//  Copyright (c) 2015 CycleStreets Ltd. All rights reserved.
//

#import "FirstRunViewController.h"
#import "UIView+Additions.h"

@interface FirstRunViewController()

@property (weak, nonatomic) IBOutlet UIScrollView *contentScrollView;
@property (weak, nonatomic) IBOutlet UIView *contentView;


@end

@implementation FirstRunViewController




//
/***********************************************
 * @description			VIEW METHODS
 ***********************************************/
//

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	[self createPersistentUI];
}


-(void)viewWillAppear:(BOOL)animated{
	
	[self createNonPersistentUI];
	
	[super viewWillAppear:animated];
}


-(void)createPersistentUI{
	
}

-(void)createNonPersistentUI{
	
	[_contentScrollView setContentSize:_contentView.size];
	
}




//
/***********************************************
 * @description			UI EVENTS
 ***********************************************/
//




-(IBAction)didSelectCancelButton:(id)sender{
	
	[self dismissView];
}


-(void)dismissView{
	
	[self dismissViewControllerAnimated:YES completion:nil];
	
}



#pragma mark - CSOverlayTransitionProtocol

-(void)didDismissWithTouch:(UIGestureRecognizer*)gestureRecogniser{
	
	[self dismissView];
	
}

-(CGSize)preferredContentSize{
	
	return CGSizeMake(280,400);
}

-(CGRect)presentationContentFrame{
	
	return self.view.superview.frame;
}

@end
