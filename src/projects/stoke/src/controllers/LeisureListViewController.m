//
//  LeisureListViewController.m
//  CycleStreets
//
//  Created by Neil Edwards on 25/11/2014.
//  Copyright (c) 2014 CycleStreets Ltd. All rights reserved.
//

#import "LeisureListViewController.h"

#import "RouteManager.h"
#import "UserRouteCellView.h"
#import "UserAccount.h"
#import "CSUserRouteVO.h"
#import "CSUserRoutePagination.h"
#import "StringUtilities.h"

@interface LeisureListViewController()<UITableViewDataSource,UITableViewDelegate>


@property (nonatomic,strong)  NSMutableArray								*dataProvider;

@property (nonatomic,weak) IBOutlet  UITableView							*tableView;
@property (weak, nonatomic) IBOutlet UILabel                                *routeCountLabel;

@end


@implementation LeisureListViewController

//
/***********************************************
 * @description		NOTIFICATIONS
 ***********************************************/
//

-(void)listNotificationInterests{
	
	[self initialise];
	
	[notifications addObject:ROUTESFORUSERRESPONSE];
	
	
	[super listNotificationInterests];
	
}

-(void)didReceiveNotification:(NSNotification*)notification{
	
	[super didReceiveNotification:notification];
	NSString *name=notification.name;
	
	if([name isEqualToString:ROUTESFORUSERRESPONSE]){
		
		[self refreshUIFromDataProvider:notification.userInfo];
		
	}
	
	
}


#pragma mark - Data responses


-(void)refreshUIFromDataProvider:(NSDictionary*)result{
	
	NSString *state=result[STATE];
	
	if([state isEqualToString:SUCCESS]){
		
		self.dataProvider=[UserAccount sharedInstance].userRoutes;
		
		
		if(_dataProvider.count==0){
			
			[self showViewOverlayForType:kViewOverlayTypeNoResults show:YES withMessage:@"noresults_ROUTESFORUSER" withIcon:ROUTESFORUSER];
			
		}else{
			
			[self showViewOverlayForType:kViewOverlayTypeNone show:NO withMessage:nil];
			
			[_tableView reloadData];
            
			CSUserRoutePagination *pagination=result[RESPONSE];
			_routeCountLabel.text=NSStringFormat(@"%i of %i",pagination.currentCount,pagination.total);
			
		}
		
	}else{
		
		[self showViewOverlayForType:kViewOverlayTypeNoResults show:YES withMessage:@"noresults_ROUTESFORUSER" withIcon:ROUTESFORUSER];
		
	}
	
}


//
/***********************************************
 * @description			VIEW METHODS
 ***********************************************/
//

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	if(_viewMode==LeisureListViewModeModal)
		self.UIType=UITYPE_MODALTABLEVIEWUI;
	
	self.tableView.rowHeight=[UserRouteCellView rowHeight];
	[_tableView registerNib:[UserRouteCellView nib] forCellReuseIdentifier:[UserRouteCellView cellIdentifier]];
	
	[self createPersistentUI];
}


-(void)viewWillAppear:(BOOL)animated{
	
	[[UserAccount sharedInstance] loadRoutesForUser:YES pagedDirectionisNewer:NO pagedID:nil];
	
	[self createNonPersistentUI];
	
	[super viewWillAppear:animated];
}


-(void)createPersistentUI{
	
}

-(void)createNonPersistentUI{
	
	
	
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
	
	UserRouteCellView *cell=[tableView dequeueReusableCellWithIdentifier:[UserRouteCellView cellIdentifier]];
	
	NSInteger row=indexPath.row;
	CSUserRouteVO *dp=_dataProvider[row];
	
	cell.dataProvider=dp;
	[cell populate];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	
	NSInteger row=indexPath.row;
	CSUserRouteVO *dp=_dataProvider[row];
	
	if(_viewMode==LeisureListViewModeDefault){
		
		//TODO:  possible push detail view instead
		[[RouteManager sharedInstance] loadRouteForRouteId:dp.routeid];
		
	}else{
		
		[[RouteManager sharedInstance] loadRouteForRouteId:dp.routeid];
		[self dismissView];
	}
	
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
