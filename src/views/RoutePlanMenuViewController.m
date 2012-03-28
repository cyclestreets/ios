//
//  RoutePlanMenuViewController.m
//  CycleStreets
//
//  Created by neil on 27/03/2012.
//  Copyright (c) 2012 CycleStreets Ltd. All rights reserved.
//

#import "RoutePlanMenuViewController.h"

@implementation RoutePlanMenuViewController



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.contentSizeForViewInPopover = self.view.frame.size;
    }
    return self;
}




- (void)viewDidLoad
{
    [super viewDidLoad];
}





- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
