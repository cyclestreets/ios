//
//  NewMapViewController.m
//  CycleStreets
//
//  Created by Neil Edwards on 26/09/2012.
//  Copyright (c) 2012 CycleStreets Ltd. All rights reserved.
//

#import "MapViewController.h"
#import "GlobalUtilities.h"
#import "RoutePlanMenuViewController.h"
#import "ExpandedUILabel.h"
#import "MapMarkerTouchView.h"
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
#import "POIListviewController.h"
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

#import <Crashlytics/Crashlytics.h>


static NSInteger DEFAULT_ZOOM = 15;
static NSInteger MAX_ZOOM_LOCATION = 16;
static NSInteger MAX_ZOOM_LOCATION_ACCURACY = 200;

static NSTimeInterval ACCIDENTAL_TAP_DELAY = 0.5;

//don't allow co-location of start/finish
static CLLocationDistance MIN_START_FINISH_DISTANCE = 100;

static NSString *const LOCATIONSUBSCRIBERID=@"MapView";


@interface MarkerMenuItem : UIMenuItem
@property (nonatomic, strong) WayPointVO* waypoint; 
@end
@implementation MarkerMenuItem
@synthesize waypoint;
@end


@interface MapViewController()<MKMapViewDelegate>

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


//rmmap
@property (nonatomic, strong) IBOutlet MKMapView					* mapView;
@property (nonatomic,strong)  NSString									*name;
@property (nonatomic, strong) CLLocation							* lastLocation;

// sub views
@property (nonatomic, strong) RoutePlanMenuViewController			* routeplanView;
@property (nonatomic, strong) WEPopoverController					* routeplanMenu;
@property (nonatomic, strong) MapLocationSearchViewController		* mapLocationSearchView;

// ui
@property (nonatomic, strong) IBOutlet UILabel						* attributionLabel;
@property (nonatomic, strong) IBOutlet RouteLineView				* lineView;
@property (nonatomic, strong) IBOutlet MapMarkerTouchView			* markerTouchView;

@property (nonatomic, assign) MapAlertType							alertType;


// waypoint ui
// will need ui for editing waypoints
@property(nonatomic,assign)  BOOL									markerMenuOpen;


@property (nonatomic, strong) InitialLocation						* initialLocation; // deprecate

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

-(void)displayLocationIndicator:(BOOL)display;


// waypoints
-(void)resetWayPoints;
-(void)removeWayPointAtIndex:(int)index;
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
		[self didSelectNewRoutePlan:notification];
	}

	if([name isEqualToString:CSMAPSTYLECHANGED]){
		[self didNotificationMapStyleChanged];
	}
	
}

#pragma mark notification response methods


- (void) didNotificationMapStyleChanged {
	
	NSArray *overlays=[_mapView overlaysInLevel:MKOverlayLevelAboveLabels];
	for(id <MKOverlay> overlay in overlays){
		if([overlay isKindOfClass:[MKTileOverlay class]] ){
			MKTileOverlay *newoverlay = [[MKTileOverlay alloc] initWithURLTemplate:[CycleStreets tileTemplate]];
			newoverlay.canReplaceMapContent = YES;
			[_mapView exchangeOverlay:overlay withOverlay:newoverlay];
			break;
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
	
	
	_mapView.rotateEnabled=YES;
    _mapView.pitchEnabled=YES;
    
    MKTileOverlay *newoverlay = [[MKTileOverlay alloc] initWithURLTemplate:[CycleStreets tileTemplate]];
	newoverlay.canReplaceMapContent = YES;
	[self.mapView addOverlay:newoverlay level:MKOverlayLevelAboveLabels];
	[_mapView setDelegate:self];
	_mapView.userTrackingMode=MKUserTrackingModeNone;
	_mapView.showsUserLocation=YES;
		
	
	[self initToolBarEntries];
	
	[self resetWayPoints];
	
	[_lineView setPointListProvider:self];
	
		
	[ViewUtilities drawUIViewEdgeShadow:_walkingRouteOverlayView atTop:YES];
	[self.view addSubview:_walkingRouteOverlayView];
	_walkingRouteOverlayView.y=self.view.height+_walkingRouteOverlayView.height;
	
	
	self.programmaticChange = NO;
	self.singleTapDidOccur=NO;
	
	_attributionLabel.text = [CycleStreets mapAttribution];
	
	[self updateUItoState:MapPlanningStateNoRoute];
	
	self.mapTapRecognizer=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapOnMap:)];
	_mapTapRecognizer.enabled=YES;
	[_mapView addGestureRecognizer:_mapTapRecognizer];
	
	[[RouteManager sharedInstance] loadSavedSelectedRoute];

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
														  action:@selector(locationButtonSelected)];
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
			BetterLog(@"MapPlanningStateNoRoute");
			
			_searchButton.enabled = YES;
			_locationButton.style=UIBarButtonItemStyleBordered;
			
			CLS_LOG(@"MapPlanningStateNoRoute toolbar items %@,%@,%@,%@", _locationButton,_searchButton, _leftFlex, _rightFlex);
			
			items=@[_locationButton,_searchButton, _leftFlex, _rightFlex];
			[self.toolBar setItems:items animated:YES ];
			
		}
		break;
		
		case MapPlanningStateLocating:
		{
			BetterLog(@"MapPlanningStateLocating");
			
			
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
			BetterLog(@"MapPlanningStateStartPlanning");
			
			_searchButton.enabled = YES;
			_locationButton.style=UIBarButtonItemStyleBordered;
			
			CLS_LOG(@"MapPlanningStateStartPlanning toolbar items %@,%@,%@", _locationButton,_searchButton, _leftFlex);
			
			items=[@[_locationButton,_searchButton,_leftFlex]mutableCopy];
            
            [self.toolBar setItems:items animated:YES ];
		}
		break;
		
		case MapPlanningStatePlanning:
		{
			BetterLog(@"MapPlanningStatePlanning");
			
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
			BetterLog(@"MapPlanningStateRoute");
			
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



//------------------------------------------------------------------------------------
#pragma mark - Core Location
//------------------------------------------------------------------------------------
//
/***********************************************
 * @description			Location Manager methods
 ***********************************************/
//

-(void)startLocating{
	
	BetterLog(@"");
	
	_mapView.showsUserLocation=NO;
	_mapView.showsUserLocation=YES;
	
	if(_uiState!=MapPlanningStateRoute)
		[self updateUItoState:MapPlanningStateLocating];
	
	
}


-(void)locationDidComplete:(MKUserLocation *)userLocation{
	
	BetterLog(@"");
	
	[self updateUItoState:_previousUIState];
	
	self.lastLocation=userLocation.location;
	

	if(_uiState!=MapPlanningStateRoute){
		[self updateUItoState:_previousUIState];
		[_mapView setCenterCoordinate:_lastLocation.coordinate zoomLevel:DEFAULT_ZOOM animated:YES];
	}else{
		
		MKMapRect mapRect=[self mapRectThatFitsBoundsSW:[self.route maxSouthWestForLocation:_lastLocation] NE:[self.route maxNorthEastForLocation:_lastLocation]];
		[_mapView setVisibleMapRect:mapRect edgePadding:UIEdgeInsetsMake(10, 10, 10, 10) animated:YES];
		
	}
	
	[_lineView setNeedsDisplay];
	
	[self assessLocationEffect];
}


-(void)locationDidFail:(NSNotification *)notification{
	
	[self updateUItoState:_previousUIState];
	
}



-(void)assessLocationEffect{
		
	if(_uiState==MapPlanningStateLocating){
		
		
	//	CLLocationCoordinate2D test=CLLocationCoordinate2DMake(self.lastLocation.coordinate.latitude-0.01, self.lastLocation.coordinate.longitude);
		
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
	
	[_lineView setNeedsDisplay];
	[self displayLocationIndicator:NO];
	
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
	
	BetterLog(@"");
	CLLocationCoordinate2D ne=[_route insetNorthEast];
	CLLocationCoordinate2D sw=[_route insetSouthWest];
	
	MKMapRect mapRect=[self mapRectThatFitsBoundsSW:sw NE:ne];
	[_mapView setVisibleMapRect:mapRect edgePadding:UIEdgeInsetsMake(10, 10, 10, 10) animated:YES];
	
	
	[_mapView removeAnnotations:[_mapView annotationsWithoutUserLocation]];
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
	
	[_lineView setNeedsDisplay];
	[self displayLocationIndicator:NO];
	
	// close left vc if open
	
	[self updateUItoState:MapPlanningStateRoute];
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
//
/***********************************************
 * @description			Waypoints
 ***********************************************/
//

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
	
	return annotation;
}


-(void)moveWayPointAtIndex:(int)startindex toIndex:(int)endindex{
	
	[_waypointArray exchangeObjectAtIndex:startindex withObjectAtIndex:endindex];
	
}


-(void)removeWayPoint:(WayPointVO*)waypoint{
	
	int found=[_waypointArray indexOfObject:waypoint];
	
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


-(void)removeWayPointAtIndex:(int)index{
	
	WayPointVO *waypoint=[_waypointArray objectAtIndex:index];
	
	[_waypointArray removeObject:waypoint];
	
	[self updateWaypointStatuses];
	
	[self assessUIState];
	
}


- (BOOL)canBecomeFirstResponder {
	return YES;
}


#pragma mark - MKMap Annotations


 
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
	
	 if ([annotation isKindOfClass:[MKUserLocation class]])
	 return nil;
	 
	 static NSString *reuseId = @"CSWaypointAnnotationView";
	 CSWaypointAnnotationView *annotationView = (CSWaypointAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:reuseId];
	
	 if (annotationView == nil){
		 annotationView = [[CSWaypointAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseId];
		 annotationView.draggable = YES;
		 annotationView.enabled=YES;
		 //annotationView.canShowCallout = YES;
	 } else {
		 annotationView.annotation = annotation;
	 }
	 
	 return annotationView;
}
 
 
-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view{
	
	if(_markerMenuOpen==YES)
		return;
	
	if(_uiState==MapPlanningStateRoute)
		return;
	
	if([view.annotation isKindOfClass:[MKUserLocation class]])
		return;
	
	UIMenuController *menuController = [UIMenuController sharedMenuController];
	
	if(menuController.isMenuVisible==NO){
		
		[self becomeFirstResponder];
		
		MarkerMenuItem *menuItem = [[MarkerMenuItem alloc] initWithTitle:@"Remove" action:@selector(removeMarkerAtIndexViaMenu:)];
		CSWaypointAnnotation *annotation=(CSWaypointAnnotation*)view.annotation;
		menuItem.waypoint=annotation.dataProvider;
		menuController.menuItems = [NSArray arrayWithObject:menuItem];
		
	}
	
	CGRect markerRect=CGRectMake(view.left-12, view.top+5, view.width, view.height);
	[menuController setTargetRect:markerRect inView:self.mapView];
	
	if(menuController.isMenuVisible==NO)
		[menuController setMenuVisible:YES animated:YES];
	
	_markerMenuOpen=YES;
	_markerTouchView.proxyTouchEvent=NO;
	
}


-(void)removeMarkerAtIndexViaMenu:(UIMenuController*)menuController {
	
	MarkerMenuItem *menuItem = [[[UIMenuController sharedMenuController] menuItems] objectAtIndex:0];
	
	if(menuItem.waypoint!=nil){
		
		[self removeWayPoint:menuItem.waypoint];
	}
	
	_markerMenuOpen=NO;
	_markerTouchView.proxyTouchEvent=NO;
	
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


- (void) locationButtonSelected {
	
	BetterLog(@"");
	
	[self startLocating];
	
}



- (IBAction) searchButtonSelected {
	
	BetterLog(@"");
	
	if (self.mapLocationSearchView == nil) {
		self.mapLocationSearchView = [[MapLocationSearchViewController alloc] initWithNibName:@"MapLocationSearchView" bundle:nil];
	}
	_mapLocationSearchView.locationReceiver = self;
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
	
    self.routeplanView=[[RoutePlanMenuViewController alloc]initWithNibName:@"RoutePlanMenuView" bundle:nil];
	_routeplanView.plan=_route.plan;
    
	self.routeplanMenu = [[popoverClass alloc] initWithContentViewController:_routeplanView];
	_routeplanMenu.delegate = self;
	
	[_routeplanMenu presentPopoverFromBarButtonItem:_changePlanButton toolBar:_toolBar permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    
	
}


-(void)didSelectNewRoutePlan:(NSNotification*)notification{
	
	NSDictionary *userInfo=notification.userInfo;
	
	[[RouteManager sharedInstance] loadRouteForRouteId:_route.routeid withPlan:[userInfo objectForKey:@"planType"]];
	
	[_routeplanMenu dismissPopoverAnimated:YES];
	
}




#pragma mark - MKMap delegate
//
/***********************************************
 * @description			RMMap Touch delegates
 ***********************************************/
//

- (void) didTapOnMap:(UITapGestureRecognizer*)recogniser {
	
	BetterLog(@"");
	
	if(_markerMenuOpen==YES){
		_markerMenuOpen=NO;
		_markerTouchView.proxyTouchEvent=NO;
		return;
	}
	
	
	CGPoint touchPoint = [recogniser locationInView:self.mapView];
    CLLocationCoordinate2D touchMapCoordinate = [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
	[self addWayPointAtCoordinate:touchMapCoordinate];
	
}



- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState{
	
	BetterLog(@"%i",newState);
	
	if (newState == MKAnnotationViewDragStateEnding) {
		
		[view setDragState:MKAnnotationViewDragStateNone]; //NOTE: doesnt seem to fire this for custom annotations
    }
	
}


- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id <MKOverlay>)overlay{
    
    if ([overlay isKindOfClass:[MKTileOverlay class]]) {
        return [[MKTileOverlayRenderer alloc] initWithTileOverlay:overlay];
        
    }
	// add routeline overlay here
    
    return nil;
}


- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
	
	[self locationDidComplete:userLocation];
	
}



#pragma mark map location persistence
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
		[_lineView setNeedsDisplay];
	}
}

- (BOOL)locationInBounds:(CLLocationCoordinate2D)location {
	//CGRect bounds = _mapView.contents.screenBounds;
	//CLLocationCoordinate2D nw = [_mapView pixelToLatLong:bounds.origin];
	//CLLocationCoordinate2D se = [_mapView pixelToLatLong:CGPointMake(bounds.origin.x + bounds.size.width, bounds.origin.y + bounds.size.height)];
	
	//if (nw.latitude < location.latitude) return NO;
	//if (nw.longitude > location.longitude) return NO;
	//if (se.latitude > location.latitude) return NO;
	//if (se.longitude < location.longitude) return NO;
	
	return YES;
}

#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
- (BOOL) assesWaypointLocationDistance:(CLLocationCoordinate2D)locationLatLon {
	
	for (WayPointVO *waypoint in _waypointArray) {
		
		CLLocationCoordinate2D fromLatLon = waypoint.coordinate;
		
		CLLocation *from = [[CLLocation alloc] initWithLatitude:fromLatLon.latitude
													  longitude:fromLatLon.longitude];
		CLLocation *to = [[CLLocation alloc] initWithLatitude:locationLatLon.latitude
													longitude:locationLatLon.longitude];
		CLLocationDistance distance = [from getDistanceFrom:to];
		
		if(distance<MIN_START_FINISH_DISTANCE){
			return NO;
		}
		
	}
	return YES;
}



//
/***********************************************
 * @description			DELEGATE METHODS
 ***********************************************/
//


#pragma mark Mapsearch delegate

- (void) didMoveToLocation:(CLLocationCoordinate2D)location {
	BetterLog(@"didMoveToLocation");
	
	[_mapView setCenterCoordinate:location zoomLevel:DEFAULT_ZOOM animated:YES];
	
	[self assessWayPointAddition:location];
	[_lineView setNeedsDisplay];
	[self displayLocationIndicator:YES];
	
	[[UserLocationManager sharedInstance] stopUpdatingLocationForSubscriber:LOCATIONSUBSCRIBERID];
}



#pragma mark WEPopoverControllerDelegate 

- (void)popoverControllerDidDismissPopover:(WEPopoverController *)thePopoverController {
	//Safe to release the popover here
	self.routeplanMenu = nil;
}

- (BOOL)popoverControllerShouldDismissPopover:(WEPopoverController *)thePopoverController {
	//The popover is automatically dismissed if you click outside it, unless you return NO here
	return YES;
}


#pragma mark point list provider 
// PointListProvider
+ (NSArray *) pointList:(RouteVO *)route withView:(MKMapView *)mapView {
	
	NSMutableArray *points = [[NSMutableArray alloc] initWithCapacity:10];
	if (route == nil) {
		return points;
	}
	
	for (int i = 0; i < [route numSegments]; i++) {
		if (i == 0)
		{	// start of first segment
			CSPointVO *p = [[CSPointVO alloc] init];
			SegmentVO *segment = [route segmentAtIndex:i];
			CLLocationCoordinate2D coordinate = [segment segmentStart];
			//CGPoint pt = [mapView.contents latLongToPixel:coordinate];
			//p.p = pt;
			//p.isWalking=segment.isWalkingSection;
			//[points addObject:p];
		}
		// remainder of all segments
		SegmentVO *segment = [route segmentAtIndex:i];
		NSArray *allPoints = [segment allPoints];
		for (int i = 1; i < [allPoints count]; i++) {
			CSPointVO *latlon = [allPoints objectAtIndex:i];
			CLLocationCoordinate2D coordinate;
			coordinate.latitude = latlon.p.y;
			coordinate.longitude = latlon.p.x;
			//CGPoint pt = [mapView.contents latLongToPixel:coordinate];
			CSPointVO *screen = [[CSPointVO alloc] init];
			//screen.p = pt;
			screen.isWalking=segment.isWalkingSection;
			[points addObject:screen];
		}
	}
	
	return points;
}

- (NSArray *) pointList {
	return [MapViewController pointList:self.route withView:self.mapView];
}

// LocationProvider
#pragma mark location provider

- (float)getX {
	//CGPoint p = [self.mapView.contents latLongToPixel:self.lastLocation.coordinate];
	return 0;
}

- (float)getY {
	//CGPoint p = [self.mapView.contents latLongToPixel:self.lastLocation.coordinate];
	return 0;
}

- (float)getRadius {
	
	//double metresPerPixel = [self.mapView.contents metersPerPixel];
	//float locationRadius=(self.lastLocation.horizontalAccuracy / metresPerPixel);
	return 0;
	//return MAX(locationRadius, 40.0f);
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
