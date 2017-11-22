    //
//  RoutesViewContoller.m
//  CycleStreets
//
//  Created by Neil Edwards on 09/03/2011.
//  Copyright 2011 CycleStreets Ltd. All rights reserved.
//

#import "RoutesViewController.h"
#import "AppConstants.h"
#import "ViewUtilities.h"
#import "StyleManager.h"
#import "RouteListViewController.h"
#import "RouteManager.h"
#import "ButtonUtilities.h"
#import "UIView+Additions.h"
#import "GenericConstants.h"

@import PureLayout;
#import "PureLayout+Additions.h"

@interface RoutesViewController()


@property (nonatomic, strong)	IBOutlet BorderView				*controlView;
@property (nonatomic, strong)	BUSegmentedControl				*routeTypeControl;
@property (nonatomic, strong)	IBOutlet UIButton				*selectedRouteButton;

@property (strong, nonatomic) 	 UIView                 	    *containerView;


@property (nonatomic, strong)	NSMutableArray					*dataTypeArray;

@property (nonatomic, strong)	NSMutableDictionary				*viewStack;
@property (nonatomic, strong)	NSArray							*childControllerData;
@property (nonatomic,strong)  NSString							*activeState;
@property (nonatomic,strong)  SuperViewController				* activeController;

@property (nonatomic, assign)	int								activeIndex;
@property (nonatomic, strong)	CSRouteDetailsViewController					*routeSummary;

-(IBAction)selectedRouteButtonSelected:(id)sender;
-(void)selectedRouteUpdated;

@end


@implementation RoutesViewController


//
/***********************************************
 * @description		NOTIFICATIONS
 ***********************************************/
//

-(void)listNotificationInterests{
	
	[self initialise];
	
	displaysConnectionErrors=NO;
    
    [notifications addObject:CSROUTESELECTED];
	
	[super listNotificationInterests];
	
}

-(void)didReceiveNotification:(NSNotification*)notification{
	
	[super didReceiveNotification:notification];
	
    if([notification.name isEqualToString:CSROUTESELECTED]){
        [self selectedRouteUpdated];
    }
	
}


//
/***********************************************
 * @description			DATA UPDATING
 ***********************************************/
//

-(void)refreshUIFromDataProvider{
	
		
}

-(void)selectedRouteUpdated{
    
    BOOL selectedRouteExists=[RouteManager sharedInstance].selectedRoute!=nil;
    
    _selectedRouteButton.enabled=selectedRouteExists;
    
    if(self.navigationController.topViewController==_routeSummary){
        if(selectedRouteExists==NO){
            [self.navigationController popToRootViewControllerAnimated:NO];
        }
    }
	
    
}


//
/***********************************************
 * @description			UI CREATION
 ***********************************************/
//

- (void)viewDidLoad {
	
	_activeIndex=-1;
	
    [super viewDidLoad];
	
	[self createPersistentUI];
	
	// sets the initial sub view
	int startIndex=1;
	if([SavedRoutesManager sharedInstance].favouritesdataProvider.count>0 )
		startIndex=0;
	
	[_routeTypeControl setSelectedSegmentIndex:startIndex];
	
}


-(void)createPersistentUI{
	
	
	self.containerView=[[UIView alloc]initForAutoLayout];
	[self.view addSubview:_containerView];
	[_containerView autoPinEdgesToSuperviewEdgesExcludingEdge:ALEdgeTop];
	[_containerView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_controlView];
	
	
	_controlView.backgroundColor=[UIColor whiteColor];
	[_controlView drawBorderwithColor:UIColorFromRGB(0xCCCCCC) andStroke:1 left:NO right:NO top:NO bottom:YES];
	
	
	UIStackView *controlcontainer=[[UIStackView alloc] initForAutoLayout];
	controlcontainer.axis=UILayoutConstraintAxisHorizontal;
	controlcontainer.alignment=UIStackViewAlignmentCenter;
	controlcontainer.distribution=UIStackViewDistributionEqualSpacing;
	

	NSMutableArray *sdp = [[NSMutableArray alloc] initWithObjects:@"Favourites", @"Recent",  nil];
	_routeTypeControl=[[BUSegmentedControl alloc]initForAutoLayout];
	_routeTypeControl.dataProvider=sdp;
	_routeTypeControl.delegate=self;
	_routeTypeControl.itemWidth=80;
	[_routeTypeControl buildInterface];
	[controlcontainer addArrangedSubview:_routeTypeControl];
	
	self.selectedRouteButton=[ButtonUtilities UIPixateButtonWithWidth:120 height:32 styleId:@"orangeButton" text:@"Current Route"];
    [_selectedRouteButton addTarget:self action:@selector(selectedRouteButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
	
	[controlcontainer addArrangedSubview:_selectedRouteButton];
	[_controlView addSubview:controlcontainer];
	[controlcontainer autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
	
	
	self.viewStack=[NSMutableDictionary dictionary];
    
    self.childControllerData=@[@{ID: SAVEDROUTE_FAVS,CONTROLLER:[RouteListViewController className],@"isSectioned":@(NO)},
                               @{ID: SAVEDROUTE_RECENTS,CONTROLLER:[RouteListViewController className],@"isSectioned":@(YES)}];
	
	
	[self loadChildControllers];
}


-(void)viewWillAppear:(BOOL)animated{
	
	[super viewWillAppear:animated];
	
	[self createNonPersistentUI];
	
}

-(void)createNonPersistentUI{
	
    _selectedRouteButton.enabled=[[RouteManager sharedInstance] selectedRoute]!=nil;
	
}




#pragma mark - UIEvents

-(IBAction)selectedRouteButtonSelected:(id)sender{
    
    if([[RouteManager sharedInstance] selectedRoute]!=nil)
		[self doNavigationPush:@"RouteSummary" withDataProvider:[[RouteManager sharedInstance] selectedRoute] andIndex:-1];
    
}



-(IBAction)didSelectFetchRouteButton:(NSString*)type{
	
	
	__weak __typeof(&*self)weakSelf = self;
	
	UIAlertController *createAlert=[UIAlertController alertControllerWithTitle:@"Enter route number" message:@"Find a CycleStreets route by number" preferredStyle:UIAlertControllerStyleAlert];
	
	UIAlertAction *executeAction=[UIAlertAction actionWithTitle:OK style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
		
		[[RouteManager sharedInstance] loadRouteForRouteId:createAlert.textFields.firstObject.text];
		
		[_routeTypeControl setSelectedSegmentIndex:1];
		[weakSelf selectedIndexDidChange:1];
		
	}];
	
	UIAlertAction *cancelAction=[UIAlertAction actionWithTitle:CANCEL style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
		
	}];
	
	[createAlert addAction:executeAction];
	[createAlert addAction:cancelAction];
	[createAlert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
		textField.placeholder = @"Enter route number";
		textField.keyboardType = UIKeyboardTypeNumberPad;
		
	}];
	
	[self presentViewController:createAlert animated:YES completion:^{
		
	}];
	[createAlert.view layoutIfNeeded];
	
	
}


#pragma mark - Segment control

-(void)selectedIndexDidChange:(NSInteger)index{
	
    if(index!=-1){
		
		[self swapChildViewControllerToType:_childControllerData[index]];
	
	}
	
}




#pragma mark - Child controllers


-(void)loadChildControllers{
	
	
	for(NSDictionary *configDict in _childControllerData){
		
		RouteListViewController *controller=[[RouteListViewController alloc]initWithNibName:[RouteListViewController nibName] bundle:nil];
		
		[controller willMoveToParentViewController:self];
		
		[_containerView addSubview:controller.view];
		[controller.view autoPinEdgesToSuperviewEdges];
		
		[self addChildViewController:controller];
		[controller didMoveToParentViewController:self];
		
		controller.delegate=self;
		[controller setValue:configDict forKey:@"configDict"];
		[_viewStack setObject:controller forKey:configDict[ID]];
		
	}
	
	[_containerView layoutSubviews];
	
	
    NSDictionary *controllerDict=_childControllerData[1];
    NSString *controllerName=controllerDict[ID];
    self.activeState=controllerName;
    self.activeController=[self.childViewControllers objectAtIndex:1];
	
	[_activeController refreshUIFromDataProvider];
}


-(void)swapChildViewControllerToType:(NSDictionary*)dict{
    
    SuperViewController *_oldcontroller=_activeController;
    
    NSString *controller=dict[ID];
	
	if([controller isEqualToString:_activeState])
		return;
	
	
    self.activeState=controller;
	
    SuperViewController *_newcontroller=[_viewStack objectForKey:controller];
    [_oldcontroller willMoveToParentViewController:nil];
    
    [self transitionFromViewController:_oldcontroller toViewController:_newcontroller duration:0.2 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{} completion:^(BOOL finished) {
        [_newcontroller didMoveToParentViewController:self];
        self.activeController=_newcontroller;
		[_activeController refreshUIFromDataProvider];
    }];
    
    
}


-(NSDictionary*)childControllerDictForType:(NSString*)type{
	
	for(NSDictionary *dict in _childControllerData){
		
		if([dict[ID] isEqualToString:type]){
			return dict;
		}
		
	}
	return nil;
}


//
/***********************************************
 * @description			ViewController delegate method
 ***********************************************/
//
-(void)doNavigationPush:(NSString*)className withDataProvider:(id)data andIndex:(int)index{
    
    if([className isEqualToString:@"RouteSummary"]){
        
        if (self.routeSummary == nil) {
            self.routeSummary = [[CSRouteDetailsViewController alloc]init];
        }
        self.routeSummary.route = (RouteVO*)data;
		_routeSummary.dataType=index;
        [self showUniqueViewController:_routeSummary];
        
    }
    
}



//
/***********************************************
 * @description			GENERIC METHODS
 ***********************************************/
//

- (void)didReceiveMemoryWarning {
   [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}




@end
