//
//  PhotoMapImageInfoViewController.m
//  CycleStreets
//
//  Created by Neil Edwards on 04/12/2012.
//  Copyright (c) 2012 CycleStreets Ltd. All rights reserved.
//

#import "PhotoMapImageInfoViewController.h"

@interface PhotoMapImageInfoViewController ()

@end

@implementation PhotoMapImageInfoViewController

//
/***********************************************
 * @description		NOTIFICATIONS
 ***********************************************/
//

-(void)listNotificationInterests{
    
	
	
	[super listNotificationInterests];
	
}

-(void)didReceiveNotification:(NSNotification*)notification{
	
	
	
}


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
    
    
    
}




//
/***********************************************
 * @description			UI EVENTS
 ***********************************************/
//





//
/***********************************************
 * @description			MEMORY
 ***********************************************/
//
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

@end
