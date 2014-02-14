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
#import "FavouritesManager.h"
#import "UIView+Additions.h"
#import "GenericConstants.h"

@interface RoutesViewController()

@property (nonatomic, strong)	IBOutlet UIView					*titleHeaderView;
@property (nonatomic, strong)	IBOutlet BorderView				*controlView;
@property (nonatomic, strong)	BUSegmentedControl				*routeTypeControl;
@property (nonatomic, strong)	IBOutlet UIButton				*selectedRouteButton;

@property (nonatomic, strong)	NSMutableDictionary				*viewStack;
@property (nonatomic, strong)	NSArray							*childControllerData;
@property (nonatomic,strong)  NSString							*activeState;
@property (nonatomic,strong)  SuperViewController				* activeController;

@property (nonatomic, assign)	int								activeIndex;
@property (nonatomic, strong)	RouteSummary					*routeSummary;

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
	
	
	_controlView.backgroundColor=[[StyleManager sharedInstance] colorForType:@"controlbar"];
	[_controlView drawBorderwithColor:UIColorFromRGB(0x333333) andStroke:1 left:NO right:NO top:YES bottom:YES];
	
	LayoutBox *controlcontainer=[[LayoutBox alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH, CONTROLUIHEIGHT)];
	controlcontainer.fixedWidth=YES;
	controlcontainer.fixedHeight=YES;
	controlcontainer.itemPadding=15;
	controlcontainer.paddingLeft=15;
	controlcontainer.alignMode=BUCenterAlignMode;
	
	NSMutableArray *sdp = [[NSMutableArray alloc] initWithObjects:@"Favourites", @"Recent",  nil];
	_routeTypeControl=[[BUSegmentedControl alloc]init];
	_routeTypeControl.dataProvider=sdp;
	_routeTypeControl.delegate=self;
	_routeTypeControl.itemWidth=80;
	[_routeTypeControl buildInterface];
	[controlcontainer addSubview:_routeTypeControl];
	
	self.selectedRouteButton=[ButtonUtilities UIButtonWithWidth:120 height:28 type:@"orange" text:@"Current Route"];
    [_selectedRouteButton addTarget:self action:@selector(selectedRouteButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
	
	[controlcontainer addSubview:_selectedRouteButton];
	[_controlView addSubview:controlcontainer];
	
	
	self.viewStack=[NSMutableDictionary dictionary];
    
    self.childControllerData=@[@{ID: SAVEDROUTE_FAVS,CONTROLLER:[RouteListViewController className],@"isSectioned":@(NO)},
                               @{ID: SAVEDROUTE_RECENTS,CONTROLLER:[RouteListViewController className],@"isSectioned":@(YES)}];
	
	
	
}


-(void)viewWillAppear:(BOOL)animated{
	
	[super viewWillAppear:animated];
	
	[self createNonPersistentUI];
	
}

-(void)createNonPersistentUI{
	
	[self loadInitialChildView];
	
    _selectedRouteButton.enabled=[[RouteManager sharedInstance] selectedRoute]!=nil;
	
}




//
/***********************************************
 * @description		UI EVENTS
 ***********************************************/
//


-(IBAction)selectedRouteButtonSelected:(id)sender{
    
    if([[RouteManager sharedInstance] selectedRoute]!=nil)
    [self doNavigationPush:@"RouteSummary" withDataProvider:[[RouteManager sharedInstance] selectedRoute] andIndex:-1];
    
}



-(void)doNavigationSelector:(NSString*)type{
	
	
    if([type isEqualToString:RIGHT]){
		[ViewUtilities createTextEntryAlertView:@"Enter route number" fieldText:nil withMessage:@"Find a CycleStreets route by number" delegate:self];
	}
    
}


// Note: use of didDismissWithButtonIndex, as otherwise the HUD gets removed by the screen clear up performed by Alert 
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
	
	if(buttonIndex > 0) {
        
		switch(alertView.tag){
                
			case kTextEntryAlertTag:
			{
				UITextField *alertInputField=(UITextField*)[alertView viewWithTag:kTextEntryAlertFieldTag];
				if (alertInputField!=nil && ![alertInputField.text isEqualToString:EMPTYSTRING]) {
					
					[[RouteManager sharedInstance] loadRouteForRouteId:alertInputField.text];
					
					[_routeTypeControl setSelectedSegmentIndex:1];
					[self selectedIndexDidChange:1];
				}
			}
            break;
                
			default:
				
            break;
                
		}
		
	}
	
}


//
/***********************************************
 * @description		RKCustomSegmentedControl  delegate method	
 ***********************************************/
//
-(void)selectedIndexDidChange:(int)index{
	
    if(index!=-1){
		
		[self swapChildViewControllerToType:_childControllerData[index]];
	
	}
	
}




#pragma mark Child controllers

-(void)createViewControllerForType:(NSString*)type{
    
    SuperViewController *_newcontroller=[_viewStack objectForKey:type];
	NSDictionary *controllerDict=[self childControllerDictForType:type];
    if(_newcontroller==nil){
        UIStoryboard *storyboard=[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil ];
        _newcontroller=[storyboard instantiateViewControllerWithIdentifier:controllerDict[CONTROLLER]];
        _newcontroller.delegate=self;
        [_viewStack setObject:_newcontroller forKey:type];
        
    }
    
    [self addChildViewController:_newcontroller];
}

-(void)loadInitialChildView{
    
    NSDictionary *dict=_childControllerData[0];
    NSString *controllerName=dict[ID];
    self.activeState=controllerName;
    
    self.activeController=[self.childViewControllers objectAtIndex:0];
    
}


-(void)swapChildViewControllerToType:(NSDictionary*)dict{
    
    SuperViewController *_oldcontroller=_activeController;
    
    NSString *controller=dict[ID];
    self.activeState=controller;
    
    [self createViewControllerForType:controller];
    SuperViewController *_newcontroller=[_viewStack objectForKey:controller];
    [_oldcontroller willMoveToParentViewController:nil];
    
    [self transitionFromViewController:_oldcontroller toViewController:_newcontroller duration:0.2 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{} completion:^(BOOL finished) {
        [_oldcontroller removeFromParentViewController];
        [_newcontroller didMoveToParentViewController:self];
        self.activeController=_newcontroller;
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
            self.routeSummary = [[RouteSummary alloc]init];
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
