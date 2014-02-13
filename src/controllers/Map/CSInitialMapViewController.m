//
//  CSInitialMapViewController.m
//  CycleStreets
//
//  Created by Neil Edwards on 13/02/2014.
//  Copyright (c) 2014 CycleStreets Ltd. All rights reserved.
//

#import "CSInitialMapViewController.h"

@interface CSInitialMapViewController ()

@end

@implementation CSInitialMapViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    self = [super initWithCenterViewController:[storyboard instantiateViewControllerWithIdentifier:@"MapViewController"]
                            leftViewController:[storyboard instantiateViewControllerWithIdentifier:@"WayPointViewController"]];
    if (self) {
        self.panningMode=IIViewDeckNoPanning;
		self.centerhiddenInteractivity=IIViewDeckCenterHiddenNotUserInteractiveWithTapToClose;
		self.navigationControllerBehavior = IIViewDeckNavigationControllerIntegrated;
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
