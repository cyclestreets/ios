//
//  HCSRouteDetailViewController.m
//  CycleStreets
//
//  Created by Neil Edwards on 21/01/2014.
//  Copyright (c) 2014 CycleStreets Ltd. All rights reserved.
//

#import "HCSRouteDetailViewController.h"

@interface HCSRouteDetailViewController ()

@end

@implementation HCSRouteDetailViewController

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
 * @description			SEGUE METHODS
 ***********************************************/
//

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    
    
}


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
