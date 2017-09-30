//
//  NewMapViewController.m
//  CycleStreets
//
//  Created by Neil Edwards on 26/09/2012.
//  Copyright (c) 2012 CycleStreets Ltd. All rights reserved.
//

#import "MapViewController.h"
#import "GlobalUtilities.h"
#import "ExpandedUILabel.h"
#import "CSPointVO.h"
#import "SegmentVO.h"
#import "SettingsManager.h"
#import "CycleStreets.h"
#import "AppDelegate.h"
#import "PhotoMapListVO.h"
#import "PhotoMapVO.h"
#import "CSPointVO.h"
#import "Files.h"
#import "RouteManager.h"
#import "GlobalUtilities.h"
#import "AppConstants.h"
#import "SettingsManager.h"
#import "HudManager.h"
#import "UserLocationManager.h"
#import	"WayPointVO.h"
#import "WayPointViewController.h"
#import "UIView+Additions.h"
#import "ViewUtilities.h"
#import "MKMapView+Additions.h"
#import "CSWaypointAnnotation.h"
#import "CSWaypointAnnotationView.h"
#import "UIActionSheet+BlocksKit.h"
#import "CSMapSource.h"
#import "RouteVO.h"
#import "WayPointViewController.h"
#import "ExpandedUILabel.h"
#import "CSRoutePolyLineOverlay.h"
#import "CSRoutePolyLineRenderer.h"
#import "GenericConstants.h"
#import "MKMapView+LegalLabel.h"
#import "CSMapTileService.h"
#import "MapViewSearchLocationViewController.h"
#import "BuildTargetConstants.h"

#import "UserSettingsManager.h"

#import "UIColor+AppColors.h"
#import "UIImage+Additions.h"
#import "UIImage-Additions.h"
#import "UIImage+ColorImage.h"

#import "A2StoryboardSegueContext.h"

#import "CSOverlayTransitionAnimator.h"
#import "SavedLocationsViewController.h"
#import "SavedLocationVO.h"
#import "SavedLocationsManager.h"
#import "SaveLocationCreateViewController.h"
#import "LeisureViewController.h"
#import "LeisureListViewController.h"
#import "FirstRunViewController.h"

#import "POIListviewController.h"
#import "POIManager.h"
#import "POILocationVO.h"
#import "POIAnnotation.h"
#import "POIAnnotationView.h"

#import "CSAppleSatelliteMapSource.h"
#import "CSOrdnanceSurveyStreetViewMapSource.h"

#import "CSRetinaTileRenderer.h"

#import <QuartzCore/QuartzCore.h>

static NSInteger DEFAULT_ZOOM = 15;
static NSInteger DEFAULT_OVERVIEWZOOM = 15;



@interface MapViewController()<MKMapViewDelegate,UIActionSheetDelegate,CLLocationManagerDelegate,LocationReceiver,UIViewControllerTransitioningDelegate,SavedLocationsViewDelegate>

// tool bar
@property (nonatomic, strong) IBOutlet UIToolbar					* toolBar;
@property (nonatomic, strong) UIBarButtonItem						* locationButton;
@property (nonatomic, strong) UIButton								* activeLocationSubButton;
@property (nonatomic, strong) UIBarButtonItem						* waypointButton;
@property (nonatomic, strong) UIBarButtonItem						* routeButton;
@property (nonatomic, strong) UIButton								* addRouteSubButton;
@property (nonatomic, strong) UIBarButtonItem						* changePlanButton;
@property (nonatomic, strong) UIBarButtonItem						* leftFlex;
@property (nonatomic, strong) UIBarButtonItem						* rightFlex;
@property (nonatomic, strong) UIBarButtonItem						* rightFixed;
@property (nonatomic, strong) UIBarButtonItem						* rightFixedSeconday;

@property (nonatomic, strong) UIBarButtonItem						* addPointButton;
@property (nonatomic, strong) UIBarButtonItem						* searchButton;


@property (weak, nonatomic) IBOutlet UIView                         *addPointView;
@property (nonatomic,weak) IBOutlet UIButton						*viewWaypointsButton;
@property (nonatomic,weak) IBOutlet UIButton						*createLesureRouteButton;
@property (nonatomic,strong)  UISwipeGestureRecognizer				*addPointSwipeGesture;


@property(nonatomic,strong) IBOutlet  UIView						*walkingRouteOverlayView;
@property(nonatomic,assign)  BOOL									walkingOverlayisVisible;


//map
@property (nonatomic, strong) IBOutlet MKMapView					* mapView;
@property (nonatomic,strong)  NSString								*name;
@property (nonatomic, strong) CLLocation							* lastLocation;
@property (nonatomic,strong)  CSRoutePolyLineOverlay				* routeOverlay;
@property (nonatomic,strong)  CSRoutePolyLineRenderer				* routeOverlayRenderer;
@property (nonatomic,strong)  CSMapSource							* activeMapSource;
@property (nonatomic,strong)  CLLocationManager						*locationManager;


// sub views
@property (nonatomic, strong) MapViewSearchLocationViewController	* mapLocationSearchView;

// ui
@property (nonatomic, strong) IBOutlet ExpandedUILabel				* attributionLabel;

@property (nonatomic, assign) MapAlertType							alertType;


// waypoint ui
// will need ui for editing waypoints
@property(nonatomic,assign)  BOOL									markerMenuOpen;
@property (nonatomic,strong)  MKAnnotationView						*selectedAnnotation;

// data
@property (nonatomic, strong) RouteVO								* route;
@property (nonatomic, strong) NSMutableArray						* waypointArray;
@property (nonatomic, strong) NSMutableArray						* waypointAnnotationArray;


// pois
@property (nonatomic, strong) NSMutableDictionary					* poiDataProvider;
@property (nonatomic, strong) NSMutableArray						* poiAnnotationArray;
@property (nonatomic, strong) NSMutableArray						* poiRouteArray;



// state
@property (nonatomic, assign) BOOL									doingLocation;
@property (nonatomic, assign) BOOL									programmaticChange;
@property (nonatomic, assign) BOOL									avoidAccidentalTaps;
@property (nonatomic, assign) BOOL									singleTapDidOccur;
@property (nonatomic, assign) BOOL									savedSelectedRouteLoading;
@property (nonatomic, assign) BOOL									loadingRoute;
@property (nonatomic, assign) BOOL									routeWasCleared;



@property (nonatomic, assign) CGPoint								singleTapPoint;
@property (nonatomic, assign) MapPlanningState						uiState;
@property (nonatomic, assign) MapPlanningState						previousUIState;

@property (nonatomic,strong)  MKMapCamera							*mapCamera;


@property (nonatomic,strong)  UITapGestureRecognizer				*mapSingleTapRecognizer;
@property (nonatomic,strong)  UITapGestureRecognizer				*mapDoubleTapRecognizer;

@property (weak, nonatomic) IBOutlet UIButton						*followUserButton;

@property (nonatomic,assign)  BOOL									toggleMap;

@end





@implementation MapViewController


-(void)listNotificationInterests{
	
	[self initialise];
	
	[notifications addObject:CSMAPSTYLECHANGED];
	[notifications addObject:CSROUTESELECTED];
	[notifications addObject:EVENTMAPROUTEPLAN];
	[notifications addObject:CSLASTLOCATIONLOAD];
	
	[notifications addObject:GPSLOCATIONCOMPLETE];
	[notifications addObject:GPSLOCATIONUPDATE];
	[notifications addObject:GPSLOCATIONFAILED];
	[notifications addObject:GPSSYSTEMLOCATIONCOMPLETE];
	
	[notifications addObject:POIMAPLOCATIONRESPONSE];
	
	[super listNotificationInterests];
	
}

-(void)didReceiveNotification:(NSNotification*)notification{
	
	[super didReceiveNotification:notification];
	
	NSString		*name=notification.name;
	
	if([name isEqualToString:CSROUTESELECTED]){
		[self updateSelectedRoute];
	}
	
	if([name isEqualToString:CSLASTLOCATIONLOAD]){
		[self loadLocation];
	}
	
	if([name isEqualToString:EVENTMAPROUTEPLAN]){
		[self didSelectNewRoutePlan:[notification.userInfo objectForKey:@"planType"]];
	}

	if([name isEqualToString:CSMAPSTYLECHANGED]){
		[self didNotificationMapStyleChanged];
	}
	
	if([name isEqualToString:GPSSYSTEMLOCATIONCOMPLETE]){
		[self userLocationDidComplete];
	}
	
	if([name isEqualToString:POIMAPLOCATIONRESPONSE]){
		[self updatePOIMapMarkers];
	}
	
}

#pragma mark notification response methods


- (void) didNotificationMapStyleChanged {
	
	
	NSArray *overlays=[_mapView overlaysInLevel:MKOverlayLevelAboveLabels];
	
	// filter to remove any Route overlays from this process
	NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id object, NSDictionary *bindings) {
		return ![object isKindOfClass:[CSRoutePolyLineOverlay class]];
	}];
	overlays=[overlays filteredArrayUsingPredicate:predicate];
	//
	
	self.activeMapSource=[CycleStreets activeMapSource];
	
	[CSMapTileService updateMapStyleForMap:_mapView toMapStyle:_activeMapSource withOverlays:overlays];
	
	[CSMapTileService updateMapAttributonLabel:_attributionLabel forMap:_mapView forMapStyle:_activeMapSource inView:self.view];
	
	[_mapView moveOverlayToTop:_routeOverlay inLevel:MKOverlayLevelAboveLabels];
	
}


//------------------------------------------------------------------------------------
#pragma mark - View methods
//------------------------------------------------------------------------------------
//
/***********************************************
 * @description			View Methods
 ***********************************************/
//

-(void)viewDidLoad{
	
	[super viewDidLoad];
	
	[self createPersistentUI];
	
}


-(void)viewDidAppear:(BOOL)animated{
	
	[self createNonPersistentUI];
	
	[super viewDidAppear:animated];
	
}


-(void)createPersistentUI{
	
	self.displaysConnectionErrors=NO;
	
	_toolBar.clipsToBounds=YES;
	
	_mapView.rotateEnabled=YES;
    _mapView.pitchEnabled=YES;
	_mapView.showsPointsOfInterest=NO;
	_mapView.showsBuildings=YES;
	_mapView.tintColor=[UIColor appTintColor];
	
	_attributionLabel.textAlignment=NSTextAlignmentCenter;
	_attributionLabel.backgroundColor=UIColorFromRGBAndAlpha(0x008000, .1);
	
	BOOL willRequireAuthorisation=[[UserLocationManager sharedInstance] requestAuthorisation];
	
	[_mapView setDelegate:self];
	
	_mapView.userTrackingMode=MKUserTrackingModeNone;
	
	[self didNotificationMapStyleChanged];
	
	
	[self initToolBarEntries];
	
	[self resetWayPoints];
	
	
	[self.view addSubview:_walkingRouteOverlayView];
	_walkingRouteOverlayView.y=self.view.height+_walkingRouteOverlayView.height;
	
	
	[UIImage styleExistingNavButton:_followUserButton forID:@"compass" atSize:CGSizeMake(30, 30)];
	_followUserButton.layer.cornerRadius=_followUserButton.width/2;
	_followUserButton.layer.shadowColor=UIColorFromRGB(0x000000).CGColor;
	_followUserButton.layer.shadowOffset=CGSizeMake(2,3);
	_followUserButton.layer.shadowRadius=4;
	_followUserButton.layer.shadowOpacity=0.7;
	
	
	
	
	self.programmaticChange = NO;
	self.singleTapDidOccur=NO;
	
	[self updateUItoState:MapPlanningStateNoRoute];
	
	self.mapSingleTapRecognizer=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapOnMapSingle:)];
	_mapSingleTapRecognizer.numberOfTapsRequired=1;
	_mapSingleTapRecognizer.enabled=YES;
	_mapSingleTapRecognizer.delaysTouchesBegan=YES;
	[self addSingleTapFailureRequirement];
	[_mapView addGestureRecognizer:_mapSingleTapRecognizer];
	
	
	self.addPointSwipeGesture=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(didSwipeAddPointView:)];
	_addPointSwipeGesture.direction=UISwipeGestureRecognizerDirectionUp;
	[_addPointView addGestureRecognizer:_addPointSwipeGesture];
	
	
	if(willRequireAuthorisation==NO){
		[self userLocationDidComplete];
	}

}


// ensures the single tap logic doesnt fire when a user double taps
- (void) addSingleTapFailureRequirement {
	
	for (UIView *aSubview in [[self mapView] subviews]) {
		
		if ([aSubview isMemberOfClass:[UIView class]]) {
			
			for (UIGestureRecognizer *aRecognizer in [aSubview gestureRecognizers]) {
				
				if ([aRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
					
					if ([(UITapGestureRecognizer *) aRecognizer numberOfTapsRequired] == 2) {
						
						[self.mapSingleTapRecognizer requireGestureRecognizerToFail:aRecognizer];
					}
				}
			}
		}
	}
}


// supports iOS8s new additional location authorisation workflow
// we have to wait for CoreLocation to prompt the user and start location updates before we attempt to switch on MapKit's location
// looks like someone didnt tell the mapkit guys this os8 functionality is required!
- (void)userLocationDidComplete{
	
	BOOL shouldloadSavedRoute=[[RouteManager sharedInstance] loadSavedSelectedRoute];
		
	if(!shouldloadSavedRoute)
		_mapView.showsUserLocation=YES;
	
	
	[self removeNotification:GPSSYSTEMLOCATIONCOMPLETE];
	
}



-(void)createNonPersistentUI{
	
	[ViewUtilities alignView:_attributionLabel withView:self.view :BURightAlignMode :BUBottomAlignMode :7];
	
	BOOL isNotFirstRun=[[[UserSettingsManager sharedInstance]fetchObjectforKey:@"isNotFirstRun"] boolValue];
	if(isNotFirstRun==NO){
		[self performSegueWithIdentifier:@"FirstRunSegue" sender:self];
		[[UserSettingsManager sharedInstance] saveObject:@(YES) forKey:@"isNotFirstRun"];
	}
	
}


-(void)initToolBarEntries{
	
	
	self.waypointButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"CSTabBar_plan_route.png"]
														   style:UIBarButtonItemStylePlain
														  target:self
														  action:@selector(showWayPointView)];
	_waypointButton.width = 40;
	
	self.activeLocationSubButton=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 20, 20)];
	_activeLocationSubButton.tintColor=[UIColor whiteColor];
	[_activeLocationSubButton addTarget:self action:@selector(didSelectLocateUserbutton) forControlEvents:UIControlEventTouchUpInside];
	[_activeLocationSubButton setImage:[UIImage imageNamed:@"CSBarButton_followuser.png"] forState:UIControlStateNormal];
	[_activeLocationSubButton setImage:[UIImage imageNamed:@"CSBarButton_gpsactive.png"] forState:UIControlStateSelected];
	self.locationButton = [[UIBarButtonItem alloc] initWithCustomView:_activeLocationSubButton];
	_locationButton.width = 40;
	
	self.searchButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"CSBarButton_search.png"]
													   style:UIBarButtonItemStylePlain
													  target:self
													  action:@selector(searchButtonSelected)];
	_searchButton.width = 40;
	
	self.changePlanButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"CSBarButton_routePlan.png"]
													   style:UIBarButtonItemStylePlain
													  target:self
													  action:@selector(showRoutePlanMenu:)];
	
	self.addRouteSubButton=[UIButton buttonWithType:UIButtonTypeCustom];
	_addRouteSubButton.tintColor=[UIColor whiteColor];
	[_addRouteSubButton setTitle:@"Plan" forState:UIControlStateNormal];
	[_addRouteSubButton addTarget:self action:@selector(routeButtonSelected) forControlEvents:UIControlEventTouchUpInside];
	_addRouteSubButton.size=CGSizeMake(44, 44);
	self.routeButton = [[UIBarButtonItem alloc] initWithCustomView:_addRouteSubButton];
	
	
	// CNS only
	self.addPointButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"CSBarButton_addPoint.png"]
														style:UIBarButtonItemStylePlain
													   target:self
                                                     action:@selector(displayAddPointView)];
	_addPointButton.width=40;
	
	
	
	self.leftFlex=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	self.rightFlex=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	self.rightFixed=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
	self.rightFixed=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
	self.rightFixedSeconday=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
	_rightFixed.width=20;
	_rightFixedSeconday.width=20;
}


/**
 iOS11 issue with top bar inter item spacing, will display uneven spacing for 1st item, so we add additional padding

 @return fixed sized item depending on os version
 */
+(UIBarButtonItem*)fixedItem{
	UIBarButtonItem *fixed=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
	if (@available(iOS 11, *)) {
		fixed.width=15;
	}else{
		fixed.width=0;
	}
	
	return fixed;
}


-(NSArray*)toolbarItemsForBuildTargetForUIState{
	
	ApplicationBuildTarget buildTarget=[BuildTargetConstants buildTarget];
	
	switch (buildTarget) {
		case ApplicationBuildTarget_CycleStreets:
		case ApplicationBuildTarget_CNS:
		{
			_viewWaypointsButton.enabled=[self shouldShowWayPointUI];
			_createLesureRouteButton.enabled=[self shouldShowCreateLeisureUI];
			
			
			switch (_uiState) {
					
				case MapPlanningStateNoRoute:
					return @[_locationButton,[MapViewController fixedItem],_searchButton, _addPointButton, _leftFlex, _rightFlex ];
					break;
					
				case MapPlanningStateLocating:
					return @[_locationButton,[MapViewController fixedItem],_searchButton,_addPointButton, _leftFlex, _rightFlex];
					
					break;
					
				case MapPlanningStateStartPlanning:
					return @[_locationButton,[MapViewController fixedItem],_searchButton,_addPointButton,_leftFlex,_rightFlex];
					break;
					
				case MapPlanningStatePlanning:
					return @[ _locationButton,[MapViewController fixedItem],_searchButton,_addPointButton,_leftFlex,_routeButton];
					break;
					
				case MapPlanningStateRoute:
					return @[_locationButton,[MapViewController fixedItem],_searchButton,_leftFlex, _changePlanButton,_rightFixed,_routeButton];
					break;
					
				case MapPlanningStateRouteLocating:
				{
					if(_allowsUserTrackingUI){
						return @[_locationButton,[MapViewController fixedItem],_searchButton,_leftFlex, _changePlanButton,_rightFixed, _routeButton];
					}else{
						return @[_locationButton,[MapViewController fixedItem],_searchButton,_leftFlex, _changePlanButton,_rightFixed,_routeButton];
					}
				}
					
				break;
			}
		}
			
		break;
	}
	return nil;
}


//------------------------------------------------------------------------------------
#pragma mark - UI State
//------------------------------------------------------------------------------------
//
/***********************************************
 * @description			State Update
 ***********************************************/
//

-(void)updateUIState{
	[self updateUItoState:_uiState];
}

- (void)updateUItoState:(MapPlanningState)state{
	
	
	self.previousUIState=_uiState;
	self.uiState = state;
	
	NSArray *items=nil;
	
	
	switch (_uiState) {
			
		case MapPlanningStateNoRoute:
		{
			BetterLog(@"MapPlanningStateNoRoute");
			
			//_searchButton.enabled = YES;
			_activeLocationSubButton.selected=NO;
			
			items=[self toolbarItemsForBuildTargetForUIState];
			[self.toolBar setItems:items animated:YES ];
			_followUserButton.visible=NO;
		}
		break;
		
		case MapPlanningStateLocating:
		{
			BetterLog(@"MapPlanningStateLocating");
			
			
			//_searchButton.enabled = YES;
			_activeLocationSubButton.selected=YES;
			
			items=[self toolbarItemsForBuildTargetForUIState];
			
			[self.toolBar setItems:items animated:YES ];
			_followUserButton.visible=NO;
			
			
		}
		break;
		
		case MapPlanningStateStartPlanning:
		{
			BetterLog(@"MapPlanningStateStartPlanning");
			
			//_searchButton.enabled = YES;
			_activeLocationSubButton.selected=NO;
			
			items=[self toolbarItemsForBuildTargetForUIState];
            
            [self.toolBar setItems:items animated:YES ];
			_followUserButton.visible=NO;
		}
		break;
		
		case MapPlanningStatePlanning:
		{
			BetterLog(@"MapPlanningStatePlanning");
			
			[_addRouteSubButton setTitle:@"Plan" forState:UIControlStateNormal];
			//_searchButton.enabled = YES;
			_activeLocationSubButton.selected=NO;
			
			items=[self toolbarItemsForBuildTargetForUIState];
            [self.toolBar setItems:items animated:YES ];
			_followUserButton.visible=NO;
		}
		break;
			
		case MapPlanningStateRoute:
		{
			BetterLog(@"MapPlanningStateRoute");
			
			[_addRouteSubButton setTitle:@"New" forState:UIControlStateNormal];
			_activeLocationSubButton.selected=NO;
			//_searchButton.enabled = YES;
			
			items=[self toolbarItemsForBuildTargetForUIState];
            [self.toolBar setItems:items animated:NO ];
			
			_followUserButton.visible=YES;
		}
		break;
			
		case MapPlanningStateRouteLocating:
		{
			BetterLog(@"MapPlanningStateRouteLocating");
			
			[_addRouteSubButton setTitle:@"New" forState:UIControlStateNormal];
			_activeLocationSubButton.selected=NO;
			//_searchButton.enabled = NO;
			
			items=[self toolbarItemsForBuildTargetForUIState];
			[self.toolBar setItems:items animated:NO ];
			_followUserButton.visible=YES;
		}
		break;
	}
	
	
	
}

#pragma mark - Event>State logic

// planning only
-(BOOL)canDragAnnotation{
	
	
	return NO;
}

// planning olny
-(BOOL)canTapAddAnnotation{
	
	
	return NO;
}

// all
-(BOOL)shouldlocateUser{
	
	return NO;
}


//------------------------------------------------------------------------------------
#pragma mark - MKMap Core Location
//------------------------------------------------------------------------------------


// called continuously as map locates user via showsUserLocation=YES
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
	
	BetterLog(@"");
	
	userLocation.title = EMPTYSTRING;
	
	if(!_programmaticChange && self.lastLocation!=nil)
		return;
	
	// as this method is called constantly from the MapView we need to filter out any same location values
	if([UserLocationManager isSignificantLocationChange:self.lastLocation.coordinate newLocation:userLocation.coordinate accuracy:2])
		[self locationDidComplete:userLocation];
	
}

// gps bar button selected
-(IBAction)didSelectLocateUserbutton{
	
	BetterLog(@"");
	
	if([[UserLocationManager sharedInstance] doesDeviceAllowLocation]){
		
		
		if(_uiState==MapPlanningStateLocating){
			
			_programmaticChange=NO;
			
			[self updateUItoState:_previousUIState];
			
		}else{
			
			_programmaticChange=YES;
			self.lastLocation=nil; // nil out the saved location so that locationDidComplete will execute the map update
			_mapView.showsUserLocation=NO;
			_mapView.showsUserLocation=YES;
			
			if(_uiState==MapPlanningStateRoute){
				[self updateUItoState:MapPlanningStateRouteLocating];
			}else{
				[self updateUItoState:MapPlanningStateLocating];
			}
			
			
		}
		
		
	}else{
		
		
		[[UserLocationManager sharedInstance] displayUserLocationAlert];
		
		
	}
	
	
	
}


// called as showsUserLocation is set to YES
- (void)mapViewWillStartLocatingUser:(MKMapView *)mapView{
	BetterLog(@"");
	
}


// called when showsUserLocation is set to NO
- (void)mapViewDidStopLocatingUser:(MKMapView *)mapView{
	
	BetterLog(@"");
	
	if(_uiState!=MapPlanningStateRoute)
		[self updateUItoState:_previousUIState];
	
}


-(void)locationDidComplete:(MKUserLocation *)userLocation{
	
	BetterLog(@"");
	
	self.lastLocation=userLocation.location;
	

	if(_uiState!=MapPlanningStateRoute){
		
		if(_previousUIState==MapPlanningStateRoute){
			
			[self setMapRectForLastLocation];
			
		}else{
			[_mapView setCenterCoordinate:_lastLocation.coordinate zoomLevel:DEFAULT_ZOOM animated:YES];
		}
		
	}else{
		[self setMapRectForLastLocation];
	}
	
	
	[self assessLocationEffect];
}


-(void)setMapRectForLastLocation{
	
	MKMapRect mapRect=[MKMapView mapRectThatFitsBoundsSW:[self.route maxSouthWestForLocation:_lastLocation] NE:[self.route maxNorthEastForLocation:_lastLocation]];
	[_mapView setVisibleMapRect:mapRect edgePadding:UIEdgeInsetsMake(40, 10, 10, 10) animated:YES];
	
}


-(void)locationDidFail:(NSNotification *)notification{
	
	BetterLog(@"");
	
	[self updateUItoState:_previousUIState];
	
}



// assess if there are any UI changes related this location update
-(void)assessLocationEffect{
	
	BetterLog(@"");
		
	if(_uiState==MapPlanningStateLocating || _uiState==MapPlanningStateRouteLocating){
		
		// if prev state is not route we shoudl see if we need to add a waypoint
		if (_previousUIState!=MapPlanningStateRoute)
			[self assessWayPointAddition:_lastLocation.coordinate];
			
		// if prev state is route, then we revert back to this
		if(_previousUIState==MapPlanningStateRoute){
			[self updateUItoState:_previousUIState];
			
		}else{
			// else load the state based on the waypoint status
			[self assessUIState];
		}
		
		
		
	}else{
		_programmaticChange=NO;
		
		if(self.route==nil){
			[self updateUItoState:_previousUIState];
			
		}else{
			[self updateUItoState:MapPlanningStateRoute];
		}
		
	}
		
}




#pragma mark - Map Tracking mode

-(void)stopUserTracking{
	
	BetterLog(@"");
	
	_programmaticChange=NO;
	_allowsUserTrackingUI=NO;
	_followUserButton.selected=_allowsUserTrackingUI;
}

-(IBAction)toggleUserTracking{
	
	BetterLog(@"");
	
	_allowsUserTrackingUI=!_allowsUserTrackingUI;
	
	if(_allowsUserTrackingUI){
		
		_mapView.camera.pitch=30;
		[_mapView setUserTrackingMode:MKUserTrackingModeFollowWithHeading animated:YES];
		
	}else{
		_programmaticChange=NO;
		[_mapView setUserTrackingMode:MKUserTrackingModeNone animated:NO];
		_mapView.camera.pitch=0;
		
	}
	
	_followUserButton.selected=_allowsUserTrackingUI;
}





#pragma mark - Route Display
//
/***********************************************
 * @description			Route loading
 ***********************************************/
//

-(void)updateSelectedRoute{
	
	BetterLog(@"");
	[self showRoute:[RouteManager sharedInstance].selectedRoute];
}

- (void) showRoute:(RouteVO *)newRoute {
	
	BetterLog(@"route=%@",newRoute);
	
	self.route = newRoute;
	
	if (_route == nil || [_route numSegments] == 0) {
		[self clearRoute];
	} else {
		[self newRoute];
	}
}

- (void) clearRoute {
	
	self.route = nil;
	[_mapView removeAnnotations:[_mapView annotationsWithoutUserLocation]];
	[_mapView removeAnnotations:_poiRouteArray];
	[_waypointArray removeAllObjects];
	
	[_routeOverlay resetOverlay];
	[_routeOverlayRenderer setNeedsDisplay];
	
	[self updateUItoState:MapPlanningStateNoRoute];
	_previousUIState=MapPlanningStateNoRoute;
	
	[self stopUserTracking];
	
	[[RouteManager sharedInstance] clearSelectedRoute];
	
	_routeWasCleared=YES;
}



- (void) newRoute {
	
	_savedSelectedRouteLoading=YES;
	_routeWasCleared=NO;
	
	[self updateUItoState:MapPlanningStateRoute];
	
	BetterLog(@"");
	CLLocationCoordinate2D ne=[_route insetNorthEast];
	CLLocationCoordinate2D sw=[_route insetSouthWest];
	
	//TODO: this needs to be optimised so the map scaling only occurs once and
	// the ui state is set correctly at end.
	
	MKMapRect mapRect=[MKMapView mapRectThatFitsBoundsSW:sw NE:ne];
	[_mapView setVisibleMapRect:mapRect edgePadding:UIEdgeInsetsMake(10, 50, 50, 10) animated:YES];
	
	
	[_waypointArray removeAllObjects];
	
	if (_route.hasWaypoints==YES) {
		
		for(CSPointVO *point in [_route createCorrectedWaypointArray]){
			CLLocationCoordinate2D location = point.coordinate;
			[self addWayPointAtCoordinate:location];
		}
		
	}else{
		
		// old legacy s/f routes
		CLLocationCoordinate2D startLocation = [[_route segmentAtIndex:0] segmentStart];
		[self addWayPointAtCoordinate:startLocation];
		CLLocationCoordinate2D endLocation = [[_route segmentAtIndex:[_route numSegments] - 1] segmentEnd];
		[self addWayPointAtCoordinate:endLocation];
		
	}
	
	[_mapView removeAnnotations:_poiRouteArray];
	if(_route.hasPOIs){
		
		NSMutableArray *poiAnnotationArray=[NSMutableArray array];
		
		for (POILocationVO *poi in _route.poiArray) {
			
			POIAnnotation *annotation=[[POIAnnotation alloc]init];
			annotation.coordinate=poi.coordinate;
			annotation.dataProvider=poi;
			
			[poiAnnotationArray addObject:annotation];
		}
		
		[_mapView addAnnotations:poiAnnotationArray];
		
		self.poiRouteArray=poiAnnotationArray;
		
	}
	
	[self showWalkingOverlay];
	
	if(_routeOverlay==nil){
		self.routeOverlay = [[CSRoutePolyLineOverlay alloc] initWithRoute:_route];
		[self.mapView addOverlay:_routeOverlay];
	}else{
		[_routeOverlay updateForDataProvider:_route];
		[_routeOverlayRenderer setNeedsDisplay];
		[_mapView moveOverlayToTop:_routeOverlay inLevel:MKOverlayLevelAboveLabels];
	}
	
	[self updateUItoState:MapPlanningStateRoute];
	
	_savedSelectedRouteLoading=NO;
	
}


//------------------------------------------------------------------------------------
#pragma mark - MapKit Overlays
//------------------------------------------------------------------------------------

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id <MKOverlay>)overlay{
	
    
    if ([overlay isKindOfClass:[MKTileOverlay class]]) {
        return [[CSRetinaTileRenderer alloc] initWithTileOverlay:overlay];
        
    }
	
	if([overlay isKindOfClass:[CSRoutePolyLineOverlay class]]){
		self.routeOverlayRenderer = [[CSRoutePolyLineRenderer alloc] initWithOverlay:overlay];
		_routeOverlayRenderer.primaryColor=UIColorFromRGBAndAlpha(0x880088, 0.7);
		_routeOverlayRenderer.secondaryColor=UIColorFromRGBAndAlpha(0x880088, 0.7);
		_routeOverlayRenderer.secondaryDash=4.0f;
		return _routeOverlayRenderer;
	}
    
    return nil;
}



-(void)showWalkingOverlay{
	
	
	if (_route.containsWalkingSections==YES) {
		
		if(_walkingOverlayisVisible==NO){
			
			_walkingRouteOverlayView.y=self.view.height;
			_walkingOverlayisVisible=YES;
			
			[UIView animateWithDuration:0.7 animations:^{
				
				_walkingRouteOverlayView.y=self.view.height-_walkingRouteOverlayView.height;
				
			} completion:^(BOOL finished) {
				
				[UIView animateWithDuration:0.3 delay:3 options:UIViewAnimationOptionCurveLinear animations:^{
					_walkingRouteOverlayView.y=self.view.height;
				} completion:^(BOOL finished) {
					_walkingOverlayisVisible=NO;
				}];
				
			}];
			
			
		}else{
			[UIView animateWithDuration:0.3 delay:5 options:UIViewAnimationOptionCurveLinear animations:^{
				_walkingRouteOverlayView.y=self.view.height;
			} completion:^(BOOL finished) {
				_walkingOverlayisVisible=NO;
			}];
			
		}
		 
	}
	
}



//------------------------------------------------------------------------------------
#pragma mark - Waypoints
//------------------------------------------------------------------------------------



-(void)resetWayPoints{
	
	[_waypointArray removeAllObjects];
	
}


-(void)assessWayPointAddition:(CLLocationCoordinate2D)cooordinate{
	
	BetterLog(@"");
	
	if(_uiState==MapPlanningStateRoute)
		return;
	
	
	BOOL acceptWaypoint=YES;
	
	// location is too near any other locations> reject
	//if (_uiState==MapPlanningStatePlanning || _uiState==MapPlanningStateStartPlanning) {
		
		acceptWaypoint=[self assesWaypointLocationDistance:cooordinate];
		
		if(acceptWaypoint==NO){
			[[HudManager sharedInstance] showHudWithType:HUDWindowTypeError withTitle:@"Point error" andMessage:@"Touch somewhere else or select a different Search location to set this point further away." andDelay:3 andAllowTouch:NO];
			return;
		}
	//}
	
	
	//explicit click while autolocation was happening. Turn off auto, accept click.
	if (_programmaticChange) {
		if (_uiState==MapPlanningStateLocating) {
			[self didSelectLocateUserbutton];
		}
	}
		
	
	[self addWayPointAtCoordinate:cooordinate];
	
	[self assessUIState];
	
	[self saveLocation:cooordinate];
}


-(void)assessUIState{
	
	BetterLog(@"");
	
	if(_savedSelectedRouteLoading)
		return;
	
	if(_waypointArray.count>1){
		[self updateUItoState:MapPlanningStatePlanning];
	}else if(_waypointArray.count==1){
		[self updateUItoState:MapPlanningStateStartPlanning];
	}else if(_waypointArray.count==0){
		[self updateUItoState:MapPlanningStateNoRoute];
	}
	
}

-(BOOL)shouldShowWayPointUI{
	
	return _waypointArray.count>1;
	
}

-(BOOL)shouldShowCreateLeisureUI{
	
	return _waypointArray.count>0;
	
}


// initial Waypoint creation
-(void)addWayPointAtCoordinate:(CLLocationCoordinate2D)coords{
	
	BetterLog(@"");
	
	WayPointVO *waypoint=[WayPointVO new];
	
	
	if(_waypointArray==nil)
		self.waypointArray=[NSMutableArray array];
	
	NSArray *annotationArray=[_mapView annotationsWithoutUserLocation];
	if(annotationArray.count==0){
		waypoint.waypointType=WayPointTypeStart;
		[_waypointArray addObject:waypoint];
	}else if(annotationArray.count==1){
		waypoint.waypointType=WayPointTypeFinish;
		[_waypointArray addObject:waypoint];
	}else{
		waypoint.waypointType=WayPointTypeIntermediate;
		[_waypointArray addObject:waypoint];
	}
	
	
	waypoint.coordinate=coords;
	
	if(_savedSelectedRouteLoading==NO){
		 if ([SettingsManager sharedInstance].dataProvider.showRoutePoint==YES) {
			 
			 if(waypoint.waypointType==WayPointTypeStart){
				 
				 [[HudManager sharedInstance] showHudWithType:HUDWindowTypeIcon withTitle:@"Start point set" andMessage:@"CSIcon_start_wisp.png"];
				 
			 }else if ( waypoint.waypointType==WayPointTypeFinish){
				 
				 [[HudManager sharedInstance] showHudWithType:HUDWindowTypeIcon withTitle:@"Finish point set" andMessage:@"CSIcon_finish_wisp.png"];
				 
			 }
		 }
	}

	// not supported for v3.0
	//[[RouteManager sharedInstance] loadMetaDataForWaypoint:waypoint];
	
	[self updateWaypointStatuses];
	
	[self assessUIState];
	
}


//------------------------------------------------------------------------------------
#pragma mark - WaypointView delegate
//------------------------------------------------------------------------------------

-(void)wayPointArraywasReordered{
	[self updateWaypointStatuses];
}

-(void)wayPointwasDeleted{
	[self updateWaypointStatuses];
	
	if(_waypointArray.count<=1){
		[self assessUIState];
		
		[self dismissViewControllerAnimated:YES completion:nil];
	}
}
-(void)wayPointWasSelected:(id)waypoint{
	WayPointVO *dp=(WayPointVO*)waypoint;
	[_mapView setCenterCoordinate:dp.coordinate zoomLevel:DEFAULT_OVERVIEWZOOM animated:YES];
	
	[self dismissViewControllerAnimated:YES completion:nil];
}


// update Waypoint types from creation, as can change if waypoints are removed post creation ie intermediate can become end etc
-(void)updateWaypointStatuses{
	
	BetterLog(@"");
	
	[_mapView removeAnnotations:_waypointAnnotationArray];
	
	[_waypointAnnotationArray removeAllObjects];
	
	for(int i=0;i<_waypointArray.count;i++){
		
		WayPointVO *waypoint=_waypointArray[i];
		WayPointType type;
		
		if(i==0){
			type=WayPointTypeStart;
		}else if(i==_waypointArray.count-1){
			type=WayPointTypeFinish;
		}else{
			type=WayPointTypeIntermediate;
		}
		
		waypoint.waypointType=type;
		
		[_mapView addAnnotation:[self annotationForWaypoint:waypoint atCoordinate:waypoint.coordinate atIndex:i]];
		
	}
	
}


-(CSWaypointAnnotation*)annotationForWaypoint:(WayPointVO*)waypoint atCoordinate:(CLLocationCoordinate2D)coordinate atIndex:(int)index{
	
	if(_waypointAnnotationArray==nil){
		self.waypointAnnotationArray=[NSMutableArray array];
	}

	CSWaypointAnnotation *annotation=[[CSWaypointAnnotation alloc]init];
	annotation.coordinate=coordinate;
	annotation.index=index;
	annotation.dataProvider=waypoint;
	annotation.menuEnabled=NO;
	
	[_waypointAnnotationArray addObject:annotation];
	
	return annotation;
}


-(void)moveWayPointAtIndex:(int)startindex toIndex:(int)endindex{
	
	[_waypointArray exchangeObjectAtIndex:startindex withObjectAtIndex:endindex];
	
}


-(void)removeWayPoint:(WayPointVO*)waypoint{
	
	NSUInteger found=[_waypointArray indexOfObject:waypoint];
	
	if(found!=NSNotFound){
		
		[self removeWayPointAtIndex:found];
		
	}
	
}

//
//-(WayPointVO*)findWayPointForMarker:(RMMarker*)marker{
//	
//	for (WayPointVO *waypoint in _waypointArray) {
//		
//		if(marker==waypoint.marker)
//			return waypoint;
//		
//	}
//	return nil;
//	
//}


-(void)removeWayPointAtIndex:(NSUInteger)index{
	
	WayPointVO *waypoint=[_waypointArray objectAtIndex:index];
	
	[_waypointArray removeObject:waypoint];
	
	[self updateWaypointStatuses];
	
	[self assessUIState];
	
}


- (BOOL)canBecomeFirstResponder {
	return YES;
}




#pragma mark - MKMap delegate

- (void) didTapOnMapSingle:(UITapGestureRecognizer*)recogniser {
	
	BetterLog(@"");
	
	if(_uiState==MapPlanningStateRoute)
		return;
	
	BetterLog(@"_selectedAnnotation=%@",_selectedAnnotation);
	
	// if an annotation is active, do not add a new one, we must wait for the annotation to be deselected
	if(_selectedAnnotation!=nil)
		return;
	
	CGPoint touchPoint = [recogniser locationInView:self.mapView];
    CLLocationCoordinate2D touchMapCoordinate = [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
	CLLocation *location=[[CLLocation alloc]initWithLatitude:touchMapCoordinate.latitude longitude:touchMapCoordinate.longitude];
	
	[self performSelector:@selector(addLocationToMapForGesture:) withObject:location afterDelay:0.7];
	
	[self hideAddPointView];
	
}

- (BOOL)mapViewRegionDidChangeFromUserInteraction
{
	BetterLog(@"");
	
	UIView *view = self.mapView.subviews.firstObject;
	//  Look through gesture recognizers to determine whether this region change is from user interaction
	for(UIGestureRecognizer *recognizer in view.gestureRecognizers) {
		if(recognizer.state == UIGestureRecognizerStateBegan || recognizer.state == UIGestureRecognizerStateEnded) {
			return YES;
		}
	}
	
	return NO;
}



-(void)addLocationToMapForGesture:(CLLocation*)location{
	
	BetterLog(@"");
	
	if (location==nil) {
		return;
	}
	
	BetterLog(@"");
	
	if(_uiState==MapPlanningStateRoute)
		return;
	
	if(_selectedAnnotation!=nil){
		_selectedAnnotation.selected=NO;
		return;
	}
		
	
	[self assessWayPointAddition:location.coordinate];
}



- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState{
	
	BetterLog(@"");
	
	if(_uiState==MapPlanningStateRoute){
		BetterLog(@"MapPlanningStateRoute");
		return;
	}
		
	
	BetterLog(@"From %u to %u",oldState, newState);
	
	CSWaypointAnnotationView *annotationView=(CSWaypointAnnotationView*)view;
		
	
	if (newState == MKAnnotationViewDragStateEnding) {
		
		[annotationView setDragState:MKAnnotationViewDragStateNone]; //NOTE: doesnt seem to fire this for custom annotations
		
    }else if (newState==MKAnnotationViewDragStateCanceling) {
		
		[annotationView setDragState:MKAnnotationViewDragStateNone]; //NOTE: doesnt seem to fire this for custom annotations
    }
	
	
}


- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated{
	
	BetterLog(@"");
	
	[self hideAddPointView];
	
	// if user tracking is on and the user drags the map we switch it off
	// this is the Apple default for this mode.
	if([self mapViewRegionDidChangeFromUserInteraction]){
		if(_allowsUserTrackingUI)
			[self stopUserTracking];
	}
	
	
}


-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
	
	// if user tracking is on and the user drags the map we switch it off
	// this is the Apple default for this mode.
	if([self mapViewRegionDidChangeFromUserInteraction]){
		if(_allowsUserTrackingUI)
			[self stopUserTracking];
	}
	
	
	[self refreshPOIMarkers];
	
}





#pragma mark - MKMap Annotations

#define kDeleteWaypointControlTag 3001
#define kSaveLocationControlTag 3002
#define kCalloutButtonHeight 90

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
	
	BetterLog(@"");
	
	if ([annotation isKindOfClass:[MKUserLocation class]]){
		 return nil;
	
	}else if ([annotation isKindOfClass:[CSWaypointAnnotation class]]){
		
		static NSString *reuseId = @"CSWaypointAnnotationView";
		CSWaypointAnnotationView *annotationView = (CSWaypointAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:reuseId];
		
		BetterLog(@"annotationView=%@",annotationView);
		
		 if (annotationView == nil){
			 
			 annotationView = [[CSWaypointAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];
			 annotationView.draggable = _uiState!=MapPlanningStateRoute;
			 annotationView.enabled=_uiState!=MapPlanningStateRoute;
			 annotationView.selected=YES;
			 annotationView.canShowCallout=YES;
			 
			 if(_uiState!=MapPlanningStateRoute){
				 UIButton *rcalloutButton=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, [self configureCalloutHeight])];
				 [rcalloutButton setImage:[UIImage imageNamed:@"UIButtonBarTrash.png"] forState:UIControlStateNormal];
				 rcalloutButton.tag=kDeleteWaypointControlTag;
				 rcalloutButton.backgroundColor=[UIColor redColor];
				 annotationView.rightCalloutAccessoryView=rcalloutButton; 
			 }
			 
			 
			UIButton *lcalloutButton=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, [self configureCalloutHeight])];
			 [lcalloutButton setImage:[UIImage imageNamed:@"CSBarButton_saveloc" tintColor:[UIColor whiteColor] style:UIImageTintedStyleKeepingAlpha] forState:UIControlStateNormal];
			 [lcalloutButton setImage:[UIImage imageNamed:@"CSBarButton_saveloc" tintColor:[UIColor blackColor] style:UIImageTintedStyleKeepingAlpha] forState:UIControlStateHighlighted];
			 lcalloutButton.tag=kSaveLocationControlTag;
			 lcalloutButton.backgroundColor=[UIColor appTintColor];
			 annotationView.leftCalloutAccessoryView=lcalloutButton;
			
			 
			 
		 } else {
			 annotationView.annotation = annotation;
			 annotationView.canShowCallout=YES;
		 }
		
		return annotationView;
		
	}else if ([annotation isKindOfClass:[POIAnnotation class]]){
		
		static NSString *reuseId = @"POIAnnotationView";
		POIAnnotationView *annotationView = (POIAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:reuseId];
		
		
		if (annotationView == nil){
			
			annotationView = [[POIAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];
			annotationView.size=CGSizeMake(28,28);
			annotationView.draggable =NO;
			annotationView.enabled=YES;
			annotationView.selected=NO;
			annotationView.canShowCallout=YES;
			
			
			UIButton *rcalloutButton=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, [self configureCalloutHeight])];
			UIImage *poiimage=[UIImage imageNamed:@"CSIcon_map_poi.png"];
			[rcalloutButton setImage:poiimage forState:UIControlStateNormal];
			rcalloutButton.backgroundColor=[UIColor appTintColor];
			annotationView.rightCalloutAccessoryView=rcalloutButton;

			
			
		} else {
			annotationView.annotation = annotation;
			annotationView.canShowCallout=YES;
		}
		
		
		return annotationView;
		
	}

	 return nil;
}

- (CGFloat)configureCalloutHeight
{
	CGFloat defaultHeight = 56.0;
	NSString *contentSize = [[UIApplication sharedApplication] preferredContentSizeCategory];
	NSArray *largeSizes = @[UIContentSizeCategoryExtraExtraLarge,
							UIContentSizeCategoryExtraExtraExtraLarge,
							UIContentSizeCategoryAccessibilityMedium,
							UIContentSizeCategoryAccessibilityLarge,
							UIContentSizeCategoryAccessibilityExtraLarge,
							UIContentSizeCategoryAccessibilityExtraExtraLarge,
							UIContentSizeCategoryAccessibilityExtraExtraExtraLarge];
	NSArray *smallSizes = @[UIContentSizeCategoryExtraSmall,
							UIContentSizeCategorySmall,
							UIContentSizeCategoryMedium];
	
	if ([largeSizes containsObject:contentSize]){
		defaultHeight = 66.0;
	}
	if ([smallSizes containsObject:contentSize]){
		defaultHeight = 46.0;
	}
	return defaultHeight;
}


// Note; there is a slight issues here
// as we drag a selected annotation the callout is removed and when it is let go it reappears
// if you tap long enough but do not move the annotation the callout will flicker
// this is beacuse it goes through the changestate logic. the tap must be just long enough a quick tap will not trigger changestate
//

-(void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view{
	
	
	
	BetterLog(@"");
	
	[self performSelector:@selector(offsetSelectedAnnnotationDeselection) withObject:nil afterDelay:0.2];
	
	//view.selected=YES;
	
}

// offsets the nilling of the selectedAnnotation as single tap will occur immediately after didDeselectAnnotationView, we dont
// want a waypoint to be addded when the user has merely dismissed the annotation popup
-(void)offsetSelectedAnnnotationDeselection{
	
	BetterLog(@"selectedAnnotation=%@",_selectedAnnotation);
	self.selectedAnnotation=nil;
}
 
 
-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view{
	
	BetterLog(@"");
	
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(offsetSelectedAnnnotationDeselection) object:nil];
	
	if([view.annotation isKindOfClass:[MKUserLocation class]]){
		
		MKUserLocation *annotation=(MKUserLocation*)view.annotation;
		view.canShowCallout=NO;
		
		if (_uiState!=MapPlanningStateRoute) {
			
			[self addWayPointAtCoordinate:annotation.location.coordinate];
		}
		
	}else if( [view.annotation isKindOfClass:[CSWaypointAnnotation class]]){
		
		self.selectedAnnotation=(CSWaypointAnnotationView*)view;
		
		BetterLog(@"selectedAnnotation=%@",_selectedAnnotation);
		BetterLog(@"CSWaypointAnnotationView.selected=%i",_selectedAnnotation.selected);
		BetterLog(@"CSWaypointAnnotationView.draggable=%i",_selectedAnnotation.draggable);
	
		[view setDragState:MKAnnotationViewDragStateDragging animated:NO];
		
	}else{
		
		
		self.selectedAnnotation=(POIAnnotationView*)view;
		
		BetterLog(@"selectedAnnotation=%@",_selectedAnnotation);
		
		
	}
	
	
}



- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control{
	
	BetterLog(@"");
	
	if([view.annotation isKindOfClass:[CSWaypointAnnotation class]]){
	
	
		NSInteger tag=control.tag;
		
		CSWaypointAnnotationView *annotationView=(CSWaypointAnnotationView*)view;
		CSWaypointAnnotation* annotation=annotationView.annotation;
		
		switch (tag) {
			case kSaveLocationControlTag:
			{
				SavedLocationVO *location=[[SavedLocationVO alloc] init];
				[location setCoordinate:annotation.coordinate];
				
				[self displayCreateSaveLocationControllerWithLocation:location];
				
				
				[mapView deselectAnnotation:annotation animated:YES];
			}
			break;
				
			case kDeleteWaypointControlTag:
			{
				[self removeWayPoint:annotation.dataProvider];
			}
			break;
		}
		
	}else if ([view.annotation isKindOfClass:[POIAnnotation class]]){
		
		POIAnnotationView *annotationView=(POIAnnotationView*)view;
		POIAnnotation* annotation=annotationView.annotation;
		
		if (_uiState!=MapPlanningStateRoute) {
			
			[self addWayPointAtCoordinate:annotation.coordinate];
			
			[mapView deselectAnnotation:annotation animated:YES];
		}
		
		
	}
	
}




//------------------------------------------------------------------------------------
#pragma mark - UI Alerts
//------------------------------------------------------------------------------------
//
/***********************************************
 * @description			UIAlerts
 ***********************************************/
//

// create alert with Type

-(void)createAlertForType:(MapAlertType)type{
	
	UIAlertView		*alert= [[UIAlertView alloc]
							 initWithTitle:APPLICATIONNAME
							 message:nil
							 delegate:self
							 cancelButtonTitle:@"Cancel"
							 otherButtonTitles:@"OK", nil];
	self.alertType=type;
	
	switch (type) {
		case MapAlertTypeClearRoute:
			
			alert.message=@"Clear current route?";
			
			break;
		 default:
			
			break;
	}
	
	[alert show];
	
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	
	
	switch (_alertType) {
			
		case MapAlertTypeClearRoute:
			
			if (buttonIndex != alertView.cancelButtonIndex) {
				[[RouteManager sharedInstance] selectRoute:nil];
			}
			
		break;
			
		default:
			break;
	}
	

}


//------------------------------------------------------------------------------------
#pragma mark - UIEvents
//------------------------------------------------------------------------------------
//
/***********************************************
 * @description			UIEvents
 ***********************************************/
//


-(IBAction)showWayPointView{
	
	[self performSegueWithIdentifier:@"WaypointViewSegue" sender:self];

	
}


- (IBAction) searchButtonSelected {
	
	BetterLog(@"");
	
	if (self.mapLocationSearchView == nil) {
		self.mapLocationSearchView = [[MapViewSearchLocationViewController alloc] initWithNibName:@"MapViewSearchLocationView" bundle:nil];
		
	}
	_mapLocationSearchView.locationReceiver = self;
	_mapLocationSearchView.centreLocation = [_mapView centerCoordinate];
	_mapLocationSearchView.mapRegion=_mapView.region;
	
	[self presentModalViewController:_mapLocationSearchView	animated:YES];
	
	[self hideAddPointView];
	
}



- (IBAction) routeButtonSelected {
	
	BetterLog(@"");
	
	if (_uiState == MapPlanningStatePlanning) {
		
		[[RouteManager sharedInstance] loadRouteForWaypoints:_waypointArray];
		
	} else if (_uiState == MapPlanningStateRoute) {
		
		[self createAlertForType:MapAlertTypeClearRoute];
		
	}
}






/***********************************************
 * @description			ROUTE PLAN POPUP METHODS
 ***********************************************/
//

-(IBAction)showRoutePlanMenu:(id)sender{
	
	NSString *currentPlan=_route.plan;
	
	__weak __typeof(&*self)weakSelf = self;
	UIActionSheet *actionSheet=[UIActionSheet bk_actionSheetWithTitle:@"Re-route with new plan type"];
	// OS8 only //
	[[UICollectionView appearanceWhenContainedIn:[UIAlertController class], nil] setTintColor:[UIColor darkGrayColor]];
	//
	actionSheet.delegate=self;
	NSArray *planArray=[AppConstants planArray];
	for (NSString *planType in planArray) {
		
		if([planType isEqualToString:currentPlan]){
			
			[actionSheet bk_setDestructiveButtonWithTitle:[planType capitalizedString] handler:^{
				[weakSelf didSelectNewRoutePlan:planType];
			}];
			
		}else{
			
			[actionSheet bk_addButtonWithTitle:[planType capitalizedString] handler:^{
				[weakSelf didSelectNewRoutePlan:planType];
			}];
			
		}
		
	}
	
	[actionSheet bk_setCancelButtonWithTitle:@"Cancel" handler:^{
	}];
	
	[actionSheet showInView:[[[UIApplication sharedApplication]delegate]window]];
	
}

// Yes, you cant style UIActionSheet without doing this!
// Note this only works for OS7, OS8 uses new AlertController
- (void)willPresentActionSheet:(UIActionSheet *)actionSheet{
	
	NSString *currentPlan=_route.plan;
	
    [actionSheet.subviews enumerateObjectsUsingBlock:^(UIView *subview, NSUInteger idx, BOOL *stop) {
        if ([subview isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)subview;
			NSString *buttonText = [button.titleLabel.text lowercaseString];
			if ([buttonText isEqualToString:currentPlan]) {
				button.titleLabel.textColor = UIColorFromRGB(0x509720);
				button.userInteractionEnabled=NO;
			}else if ([buttonText isEqualToString:@"cancel"]){
                button.titleLabel.textColor = UIColorFromRGB(0xB20003);
				[button setTitleColor:UIColorFromRGB(0x509720) forState:UIControlStateHighlighted];
            }else{
				[button setTitleColor:UIColorFromRGB(0x509720) forState:UIControlStateHighlighted];
				button.titleLabel.textColor = [UIColor darkGrayColor];
			}
        }
    }];
}



-(void)didSelectNewRoutePlan:(NSString*)planType{
	
	if([planType isEqualToString:_route.plan])
		return;
	
	[[RouteManager sharedInstance] loadRouteForRouteId:_route.routeid withPlan:planType];
	
}




-(IBAction)didSelectPOIButton:(id)sender{
	
	[self showPOIView];
    
    [self hideAddPointView];
	
}



-(IBAction)didSelectSaveLocationsButton:(id)sender{
	
	[self performSegueWithIdentifier:@"SavedLocationsSegue" sender:self];
    
    [self hideAddPointView];
	
	
}


-(void)displayCreateSaveLocationControllerWithLocation:(SavedLocationVO*)location{
	
	[self performSegueWithIdentifier:@"CreateSavedLocationSegue" sender:self context:location];
    
    [self hideAddPointView];
}


-(IBAction)didSelectLeisureRouteButton:(id)sender{
	
	[self performSegueWithIdentifier:@"LeisureListViewSegue" sender:self];
	
	[self hideAddPointView];
}

-(IBAction)didSelectCreateLeisureRouteButton:(id)sender{
	
	[self performSegueWithIdentifier:@"LeisureViewSegue" sender:self];
	
	[self hideAddPointView];
}




#pragma mark - Add Point View



-(void)didSwipeAddPointView:(UISwipeGestureRecognizer*)recogniser{
	
	[self hideAddPointView];
	
}



-(void)displayAddPointView{
	
	if(_addPointView.y>_toolBar.top){
		
		[self hideAddPointView];
		
	}else{
		[UIView animateWithDuration:0.3 animations:^{
			_addPointView.y=_toolBar.bottom;
		}];
	}
	
}


-(void)hideAddPointView{
	
	if(_addPointView.y>_toolBar.top)
		[UIView animateWithDuration:0.3 animations:^{
			_addPointView.y=_toolBar.top;
		}];
	
}


#pragma mark - Segues



-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	
	[super prepareForSegue:segue sender:sender];
	
	if([segue.identifier isEqualToString:@"SavedLocationsSegue"]){
		
		SavedLocationsViewController *controller=(SavedLocationsViewController*)segue.destinationViewController;
		controller.viewMode=SavedLocationsViewModeModal;
		controller.savedLocationdelegate=self;
		controller.transitioningDelegate = self;
		controller.modalPresentationStyle = UIModalPresentationCustom;
		
	}else if ([segue.identifier isEqualToString:@"CreateSavedLocationSegue"]){
		
		SaveLocationCreateViewController *controller=(SaveLocationCreateViewController*)segue.destinationViewController;
		controller.dataProvider=segue.context;
		controller.transitioningDelegate = self;
		controller.modalPresentationStyle = UIModalPresentationCustom;
		
	}else if ([segue.identifier isEqualToString:@"POIListViewSegue"]){
		
		POIListviewController *controller=(POIListviewController*)segue.destinationViewController;
		
		CLLocationCoordinate2D nw = [_mapView NWforMapView];
		CLLocationCoordinate2D se = [_mapView SEforMapView];
		
		controller.viewMode=POIListViewMode_Map;
		
		controller.nwCoordinate=nw;
		controller.seCoordinate=se;
		
		controller.shouldRefreshSelectedData=_routeWasCleared;
		
		controller.transitioningDelegate = self;
		controller.modalPresentationStyle = UIModalPresentationCustom;
		
	}else if ([segue.identifier isEqualToString:@"WaypointViewSegue"]){
		
		WayPointViewController *controller=(WayPointViewController*)segue.destinationViewController;
		controller.delegate=self;
		controller.dataProvider=_waypointArray;
		
		controller.transitioningDelegate = self;
		controller.modalPresentationStyle = UIModalPresentationCustom;
		
	}else if ([segue.identifier isEqualToString:@"LeisureViewSegue"]){
		
		LeisureViewController *controller=(LeisureViewController*)segue.destinationViewController;
		controller.waypointArray=_waypointArray;
		
		controller.transitioningDelegate = self;
		controller.modalPresentationStyle = UIModalPresentationCustom;
		
	}else if ([segue.identifier isEqualToString:@"LeisureListViewSegue"]){
		
		LeisureListViewController *controller=(LeisureListViewController*)segue.destinationViewController;
		controller.waypointArray=_waypointArray;
		
		controller.transitioningDelegate = self;
		controller.modalPresentationStyle = UIModalPresentationCustom;
		
	}else if ([segue.identifier isEqualToString:@"FirstRunSegue"]){
		
		FirstRunViewController *controller=(FirstRunViewController*)segue.destinationViewController;
		
		controller.transitioningDelegate = self;
		controller.modalPresentationStyle = UIModalPresentationCustom;
	}
	
}


#pragma mark - SaveLocationViewController Delegate

-(void)didSelectSaveLocation:(SavedLocationVO *)savedlocation{
	
	[self addWayPointAtCoordinate:savedlocation.coordinate];
	
	[_mapView setCenterCoordinate:savedlocation.coordinate zoomLevel:_mapView.getZoomLevel animated:YES];
	
}




#pragma mark - UIViewControllerTransitioningDelegate Methods

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
																  presentingController:(UIViewController *)presenting
																	  sourceController:(UIViewController *)source {
	
	CSOverlayTransitionAnimator *animator = [CSOverlayTransitionAnimator new];
	animator.presenting = YES;
	return animator;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
	CSOverlayTransitionAnimator *animator = [CSOverlayTransitionAnimator new];
	return animator;
}




//------------------------------------------------------------------------------------
#pragma mark - POI Methods
//------------------------------------------------------------------------------------

//
/***********************************************
 * @description			POI METHODS
 ***********************************************/
//

-(void)showPOIView{
	
	[self performSegueWithIdentifier:@"POIListViewSegue" sender:self];
	
}


-(void)refreshPOIMarkers{
	
	BOOL hasSelectedPOIs=[POIManager sharedInstance].hasSelectedPOIs;
	if (hasSelectedPOIs==NO)
		return;
		
	CLLocationCoordinate2D centreCoordinate=_mapView.centerCoordinate;
	if([UserLocationManager isSignificantLocationChange:_lastLocation.coordinate newLocation:centreCoordinate accuracy:4]){
		
		CLLocationCoordinate2D nw = [_mapView NWforMapView];
		CLLocationCoordinate2D se = [_mapView SEforMapView];
		
		[[POIManager sharedInstance] refreshPOICategoryMapPointswithNWBounds:nw andSEBounds:se];
		
	}else{
		
	}
	
	
}


-(void)updatePOIMapMarkers{
	
	[self removePOIMarkers];
	
	self.poiDataProvider=[POIManager sharedInstance].categoryDataProvider;
	
	for (NSString *key in _poiDataProvider) {
		
		for (POILocationVO *poi in _poiDataProvider[key]) {
			
			POIAnnotation *annotation=[[POIAnnotation alloc]init];
			annotation.coordinate=poi.coordinate;
			annotation.dataProvider=poi;
			
			[_poiAnnotationArray addObject:annotation];
		}
		
	}
	
	[_mapView addAnnotations:_poiAnnotationArray];
	
}




-(void)removePOIMarkers{
	
	if (_poiAnnotationArray==nil) {
		self.poiAnnotationArray=[NSMutableArray new];
		return;
	}
	
	[_mapView removeAnnotations:_poiAnnotationArray];
	
	[_poiAnnotationArray removeAllObjects];
	
}




#pragma mark - map location persistence
//
/***********************************************
 * @description			Saves Map location
 ***********************************************/
//

- (void)saveLocation:(CLLocationCoordinate2D)location {
	NSMutableDictionary *misc = [NSMutableDictionary dictionaryWithDictionary:[[CycleStreets sharedInstance].files misc]];
	[misc setValue:[NSString stringWithFormat:@"%f", location.latitude] forKey:@"latitude"];
	[misc setValue:[NSString stringWithFormat:@"%f", location.longitude] forKey:@"longitude"];
	[misc setValue:[NSString stringWithFormat:@"%f", _mapView.getZoomLevel] forKey:@"zoom"];
	[[CycleStreets sharedInstance].files setMisc:misc];
}

//
/***********************************************
 * @description			Loads any saved map lat/long and zoom
 ***********************************************/
//
-(void)loadLocation{
	
	BetterLog(@"");
	
	NSDictionary *misc = [[CycleStreets sharedInstance].files misc];
	NSString *latitude = [misc valueForKey:@"latitude"];
	NSString *longitude = [misc valueForKey:@"longitude"];
	int zoom = [[misc valueForKey:@"zoom"] intValue];
	
	CLLocationCoordinate2D initLocation;
	if (latitude != nil && longitude != nil) {
		initLocation.latitude = [latitude doubleValue];
		initLocation.longitude = [longitude doubleValue];
		[_mapView setCenterCoordinate:initLocation zoomLevel:zoom animated:YES];
	}
}



- (BOOL) assesWaypointLocationDistance:(CLLocationCoordinate2D)locationLatLon {
	
	for (WayPointVO *waypoint in _waypointArray) {
		
		CLLocationCoordinate2D fromLatLon = waypoint.coordinate;
		
		CLLocation *from = [[CLLocation alloc] initWithLatitude:fromLatLon.latitude longitude:fromLatLon.longitude];
		CLLocation *to = [[CLLocation alloc] initWithLatitude:locationLatLon.latitude longitude:locationLatLon.longitude];
		CLLocationDistance distance = [from getDistanceFrom:to];
		
		if(distance<MIN_START_FINISH_DISTANCE){
			return NO;
		}
		
	}
	return YES;
}



#pragma mark - Mapsearch delegate

- (void) didMoveToLocation:(CLLocationCoordinate2D)location {
	BetterLog(@"didMoveToLocation");
	
	[_mapView setCenterCoordinate:location zoomLevel:DEFAULT_ZOOM animated:YES];
	
	[self assessWayPointAddition:location];
	
}




//
/***********************************************
 * @description			MEMORY
 ***********************************************/
//

-(void)didReceiveMemoryWarning{
	[super didReceiveMemoryWarning];
		
}

@end
