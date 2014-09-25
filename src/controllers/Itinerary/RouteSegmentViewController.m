/*

Copyright (C) 2010  CycleStreets Ltd

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

*/

//  RouteSegmentViewController.m
//  CycleStreets
//
//


#import "RouteSegmentViewController.h"
#import "SegmentVO.h"
#import "MapViewController.h"
#import "AppDelegate.h"
#import "CycleStreets.h"
#import "PhotoMapListVO.h"
#import "PhotoMapVO.h"
#import "PhotoMapImageLocationViewController.h"
#import "CSPointVO.h"
#import "AppConstants.h"
#import "GlobalUtilities.h"
#import "ExpandedUILabel.h"
#import "GradientView.h"
#import "CSSegmentFooterView.h"
#import "UserLocationManager.h"
#import "UIView+Additions.h"
#import <MapKit/MapKit.h>
#import "MKMapView+Additions.h"
#import "CSRouteSegmentAnnotation.h"
#import "CSRouteSegmentAnnotationView.h"
#import "PhotoManager.h"
#import "CSPhotomapAnnotation.h"
#import "CSPhotomapAnnotationView.h"
#import "CSRoutePolyLineOverlay.h"
#import "CSRoutePolyLineRenderer.h"
#import "CSMapSource.h"


@interface RouteSegmentViewController()< MKMapViewDelegate>


@property (nonatomic, weak) IBOutlet UILabel							* attributionLabel;
@property (nonatomic, weak) IBOutlet MKMapView							* mapView;
@property (nonatomic, weak) IBOutlet UIToolbar							* toolBar;
@property (nonatomic, weak) IBOutlet UIBarButtonItem					* locationButton;
@property (nonatomic, weak) IBOutlet UIBarButtonItem					* infoButton;
@property (nonatomic, weak) IBOutlet UIBarButtonItem					* photoIconButton;
@property (nonatomic, weak) IBOutlet UIBarButtonItem					* prevPointButton;
@property (nonatomic, weak) IBOutlet UIBarButtonItem					* nextPointButton;

@property (nonatomic, strong) CSSegmentFooterView						* footerView;
@property (nonatomic) BOOL												footerIsHidden;

@property (nonatomic,strong)  SegmentVO									* currentSegment;
@property (nonatomic,strong)  CSRoutePolyLineOverlay					* routeOverlay;
@property (nonatomic,strong)  CSRoutePolyLineRenderer					* routeOverlayRenderer;

@property (nonatomic,strong)  CSRoutePolyLineOverlay					* segmentOverlay;
@property (nonatomic,strong)  CSRoutePolyLineRenderer					* segmentOverlayRenderer;

@property (nonatomic,strong)  CSMapSource								* activeMapSource;


@property (nonatomic, strong) CLLocation								* currentLocation;
@property (nonatomic,assign)  BOOL										isLocating;

@property (nonatomic) BOOL												photoIconsVisisble;
@property (nonatomic, strong) NSMutableArray							* photoMarkers;
@property (nonatomic, strong) PhotoMapImageLocationViewController		* locationView;
@property (nonatomic, assign) BOOL										photomapQuerying;


@property (nonatomic,strong)  CSRouteSegmentAnnotation						*startAnnotation;
@property (nonatomic,strong)  CSRouteSegmentAnnotation						*endAnnotation;


@property (nonatomic,strong)  UISwipeGestureRecognizer					*footerSwipeGesture;
@property (nonatomic,strong)  UISwipeGestureRecognizer					*segmentNextSwipeGesture;
@property (nonatomic,strong)  UISwipeGestureRecognizer					*segmentPreviousSwipeGesture;

@end




@implementation RouteSegmentViewController



-(void)dealloc{
	
	self.mapView.delegate=nil;
	
}



#pragma mark - Notifications

-(void)listNotificationInterests{
	
	[self initialise];
	
	[notifications addObject:CSMAPSTYLECHANGED];
	[notifications addObject:RETREIVEROUTEPHOTOSRESPONSE];
	
	[super listNotificationInterests];
	
}

-(void)didReceiveNotification:(NSNotification*)notification{
	
	[super didReceiveNotification:notification];
	

	//NSDictionary	*dict=[notification userInfo];
	NSString		*name=notification.name;
	
	if([name isEqualToString:CSMAPSTYLECHANGED]){
		[self didNotificationMapStyleChanged];
	}
	
	if([name isEqualToString:RETREIVEROUTEPHOTOSRESPONSE]){
		[self didRecievePhotoResponse:notification.object];
	}
	
}


#pragma mark - notification responses

- (void) didNotificationMapStyleChanged {
	
	
	NSArray *overlays=[_mapView overlaysInLevel:MKOverlayLevelAboveLabels];
	
	self.activeMapSource=[CycleStreets activeMapSource];
	
	if(overlays.count==0){
		
		if(![_activeMapSource.uniqueTilecacheKey isEqualToString:MAPPING_BASE_APPLE]){
			
			
			MKTileOverlay *newoverlay = [[MKTileOverlay alloc] initWithURLTemplate:_activeMapSource.tileTemplate];
			newoverlay.canReplaceMapContent = YES;
			newoverlay.maximumZ=_activeMapSource.maxZoom;
			[_mapView insertOverlay:newoverlay atIndex:0 level:MKOverlayLevelAboveLabels];
			
		}
		
	}else{
		
		for(id <MKOverlay> overlay in overlays){
			if([overlay isKindOfClass:[MKTileOverlay class]] ){
				
				
				if([_activeMapSource.uniqueTilecacheKey isEqualToString:MAPPING_BASE_APPLE]){
					
					[_mapView removeOverlay:overlay];
					
					break;
					
				}else{
					
					MKTileOverlay *newoverlay = [[MKTileOverlay alloc] initWithURLTemplate:_activeMapSource.tileTemplate];
					newoverlay.canReplaceMapContent = YES;
					newoverlay.maximumZ=_activeMapSource.maxZoom;
					[_mapView removeOverlay:overlay];
					[_mapView insertOverlay:newoverlay atIndex:0 level:MKOverlayLevelAboveLabels]; // always at bottom
					
					break;
					
				}
				
				
				break;
			}
		}
		
	}
	
	
	if([_activeMapSource.uniqueTilecacheKey isEqualToString:MAPPING_BASE_APPLE]){
		
		_attributionLabel.visible=NO;
		//mkAttributionLabel.visible=YES;
		
	}else{
		_attributionLabel.visible=YES;
		//mkAttributionLabel.visible=NO;
		_attributionLabel.text = _activeMapSource.shortAttribution;
		
	}
}

#pragma mark - UI View

- (void)viewDidLoad {
	
    [super viewDidLoad];
	
		
	_mapView.userTrackingMode=MKUserTrackingModeNone;
	[self didNotificationMapStyleChanged];
	
	
	//photo & info default to ON state
	self.infoButton.style = UIBarButtonItemStyleDone;
	self.photoIconButton.style = UIBarButtonItemStyleDone;
	
	_photoIconsVisisble=NO;
	self.photoMarkers=[NSMutableArray array];
	
	_footerIsHidden=NO;
	self.footerView=[[CSSegmentFooterView alloc]initWithFrame:CGRectMake(0, SCREENHEIGHT, SCREENWIDTH, 10)];
	[self.view addSubview:_footerView];
	
	
	self.attributionLabel.backgroundColor=UIColorFromRGBAndAlpha(0x008000,0.2);
	self.attributionLabel.text = _activeMapSource.shortAttribution;;
	

	
	_toolBar.clipsToBounds=YES;
	[self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc]initWithCustomView:_toolBar]];
	
	self.footerSwipeGesture=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(didcloseFooterGesture:)];
	_footerSwipeGesture.direction=UISwipeGestureRecognizerDirectionDown;
	[_footerView addGestureRecognizer:_footerSwipeGesture];
	
	
	self.segmentNextSwipeGesture=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(didsegmentNextFooterGesture:)];
	_segmentNextSwipeGesture.direction=UISwipeGestureRecognizerDirectionLeft;
	[_footerView addGestureRecognizer:_segmentNextSwipeGesture];
	
	self.segmentPreviousSwipeGesture=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(didsegmentPreviousFooterGesture:)];
	_segmentPreviousSwipeGesture.delaysTouchesBegan=YES;
	_segmentPreviousSwipeGesture.direction=UISwipeGestureRecognizerDirectionRight;
	[_footerView addGestureRecognizer:_segmentPreviousSwipeGesture];
	
}


//------------------------------------------------------------------------------------
#pragma mark - Footer gesture recognisers
//------------------------------------------------------------------------------------

- (void)didcloseFooterGesture:(UISwipeGestureRecognizer *)recognizer{
	
	[self didToggleInfo];
	
}

- (void)didsegmentNextFooterGesture:(UISwipeGestureRecognizer *)recognizer{
	
	[self didNext];
}

- (void)didsegmentPreviousFooterGesture:(UISwipeGestureRecognizer *)recognizer{
	
	[self didPrev];
}



//------------------------------------------------------------------------------------
#pragma mark - UIView
//------------------------------------------------------------------------------------

-(void)viewWillAppear:(BOOL)animated{
	
	if(_mapView.delegate==nil)
		[_mapView setDelegate:self];
	
	if([self isMovingToParentViewController]){
		[self updateRouteOverlay];
		[self setSegmentIndex:_index];
	}
		
	
	[super viewWillAppear:animated];
}


-(void)viewWillDisappear:(BOOL)animated{
	
	if([self isMovingFromParentViewController])
		_mapView.delegate=nil;
	
	[super viewWillDisappear:animated];
}



#pragma mark - UI Update


- (void)updateNextPreviousUI {
	
	[_prevPointButton setEnabled:YES];
	if (_index == 0) {
		[_prevPointButton setEnabled:NO];
	}
	
	[_nextPointButton setEnabled:YES];
	if (_index == [self.route numSegments]-1) {
		[_nextPointButton setEnabled:NO];
	}
	
	NSString *message = [NSString stringWithFormat:@"Stage: %d/%ld", _index+1, (long)[self.route numSegments]];
	_footerView.segmentIndexLabel.text=message;
	 
	
}




#pragma mark - Photo Markers
//
/***********************************************
 * @description			Photo Marker Methods
 ***********************************************/
//

- (void) requestPhotos {
	
	BetterLog(@"");
	
	CGRect bounds = _mapView.bounds;
	CLLocationCoordinate2D nw = [_mapView convertPoint:bounds.origin toCoordinateFromView:_mapView];
	CLLocationCoordinate2D se = [_mapView convertPoint:CGPointMake(bounds.origin.x + bounds.size.width, bounds.origin.y + bounds.size.height) toCoordinateFromView:_mapView ];
	CLLocationCoordinate2D ne;
	CLLocationCoordinate2D sw;
	ne.latitude = nw.latitude;
	ne.longitude = se.longitude;
	sw.latitude = se.latitude;
	sw.longitude = nw.longitude;
	

	[self fetchPhotoMarkersNorthEast:ne SouthWest:sw];
	
}



- (void)fetchPhotoMarkersNorthEast:(CLLocationCoordinate2D)ne SouthWest:(CLLocationCoordinate2D)sw {
	
	if (_photomapQuerying) return;
	if(!_photoIconsVisisble) return;
	
	_photomapQuerying = YES;
	
	[[PhotoManager sharedInstance] retrievePhotosForRouteBounds:ne withEdge:sw];
	
}


-(void)didRecievePhotoResponse:(NSDictionary*)dict{
	
	BetterLog(@"");
	
	_photomapQuerying = NO;
	
	NSString *status=[dict objectForKey:@"status"];
	
	if([status isEqualToString:SUCCESS]){
		
		[self displayPhotosOnMap];
		
	}
	
}



-(void)displayPhotosOnMap{
	
	BetterLog(@"");
	
	PhotoMapListVO *photoList=[PhotoManager sharedInstance].routePhotoList;
	
	[_mapView removeAnnotations:_photoMarkers];
	
	for (PhotoMapVO *photo in [photoList photos]) {
		
		CSPhotomapAnnotation *annotation=[[CSPhotomapAnnotation alloc]init];
		annotation.coordinate=photo.locationCoords;
		annotation.dataProvider=photo;
		annotation.isUserPhoto=[[PhotoManager sharedInstance] isUserPhoto:photo];
		
		[_mapView addAnnotation:annotation];
		[_photoMarkers addObject:annotation];
		
	}
	
	
}




#pragma mark - MKMap delegate


- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated{
	
    if([mapView getZoomLevel]>MAX_ZOOM_SEGMENT) {
        [mapView setCenterCoordinate:[mapView centerCoordinate] zoomLevel:MAX_ZOOM_SEGMENT animated:YES];
    }
	
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
	
	
	double zoom=[_mapView getZoomLevel];
	BetterLog(@"zoom=%g",zoom);
	
	if(_photoIconsVisisble){
		CLLocationCoordinate2D centreCoordinate=_mapView.centerCoordinate;
		if([UserLocationManager isSignificantLocationChange:_currentLocation.coordinate newLocation:centreCoordinate accuracy:5])
		[self requestPhotos];
		
	}
}


- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id <MKOverlay>)overlay{
    
    if ([overlay isKindOfClass:[MKTileOverlay class]]) {
        return [[MKTileOverlayRenderer alloc] initWithTileOverlay:overlay];
        
    }
	
	// individual segment
	if(overlay==_segmentOverlay){
		self.segmentOverlayRenderer = [[CSRoutePolyLineRenderer alloc] initWithOverlay:overlay];
		_segmentOverlayRenderer.primaryColor=UIColorFromRGBAndAlpha(0x880088, 0.6);
		return _segmentOverlayRenderer;
	}
	
	// overall route inc walking sections
	if(overlay==_routeOverlay){
		self.routeOverlayRenderer = [[CSRoutePolyLineRenderer alloc] initWithOverlay:overlay];
		_routeOverlayRenderer.primaryColor=UIColorFromRGBAndAlpha(0x880088, 0.4);
		_routeOverlayRenderer.secondaryColor=UIColorFromRGBAndAlpha(0x880088, 0.4);
		return _routeOverlayRenderer;
	}
	
	
    
    return nil;
}



#pragma mark - MKMap Annotations

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
	
	if ([annotation isKindOfClass:[MKUserLocation class]])
		return nil;
	
	
	// if s/f annotation
	if ([annotation isKindOfClass:[CSRouteSegmentAnnotation class]]){
		
		static NSString *reuseId = @"CSRouteSegmentAnnotation";
		CSRouteSegmentAnnotationView *annotationView = (CSRouteSegmentAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:reuseId];
		
		if (annotationView == nil){
			annotationView = [[CSRouteSegmentAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseId];
			annotationView.enabled=NO;
			annotationView.annotation = annotation;
		} else {
			annotationView.annotation = annotation;
		}
		
		return annotationView;
		
		
	}else if ([annotation isKindOfClass:[CSPhotomapAnnotation class]]){
		
		static NSString *reuseId = @"CSPhotomapAnnotation";
		CSPhotomapAnnotationView *annotationView = (CSPhotomapAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:reuseId];
		
		if (annotationView == nil){
			annotationView = [[CSPhotomapAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseId];
			annotationView.enabled=YES;
			annotationView.annotation = annotation;
		} else {
			annotationView.annotation = annotation;
		}
		
		return annotationView;
		
	}
	
	return nil;
	
}


-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view{
	
	BetterLog(@"Fired");
	
	if ([view isKindOfClass:[CSPhotomapAnnotationView class]]){
	
		CSPhotomapAnnotation *annotation=(CSPhotomapAnnotation*)view.annotation;
		
		PhotoMapImageLocationViewController *lv = [[PhotoMapImageLocationViewController alloc] initWithNibName:@"PhotoMapImageLocationView" bundle:nil];
		PhotoMapVO *photoEntry = (PhotoMapVO *)annotation.dataProvider;
		lv.dataProvider=photoEntry;
		[self presentModalViewController:lv animated:YES];
		
	}
	
}






#pragma mark - Route Overlay

- (void) updateRouteOverlay {
	
	
	BetterLog(@"");
	CLLocationCoordinate2D ne=[_route insetNorthEast];
	CLLocationCoordinate2D sw=[_route insetSouthWest];
	
	MKMapRect mapRect=[self mapRectThatFitsBoundsSW:sw NE:ne];
	
	if(_routeOverlay==nil){
		self.routeOverlay = [[CSRoutePolyLineOverlay alloc] initWithRoute:_route];
		[self.mapView addOverlay:_routeOverlay level:MKOverlayLevelAboveLabels];
	}else{
		[_routeOverlay updateForDataProvider:_route];
		[_routeOverlayRenderer setNeedsDisplayInMapRect:mapRect];
	}
	
	
}


//
/***********************************************
 * @description			Update Map view by segment
 ***********************************************/
//

- (void)setSegmentIndex:(NSInteger)newIndex {
	
	
	self.index = newIndex;
	self.currentSegment = [self.route segmentAtIndex:_index];
	SegmentVO *nextSegment = nil;
	if (_index + 1 < [self.route numSegments]) {
		nextSegment = [self.route segmentAtIndex:_index+1];
	}
	
	// fill the labels from the segment we are showing
	_footerView.dataProvider=_currentSegment;
	[_footerView updateLayout];
	[self updateFooterPositions];
	
	
	// centre the view around the segment
	CLLocationCoordinate2D start = [_currentSegment segmentStart];
	CLLocationCoordinate2D end = [_currentSegment segmentEnd];
	CLLocationCoordinate2D ne;
	CLLocationCoordinate2D sw;
	
	// Note: if end/start coordinates have same value, MKMapRect will calculate a wacky zoom
	// so we tweak the values if we spot this.
	if(start.longitude==end.longitude)
		end.longitude+=0.000001;
	if(start.latitude==end.latitude)
		end.latitude+=0.000001;
	
	
	if (start.latitude <= end.latitude) {
		sw.latitude = start.latitude;
		ne.latitude = end.latitude;
	} else {
		sw.latitude = end.latitude;
		ne.latitude = start.latitude;
	}
	if (start.longitude <= end.longitude) {
		sw.longitude = start.longitude;
		ne.longitude = end.longitude;
	} else {
		sw.longitude = end.longitude;
		ne.longitude = start.longitude;
	}
	
	MKMapRect mapRect=[self mapRectThatFitsBoundsSW:sw NE:ne];
	[_mapView setVisibleMapRect:mapRect edgePadding:UIEdgeInsetsMake(100,20,100,20) animated:YES];
	
	// check what the zoom will be
	//MKCoordinateRegion region = MKCoordinateRegionForMapRect(_mapView.visibleMapRect);
	//double newzoom= log2(360 * ((_mapView.size.width/256) / region.span.longitudeDelta));
    

	[self updateupdateRouteAnnotationsToStart:start end:end forstartAngle:[_currentSegment startBearing] endAngle:[nextSegment startBearing]];
	
	if(_segmentOverlay==nil){
		self.segmentOverlay = [[CSRoutePolyLineOverlay alloc] initWithSegment:nil];
		[_segmentOverlay updateForSegment:_currentSegment];
		[self.mapView addOverlay:_segmentOverlay level:MKOverlayLevelAboveLabels];
	}else{
		[_segmentOverlay updateForSegment:_currentSegment];
		[_segmentOverlayRenderer setNeedsDisplay];
	}
	
	[self updateNextPreviousUI];
	
}

-(void)updateupdateRouteAnnotationsToStart:(CLLocationCoordinate2D)start end:(CLLocationCoordinate2D)end forstartAngle:(NSInteger)startAngle endAngle:(NSInteger)endAngle{
	
	if(_startAnnotation==nil){
		
		self.startAnnotation=[[CSRouteSegmentAnnotation alloc]initWithCoordinate:start];
		_startAnnotation.wayPointType=WayPointTypeStart;
		[_mapView addAnnotation:_startAnnotation];
	}
	
	if(_endAnnotation==nil){
		
		self.endAnnotation=[[CSRouteSegmentAnnotation alloc]initWithCoordinate:end];
		_endAnnotation.wayPointType=WayPointTypeFinish;
		[_mapView addAnnotation:_endAnnotation];
		
	}
	
	_startAnnotation.coordinate=start;
	_endAnnotation.coordinate=end;
	
	CSRouteSegmentAnnotationView *startView=[self fetchAnnotationViewForAnnotation:_startAnnotation];
	_startAnnotation.annotationAngle=startAngle;
	[startView updateAnnotationAngle];
	
	CSRouteSegmentAnnotationView *endView=[self fetchAnnotationViewForAnnotation:_endAnnotation];
	_endAnnotation.annotationAngle=endAngle;
	[endView updateAnnotationAngle];
	
	
}


-(void)updateupdateRouteAnnotationsToStart:(CLLocationCoordinate2D)start end:(CLLocationCoordinate2D)end{
	
	if(_startAnnotation==nil){
		
		self.startAnnotation=[[CSRouteSegmentAnnotation alloc]initWithCoordinate:start];
		_startAnnotation.wayPointType=WayPointTypeStart;
		[_mapView addAnnotation:_startAnnotation];
	}
	
	if(_endAnnotation==nil){
		
		self.endAnnotation=[[CSRouteSegmentAnnotation alloc]initWithCoordinate:end];
		_endAnnotation.wayPointType=WayPointTypeFinish;
		[_mapView addAnnotation:_endAnnotation];
		
	}
	
	_startAnnotation.coordinate=start;
	_endAnnotation.coordinate=end;
	
	
}



-(CSRouteSegmentAnnotationView*)fetchAnnotationViewForAnnotation:(CSRouteSegmentAnnotation*)aAnnotation{
	
	CSRouteSegmentAnnotationView* anView = (CSRouteSegmentAnnotationView*)[_mapView viewForAnnotation: aAnnotation];
	return anView;
	
}


//
/***********************************************
 * @description			update info footer
 ***********************************************/
//

-(void)updateFooterPositions{
	
	if(_footerIsHidden==NO){
		CGRect	fframe=_footerView.frame;
		CGRect	aframe=_attributionLabel.frame;
		
		fframe.origin.y=SCREENHEIGHTWITHNAVIGATION-fframe.size.height;
		aframe.origin.y=fframe.origin.y-10-aframe.size.height;
		
		_footerView.frame=fframe;
		_attributionLabel.frame=aframe;
		
	}
}




#pragma mark - UserLocation notification methods


-(void)locationDidComplete:(MKUserLocation *)userLocation{
	
	if (_isLocating==NO){
		_locationButton.enabled=YES;
		return;
	}
	
	
	BetterLog(@"");
	
	CLLocation *location=userLocation.location;
	
	CLLocationCoordinate2D centreCoordinate=_mapView.centerCoordinate;
	if([UserLocationManager isSignificantLocationChange:centreCoordinate newLocation:location.coordinate accuracy:2]){
		
		[_mapView showAnnotations:@[userLocation,_startAnnotation,_endAnnotation] animated:YES];
		self.currentLocation=location;
		
		_isLocating=NO;
		
	}
	
	_locationButton.enabled=YES;
	
	if(!_footerIsHidden)
		[self didToggleInfo];
	
	
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



- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
	
	[self locationDidComplete:userLocation];
	
}

- (void)mapViewDidStopLocatingUser:(MKMapView *)mapView{
	
}



//------------------------------------------------------------------------------------
#pragma mark - Core Location
//------------------------------------------------------------------------------------
//
/***********************************************
 * @description			Location Manager methods
 ***********************************************/
//

-(IBAction)startLocating{
	
	_isLocating=!_isLocating;
	
	_locationButton.enabled=NO;
	
	_mapView.showsUserLocation=NO;
	_mapView.showsUserLocation=YES;
	
}



#pragma mark - User Events

//
/***********************************************
 * @description			UI button events
 ***********************************************/
//


- (IBAction) didPrev {
	if (_index > 0) {
		[self setSegmentIndex:_index-1];
	}
}

- (IBAction) didNext {
	if (_index < [self.route numSegments]-1) {
		[self setSegmentIndex:_index+1];
	}
}

- (IBAction) didToggleInfo {
	
	if (_footerIsHidden==NO) {
		
		CGRect __block fframe=_footerView.frame;
		CGRect __block aframe=_attributionLabel.frame;
		
		
		[UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
			
			fframe.origin.y=SCREENHEIGHTWITHNAVIGATION;
			aframe.origin.y=fframe.origin.y-aframe.size.height-10;
			
			_footerView.frame=fframe;
			_footerView.alpha=0;
			_attributionLabel.frame=aframe;
			
		} completion:^(BOOL finished) {
			if(finished==YES)
				_footerIsHidden=YES;
		}];
		
		
		self.infoButton.style = UIBarButtonItemStyleBordered;
		
	} else {
		
		CGRect __block fframe=_footerView.frame;
		CGRect __block aframe=_attributionLabel.frame;
		
		[UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
			
			fframe.origin.y=SCREENHEIGHTWITHNAVIGATION-fframe.size.height;
			aframe.origin.y=fframe.origin.y-10-aframe.size.height;
			
			_footerView.frame=fframe;
			_footerView.alpha=1;
			_attributionLabel.frame=aframe;
			
		} completion:^(BOOL finished) {
			if(finished==YES)
				_footerIsHidden=NO;
		}];
		
		
		self.infoButton.style = UIBarButtonItemStyleDone;
	}
}


-(IBAction)photoIconButtonSelected{
	
	_photoIconsVisisble=!_photoIconsVisisble;
	
	//TODO: we could optimise this for non changed locations so we dont have to call the server again
	if(_photoIconsVisisble==NO){
		
		[_mapView removeAnnotations:_photoMarkers];
		
	}else{
		
		[self requestPhotos];
	}
	
}






#pragma mark - Generic

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
	
}



@end
