//
//  LeisureListViewController.m
//  CycleStreets
//
//  Created by Neil Edwards on 25/11/2014.
//  Copyright (c) 2014 CycleStreets Ltd. All rights reserved.
//

#import "LeisureListViewController.h"

@interface LeisureListViewController()<UITableViewDataSource,UITableViewDelegate>


@property (nonatomic,strong)  NSMutableArray								*dataProvider;

@property (nonatomic,weak) IBOutlet  UITableView							*tableView;

@end


@implementation LeisureListViewController

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
	
	self.UIType=UITYPE_MODALTABLEVIEWUI;
	
	[self createPersistentUI];
}


-(void)viewWillAppear:(BOOL)animated{
	
	[self createNonPersistentUI];
	
	[super viewWillAppear:animated];
}


-(void)createPersistentUI{
	
}

-(void)createNonPersistentUI{
	
	if(_dataProvider.count==0){
		
		[self showViewOverlayForType:kViewOverlayTypeNoResults show:YES withMessage:@"noresults_LEISUREROUTES" withIcon:@"LEISUREROUTES"];
		
	}else{
		
		[self showViewOverlayForType:kViewOverlayTypeNone show:NO withMessage:nil];
		
	}
	
}


#pragma mark UITableView
//
/***********************************************
 * @description			UITABLEVIEW DELEGATES
 ***********************************************/
//

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_dataProvider count];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}


-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    
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



//
/***********************************************
 * @description			SEGUE METHODS
 ***********************************************/
//

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
	
	
	
}


#pragma mark - CSOverlayTransitionProtocol

-(void)didDismissWithTouch:(UIGestureRecognizer*)gestureRecogniser{
	
	[self dismissView];
	
}

-(CGSize)preferredContentSize{
	
	return CGSizeMake(280,340);
}

-(CGRect)presentationContentFrame{
	
	return self.view.superview.frame;
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
