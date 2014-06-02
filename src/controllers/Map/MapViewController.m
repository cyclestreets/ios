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
#import "RMTileSource.h"
#import "PhotoMapListVO.h"
#import "PhotoMapVO.h"
#import "MapLocationSearchViewController.h"
#import "CSPointVO.h"
#import "Files.h"
#import "RouteManager.h"
#import "GlobalUtilities.h"
#import "AppConstants.h"
#import "SettingsManager.h"
#import "HudManager.h"
#import "UserLocationManager.h"
#import	"WayPointVO.h"
#import "IIViewDeckController.h"
#import "WayPointViewController.h"
#import "UIView+Additions.h"
#import "ViewUtilities.h"
#import "MKMapView+Additions.h"
#import "CSWaypointAnnotation.h"
#import "CSWaypointAnnotationView.h"
#import "UIActionSheet+BlocksKit.h"

#import "RouteVO.h"
#import "MapLocationSearchViewController.h"
#import "WayPointViewController.h"

#import "CSRoutePolyLineOverlay.h"
#import "CSRoutePolyLineRenderer.h"


#import <Crashlytics/Crashlytics.h>


static NSInteger DEFAULT_ZOOM = 15;

//don't allow co-location of start/finish
static CLLocationDistance MIN_START_FINISH_DISTANCE = 100;


@interface MarkerMenuItem : UIMenuItem
@property (nonatomic, strong) WayPointVO* waypoint; 
@end
@implementation MarkerMenuItem
@synthesize waypoint;
@end


@interface MapViewController()<MKMapViewDelegate,UIActionSheetDelegate,CLLocationManagerDelegate>

// tool bar
@property (nonatomic, strong) IBOutlet UIToolbar					* toolBar;
@property (nonatomic, strong) UIBarButtonItem						* locationButton;
@property (nonatomic, strong) UIBarButtonItem						* activeLocationButton;
@property (nonatomic, strong) UIBarButtonItem						* searchButton;
@property (nonatomic, strong) UIBarButtonItem						* routeButton;
@property (nonatomic, strong) UIBarButtonItem						* changePlanButton;
@property (nonatomic, strong) UIActivityIndicatorView				* locatingIndicator;
@property (nonatomic, strong) UIBarButtonItem						* leftFlex;
@property (nonatomic, strong) UIBarButtonItem						* rightFlex;
@property (nonatomic,strong)  UIBarButtonItem						* waypointButton;


@property(nonatomic,strong) IBOutlet  UIView						*walkingRouteOverlayView;
@property(nonatomic,assign)  BOOL									walkingOverlayisVisible;


//map
@property (nonatomic, strong) IBOutlet MKMapView					* mapView;
@property (nonatomic,strong)  NSString								*name;
@property (nonatomic, strong) CLLocation							* lastLocation;
@property (nonatomic,strong)  CSRoutePolyLineOverlay				* routeOverlay;
@property (nonatomic,strong)  CSRoutePolyLineRenderer				* routeOverlayRenderer;


// sub views
@property (nonatomic, strong) MapLocationSearchViewController		* mapLocationSearchView;

// ui
@property (nonatomic, strong) IBOutlet UILabel						* attributionLabel;

@property (nonatomic, assign) MapAlertType							alertType;


// waypoint ui
// will need ui for editing waypoints
@property(nonatomic,assign)  BOOL									markerMenuOpen;
@property (nonatomic,strong)  CSWaypointAnnotationView				*selectedAnnotation;

// data
@property (nonatomic, strong) RouteVO								* route;
@property (nonatomic, strong) NSMutableArray						* waypointArray;
@property (nonatomic, strong) RMMarker								* activeMarker;



// state
@property (nonatomic, assign) BOOL									doingLocation;
@property (nonatomic, assign) BOOL									programmaticChange;
@property (nonatomic, assign) BOOL									avoidAccidentalTaps;
@property (nonatomic, assign) BOOL									singleTapDidOccur;
@property (nonatomic, assign) CGPoint								singleTapPoint;
@property (nonatomic, assign) MapPlanningState						uiState;
@property (nonatomic, assign) MapPlanningState						previousUIState;


@property (nonatomic,strong)  UITapGestureRecognizer				*mapTapRecognizer;

// ui
- (void)initToolBarEntries;
- (void)updateUItoState:(MapPlanningState)state;



// waypoints
-(void)resetWayPoints;
-(void)removeWayPointAtIndex:(NSUInteger)index;
-(void)assessWayPointAddition:(CLLocationCoordinate2D)cooordinate;
-(void)addWayPointAtCoordinate:(CLLocationCoordinate2D)coords;

// waypoint menu
-(void)removeMarkerAtIndexViaMenu:(UIMenuController*)menuController;

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
	
}

#pragma mark notification response methods


- (void) didNotificationMapStyleChanged {
	
	NSArray *overlays=[_mapView overlaysInLevel:MKOverlayLevelAboveLabels];
	
	NSString *tileTemplate=[CycleStreets tileTemplate];
	
	if(overlays.count==0){
		
		MKTileOverlay *newoverlay = [[MKTileOverlay alloc] initWithURLTemplate:tileTemplate];
		newoverlay.canReplaceMapContent = YES;
		newoverlay.maximumZ=MAX_ZOOM_LOCATION;
		[_mapView insertOverlay:newoverlay atIndex:0 level:MKOverlayLevelAboveLabels];
		
	}else{
		
		for(id <MKOverlay> overlay in overlays){
			if([overlay isKindOfClass:[MKTileOverlay class]] ){
				
				
				if([tileTemplate isEqualToString:MAPPING_TILETEMPLATE_APPLE]){
					
					[_mapView removeOverlay:overlay];
					
					break;
					
				}else{
					
					MKTileOverlay *newoverlay = [[MKTileOverlay alloc] initWithURLTemplate:tileTemplate];
					newoverlay.canReplaceMapContent = YES;
					newoverlay.maximumZ=MAX_ZOOM_LOCATION;
					[_mapView removeOverlay:overlay];
					[_mapView insertOverlay:newoverlay atIndex:0 level:MKOverlayLevelAboveLabels]; // always at bottom
					
					break;
					
				}
				
				
				break;
			}
		}
		
	}
	
	
	
	
	
	 
	_attributionLabel.text = [CycleStreets mapAttribution];
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
	
	[super viewWillAppear:animated];
	
}


-(void)createPersistentUI{
	
	self.displaysConnectionErrors=NO;
	
	_toolBar.clipsToBounds=YES;
	
	_mapView.rotateEnabled=YES;
    _mapView.pitchEnabled=YES;
    
//    MKTileOverlay *newoverlay = [[MKTileOverlay alloc] initWithURLTemplate:[CycleStreets tileTemplate]];
//	newoverlay.canReplaceMapContent = YES;
//	newoverlay.maximumZ=MAX_ZOOM_LOCATION;
//	[self.mapView addOverlay:newoverlay level:MKOverlayLevelAboveLabels];
	[_mapView setDelegate:self];
	_mapView.userTrackingMode=MKUserTrackingModeNone;
	
	[self initToolBarEntries];
	
	[self resetWayPoints];
	
		
	[ViewUtilities drawUIViewEdgeShadow:_walkingRouteOverlayView atTop:YES];
	[self.view addSubview:_walkingRouteOverlayView];
	_walkingRouteOverlayView.y=self.view.height+_walkingRouteOverlayView.height;
	
	
	self.programmaticChange = NO;
	self.singleTapDidOccur=NO;
	
	_attributionLabel.text = [CycleStreets mapAttribution];
	
	[self updateUItoState:MapPlanningStateNoRoute];
	
	self.mapTapRecognizer=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapOnMap:)];
	_mapTapRecognizer.numberOfTapsRequired=1;
	_mapTapRecognizer.enabled=YES;
	_mapTapRecognizer.delaysTouchesBegan=YES;
	[_mapView addGestureRecognizer:_mapTapRecognizer];
	
	//TODO: logic for map if no selected route exists
	BOOL hasSelectedRoute=[[RouteManager sharedInstance] loadSavedSelectedRoute];
	
	if(!hasSelectedRoute){
		_mapView.showsUserLocation=YES;
	}
}


-(void)createNonPersistentUI{
	
	
	
	
	
}


-(void)initToolBarEntries{
	
	self.locatingIndicator=[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	_locatingIndicator.hidesWhenStopped=YES;
	
	self.activeLocationButton = [[UIBarButtonItem alloc] initWithCustomView:_locatingIndicator ];
	_activeLocationButton.style	= UIBarButtonItemStyleDone;
	
	self.waypointButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"CSBarButton_waypoint.png"]
														   style:UIBarButtonItemStyleBordered
														  target:self
														  action:@selector(showWayPointView)];
	_waypointButton.width = 40;
	
	self.locationButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"CSBarButton_location.png"]
														   style:UIBarButtonItemStyleBordered
														  target:self
														  action:@selector(didSelectLocateUserbutton)];
	_locationButton.width = 40;
	
	self.searchButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"CSBarButton_search.png"]
													   style:UIBarButtonItemStyleBordered
													  target:self
													  action:@selector(searchButtonSelected)];
	_searchButton.width = 40;
	
	self.changePlanButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"CSBarButton_routePlan.png"]
													   style:UIBarButtonItemStyleBordered
													  target:self
													  action:@selector(showRoutePlanMenu:)];
	
	
	self.routeButton = [[UIBarButtonItem alloc] initWithTitle:@"Plan Route"
														style:UIBarButtonItemStyleBordered
													   target:self
													   action:@selector(routeButtonSelected)];
	
	
	
	self.leftFlex=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	self.rightFlex=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	
	
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
			//BetterLog(@"MapPlanningStateNoRoute");
			
			_searchButton.enabled = YES;
			_locationButton.style=UIBarButtonItemStyleBordered;
			
			CLS_LOG(@"MapPlanningStateNoRoute toolbar items %@,%@,%@,%@", _locationButton,_searchButton, _leftFlex, _rightFlex);
			
			items=@[_locationButton,_searchButton, _leftFlex, _rightFlex];
			[self.toolBar setItems:items animated:YES ];
			
		}
		break;
		
		case MapPlanningStateLocating:
		{
			//BetterLog(@"MapPlanningStateLocating");
			
			
			_searchButton.enabled = YES;
			_locationButton.style=UIBarButtonItemStyleDone;
			
			if([self shouldShowWayPointUI]==YES){
				items=@[_waypointButton,_locationButton,_searchButton, _leftFlex, _rightFlex];
			}else{
				
				CLS_LOG(@"MapPlanningStateLocating shouldShowWayPointUI=YES toolbar items %@,%@,%@,%@", _locationButton,_searchButton, _leftFlex, _rightFlex);
				
				items=@[_locationButton,_searchButton, _leftFlex, _rightFlex];
			}
			
			[self.toolBar setItems:items animated:YES ];
			
			
			
		}
		break;
		
		case MapPlanningStateStartPlanning:
		{
			//BetterLog(@"MapPlanningStateStartPlanning");
			
			_searchButton.enabled = YES;
			_locationButton.style=UIBarButtonItemStyleBordered;
			
			CLS_LOG(@"MapPlanningStateStartPlanning toolbar items %@,%@,%@", _locationButton,_searchButton, _leftFlex);
			
			items=[@[_locationButton,_searchButton,_leftFlex]mutableCopy];
            
            [self.toolBar setItems:items animated:YES ];
		}
		break;
		
		case MapPlanningStatePlanning:
		{
			//BetterLog(@"MapPlanningStatePlanning");
			
			_routeButton.title = @"Plan route";
			_searchButton.enabled = YES;
			_locationButton.style=UIBarButtonItemStyleBordered;
			
			CLS_LOG(@"MapPlanningStatePlanning toolbar items %@,%@,%@,%@,%@", _waypointButton, _locationButton,_searchButton,_leftFlex,_routeButton);
			
			items=@[_waypointButton, _locationButton,_searchButton,_leftFlex,_routeButton];
            [self.toolBar setItems:items animated:YES ];
		}
		break;
			
		case MapPlanningStateRoute:
		{
			//BetterLog(@"MapPlanningStateRoute");
			
			_routeButton.title = @"New route";
			_locationButton.style=UIBarButtonItemStyleBordered;
			_searchButton.enabled = YES;
			
			CLS_LOG(@"MapPlanningStateRoute toolbar items %@,%@,%@,%@,%@", _locationButton,_searchButton,_leftFlex, _changePlanButton,_routeButton);
			
			items=@[_locationButton,_searchButton,_leftFlex, _changePlanButton,_routeButton];
            [self.toolBar setItems:items animated:NO ];
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


// called continuously as map locates user
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
	
	[self locationDidComplete:userLocation];
	
}

// gps bar button selected
-(IBAction)didSelectLocateUserbutton{
	
	BetterLog(@"");
	
	if(_uiState==MapPlanningStateLocating){
		
		_mapView.showsUserLocation=NO;
		
		_programmaticChange=NO;
		
		[self updateUItoState:_previousUIState];
		
	}else{
		
		_programmaticChange=YES;
		
		_mapView.showsUserLocation=NO;
		_mapView.showsUserLocation=YES;
		
		[self updateUItoState:MapPlanningStateLocating];
		
	}
	
}


// called as showsUserLocation is set to YES
- (void)mapViewWillStartLocatingUser:(MKMapView *)mapView{
	
	
}


// called when showsUserLocation is set to NO
- (void)mapViewDidStopLocatingUser:(MKMapView *)mapView{
	
	
	[self updateUItoState:_previousUIState];
	
}


-(void)locationDidComplete:(MKUserLocation *)userLocation{
	
	BetterLog(@"");
	
	
	
	self.lastLocation=userLocation.location;
	

	if(_uiState!=MapPlanningStateRoute){
		[self updateUItoState:_previousUIState];
		[_mapView setCenterCoordinate:_lastLocation.coordinate zoomLevel:DEFAULT_ZOOM animated:YES];
	}else{
		
		MKMapRect mapRect=[self mapRectThatFitsBoundsSW:[self.route maxSouthWestForLocation:_lastLocation] NE:[self.route maxNorthEastForLocation:_lastLocation]];
		[_mapView setVisibleMapRect:mapRect edgePadding:UIEdgeInsetsMake(10, 10, 10, 10) animated:YES];
		
	}
	
	
	[self assessLocationEffect];
}


-(void)locationDidFail:(NSNotification *)notification{
	
	[self updateUItoState:_previousUIState];
	
}



-(void)assessLocationEffect{
		
	if(_uiState==MapPlanningStateLocating){
		
		[self addWayPointAtCoordinate:_lastLocation.coordinate];
		
		if(_uiState!=MapPlanningStateRoute)
			[self updateUItoState:_previousUIState];
		
		[self assessUIState];
		
	}
		
}



#pragma mark Route Display
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
	[_waypointArray removeAllObjects];
	
	[_routeOverlay resetOverlay];
	[_routeOverlayRenderer setNeedsDisplay];
	
	[self updateUItoState:MapPlanningStateNoRoute];
	
	[[RouteManager sharedInstance] clearSelectedRoute];
}


- (MKMapRect) mapRectThatFitsBoundsSW:(CLLocationCoordinate2D)sw NE:(CLLocationCoordinate2D)ne{
    MKMapPoint pSW = MKMapPointForCoordinate(sw);
    MKMapPoint pNE = MKMapPointForCoordinate(ne);
	
    double antimeridianOveflow =
	(ne.longitude > sw.longitude) ? 0 : MKMapSizeWorld.width;
	
    return MKMapRectMake(pSW.x, pNE.y,
						 (pNE.x - pSW.x) + antimeridianOveflow,
						 (pSW.y - pNE.y));
}

- (void) newRoute {
	
	[self updateUItoState:MapPlanningStateRoute];
	
	BetterLog(@"");
	CLLocationCoordinate2D ne=[_route insetNorthEast];
	CLLocationCoordinate2D sw=[_route insetSouthWest];
	
	//TODO: this needs to be optimised so the map scaling only occurs once and
	// the ui state is set correctly at end.
	
	MKMapRect mapRect=[self mapRectThatFitsBoundsSW:sw NE:ne];
	[_mapView setVisibleMapRect:mapRect edgePadding:UIEdgeInsetsMake(10, 50, 50, 10) animated:YES];
	
	// or:
	//[_mapView showAnnotations:@[array of annotations] animated:NO];
	
	//[_mapView removeAnnotations:[_mapView annotationsWithoutUserLocation]];
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
	
	[self showWalkingOverlay];
	
	if(_routeOverlay==nil){
		self.routeOverlay = [[CSRoutePolyLineOverlay alloc] initWithRoute:_route];
		[self.mapView addOverlay:_routeOverlay];
	}else{
		[_routeOverlay updateForDataProvider:_route];
		[_routeOverlayRenderer setNeedsDisplay];
	}
	
	[self updateUItoState:MapPlanningStateRoute];
	
}


- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id <MKOverlay>)overlay{
	
    
    if ([overlay isKindOfClass:[MKTileOverlay class]]) {
        return [[MKTileOverlayRenderer alloc] initWithTileOverlay:overlay];
        
    }
	
	if([overlay isKindOfClass:[CSRoutePolyLineOverlay class]]){
		self.routeOverlayRenderer = [[CSRoutePolyLineRenderer alloc] initWithOverlay:overlay];
		_routeOverlayRenderer.primaryColor=[UIColor purpleColor];
		_routeOverlayRenderer.secondaryColor=[UIColor greenColor];
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

-(void)showWayPointView{
	
	UINavigationController *nav=(UINavigationController*)self.viewDeckController.leftController;
	WayPointViewController *waypointController=(WayPointViewController*)nav.topViewController;
	waypointController.delegate=self;
	waypointController.dataProvider=_waypointArray;
	
	[self.viewDeckController openLeftViewAnimated:YES];
	
}


-(void)resetWayPoints{
	
	[_waypointArray removeAllObjects];
	
	//[[_mapView markerManager] removeMarkers];
}


-(void)assessWayPointAddition:(CLLocationCoordinate2D)cooordinate{
	
	if(_uiState==MapPlanningStateRoute)
		return;
	
	
	BOOL acceptWaypoint=YES;
	
	// location is too near any other locations> reject
	if (_uiState==MapPlanningStatePlanning || _uiState==MapPlanningStateStartPlanning) {
		
		acceptWaypoint=[self assesWaypointLocationDistance:cooordinate];
		
		if(acceptWaypoint==NO){
			[[HudManager sharedInstance] showHudWithType:HUDWindowTypeError withTitle:@"Point error" andMessage:@"Touch somewhere else or select a different Search location to set this point further away." andDelay:3 andAllowTouch:NO];
			return;
		}
	}
	
	
	//explicit click while autolocation was happening. Turn off auto, accept click.
	if (!_programmaticChange) {
		if (_uiState==MapPlanningStateLocating) {
			[self didSelectLocateUserbutton];
		}
	}
		
	
	[self addWayPointAtCoordinate:cooordinate];
	
	[self assessUIState];
	
	[self saveLocation:cooordinate];
}


-(void)assessUIState{
	
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


// initial Waypoint creation
-(void)addWayPointAtCoordinate:(CLLocationCoordinate2D)coords{
	
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
		[self.viewDeckController closeLeftViewAnimated:YES];
	}
}


// update Waypoint types from creation, as can change if waypoints are removed post creation ie intermediate can become end etc
-(void)updateWaypointStatuses{
	
	[_mapView removeAnnotations:_mapView.annotationsWithoutUserLocation];
	
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
	
	CSWaypointAnnotation *annotation=[[CSWaypointAnnotation alloc]init];
	annotation.coordinate=coordinate;
	annotation.index=index;
	annotation.dataProvider=waypoint;
	annotation.menuEnabled=NO;
	
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


-(WayPointVO*)findWayPointForMarker:(RMMarker*)marker{
	
	for (WayPointVO *waypoint in _waypointArray) {
		
		if(marker==waypoint.marker)
			return waypoint;
		
	}
	return nil;
	
}


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

- (void) didTapOnMap:(UITapGestureRecognizer*)recogniser {
	
	BetterLog(@"");
	
	CGPoint touchPoint = [recogniser locationInView:self.mapView];
    CLLocationCoordinate2D touchMapCoordinate = [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
	CLLocation *location=[[CLLocation alloc]initWithLatitude:touchMapCoordinate.latitude longitude:touchMapCoordinate.longitude];
	
	[self performSelector:@selector(addLocationToMapForGesture:) withObject:location afterDelay:0.7];
	
	
}



-(void)addLocationToMapForGesture:(CLLocation*)location{
	
	if(_uiState==MapPlanningStateRoute)
		return;
	
	if(_selectedAnnotation!=nil){
		_selectedAnnotation.selected=NO;
		return;
	}
		
	
	[self assessWayPointAddition:location.coordinate];
}



- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState{
	
	if(_uiState==MapPlanningStateRoute){
		BetterLog(@"MapPlanningStateRoute");
		return;
	}
		
	
	BetterLog(@"From %lu to %lu",oldState, newState);
	
	CSWaypointAnnotationView *annotationView=(CSWaypointAnnotationView*)view;
		
	
	if (newState == MKAnnotationViewDragStateEnding) {
		
		[annotationView setDragState:MKAnnotationViewDragStateNone]; //NOTE: doesnt seem to fire this for custom annotations
		
    }else if (newState==MKAnnotationViewDragStateCanceling) {
		
		[annotationView setDragState:MKAnnotationViewDragStateNone]; //NOTE: doesnt seem to fire this for custom annotations
    }
	
	
}








#pragma mark - MKMap Annotations

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
	
	 if ([annotation isKindOfClass:[MKUserLocation class]])
	 return nil;
	 
	 static NSString *reuseId = @"CSWaypointAnnotationView";
	 CSWaypointAnnotationView *annotationView = (CSWaypointAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:reuseId];
	
	//TODO: logic to ensure reused annotationviews have the right state
	// this occurs due to re creation of annotations if one is removed
	// or if a route is loaded
	
	 if (annotationView == nil){
		 
		 annotationView = [[CSWaypointAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];
		 annotationView.draggable = _uiState!=MapPlanningStateRoute;
		 annotationView.enabled=_uiState!=MapPlanningStateRoute;
		 annotationView.selected=YES;
		 annotationView.canShowCallout=YES;
		 
		 UIButton *calloutButton=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 50)];
		 [calloutButton setImage:[UIImage imageNamed:@"UIButtonBarTrash.png"] forState:UIControlStateNormal];
		 calloutButton.backgroundColor=[UIColor redColor];
		 annotationView.rightCalloutAccessoryView=calloutButton;
		 
		 
		 
	 } else {
		 annotationView.annotation = annotation;
	 }
	 
	 return annotationView;
}

-(void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view{
	
	BetterLog(@"");
	
	self.selectedAnnotation=nil;
	
	view.selected=YES;
	
}
 
 
-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view{
	
	BetterLog(@"");
	
	self.selectedAnnotation=(CSWaypointAnnotationView*)view;
	
	[view setDragState:MKAnnotationViewDragStateStarting];
	
}



- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control{
	
	CSWaypointAnnotationView *annotationView=(CSWaypointAnnotationView*)view;
	CSWaypointAnnotation* annotation=annotationView.annotation;
	
	[self removeWayPoint:annotation.dataProvider];
	
	
}


-(void)removeMarkerAtIndexViaMenu:(UIMenuController*)menuController {
	
	MarkerMenuItem *menuItem = [[[UIMenuController sharedMenuController] menuItems] objectAtIndex:0];
	
	if(menuItem.waypoint!=nil){
		
		[self removeWayPoint:menuItem.waypoint];
	}
	
	_markerMenuOpen=NO;
	
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
							 initWithTitle:@"CycleStreets"
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



- (IBAction) searchButtonSelected {
	
	BetterLog(@"");
	
	if (self.mapLocationSearchView == nil) {
		self.mapLocationSearchView = [[MapLocationSearchViewController alloc] initWithNibName:@"MapLocationSearchView" bundle:nil];
	}
	//_mapLocationSearchView.locationReceiver = self;
	_mapLocationSearchView.centreLocation = [_mapView centerCoordinate];
	
	[self presentModalViewController:_mapLocationSearchView	animated:YES];
	
}



- (IBAction) routeButtonSelected {
	
	BetterLog(@"");
	
	if (_uiState == MapPlanningStatePlanning) {
		
		[[RouteManager sharedInstance] loadRouteForWaypoints:_waypointArray];
		
	} else if (_uiState == MapPlanningStateRoute) {
		
		[self createAlertForType:MapAlertTypeClearRoute];
		
	}
}


-(void)waypointButtonSelected{
	
	BetterLog(@"");
	
	WayPointViewController *waypointController=(WayPointViewController*)self.viewDeckController.leftController;
	waypointController.dataProvider=_waypointArray;
	
	[self.viewDeckController openLeftViewAnimated:YES];
	
}



/***********************************************
 * @description			ROUTE PLAN POPUP METHODS
 ***********************************************/
//

-(IBAction)showRoutePlanMenu:(id)sender{
	
	NSString *currentPlan=_route.plan;
	
	__weak __typeof(&*self)weakSelf = self;
	UIActionSheet *actionSheet=[UIActionSheet bk_actionSheetWithTitle:@"Re-route with new plan type"];
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
            }else{
				button.titleLabel.highlightedTextColor=UIColorFromRGB(0x509720);
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
	//[misc setValue:[NSString stringWithFormat:@"%f", _mapView.contents.zoom] forKey:@"zoom"];
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
