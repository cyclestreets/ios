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
#import "CSTableLoadingCellView.h"
#import "CSOverlayPushTransitionAnimator.h"
#import "LeisureViewController.h"

@interface LeisureListViewController()<UITableViewDataSource,UITableViewDelegate,UIViewControllerTransitioningDelegate,CSOverlayPushTransitionAnimatorProtocol>


@property (nonatomic,strong)  NSMutableArray								*dataProvider;

@property (nonatomic,weak) IBOutlet  UITableView							*tableView;
@property (weak, nonatomic) IBOutlet UILabel                                *routeCountLabel;

@property (nonatomic,strong)  CSUserRoutePagination							*paginationProvider;

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
            
			self.paginationProvider=result[RESPONSE];
			_routeCountLabel.text=NSStringFormat(@"%i of %i",_dataProvider.count,_paginationProvider.total);
			
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
	[_tableView registerNib:[CSTableLoadingCellView nib] forCellReuseIdentifier:[CSTableLoadingCellView cellIdentifier]];
	
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
	
	NSInteger row=indexPath.row;
	
	if([self handleTableViewWillDisplayRowAtIndexPath:indexPath]){
		
		CSTableLoadingCellView *cell=[self dequeueReusableSpinnerCellForTableView:tableView indexPath:indexPath message:@"Loading" animating:YES];
		return cell;
		
	}else{
		
		UserRouteCellView *cell=[tableView dequeueReusableCellWithIdentifier:[UserRouteCellView cellIdentifier]];
		
		
		CSUserRouteVO *dp=_dataProvider[row];
		
		cell.dataProvider=dp;
		[cell populate];
		
		return cell;
		
	}
	
}


#pragma mark - Table loading cell support

- (CSTableLoadingCellView*)dequeueReusableSpinnerCellForTableView:(UITableView*)tableView indexPath:(NSIndexPath*)indexPath message:(NSString*)message animating:(BOOL)animating{
	
	CSTableLoadingCellView *cell = [tableView dequeueReusableCellWithIdentifier:[CSTableLoadingCellView cellIdentifier]];
	[cell updateLoadingText:message];
	[cell updateLoading:animating];
	
	return cell;
}

- (BOOL)handleTableViewWillDisplayRowAtIndexPath:(NSIndexPath*)indexPath{
	
	if (indexPath.row == [_dataProvider count] - 1 && _paginationProvider.total > [_dataProvider count]) {
			[[UserAccount sharedInstance] loadRoutesForUser:NO pagedDirectionisNewer:NO pagedID:_paginationProvider.bottomID];
		return YES;
	}
	return NO;
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


-(IBAction)didSelectCreateLeisureRouteButton:(id)sender{
	
	[self performSegueWithIdentifier:@"LeisureViewSegue" sender:self];
	
}


//
/***********************************************
 * @description			SEGUE METHODS
 ***********************************************/
//

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	
	[super prepareForSegue:segue sender:sender];
	
	if ([segue.identifier isEqualToString:@"LeisureViewSegue"]){
		
		LeisureViewController *controller=(LeisureViewController*)segue.destinationViewController;
		controller.waypointArray=_waypointArray;
		
		controller.transitioningDelegate = self;
		controller.modalPresentationStyle = UIModalPresentationCustom;
		
	}	
}


#pragma mark - CSOverlayTransitionProtocol

#pragma mark - UIViewControllerTransitioningDelegate Methods

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
																  presentingController:(UIViewController *)presenting
																	  sourceController:(UIViewController *)source {
	
	CSOverlayPushTransitionAnimator *animator = [CSOverlayPushTransitionAnimator new];
	animator.presenting = YES;
	return animator;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
	CSOverlayPushTransitionAnimator *animator = [CSOverlayPushTransitionAnimator new];
	return animator;
}


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
