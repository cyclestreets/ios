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

//  PhotoMap.m
//  CycleStreets
//
//


#import "PhotoMapViewController.h"
#import "CycleStreets.h"
#import "AppDelegate.h"
#import "SegmentVO.h"
#import <CoreLocation/CoreLocation.h>
#import "GenericConstants.h"
#import "PhotoMapListVO.h"
#import "PhotoMapVO.h"
#import "PhotoMapImageLocationViewController.h"
#import "CSPointVO.h"
#import "Files.h"
#import "GlobalUtilities.h"
#import "ButtonUtilities.h"
#import "HudManager.h"
#import "PhotoManager.h"
#import "UserLocationManager.h"
#import "UIView+Additions.h"
#import "MKMapView+Additions.h"
#import "CSPhotomapAnnotation.h"
#import "CSPhotomapAnnotationView.h"
#import <MapKit/MapKit.h>
#import "CSMapSource.h"
#import "MKMapView+LegalLabel.h"
#import "CSMapTileService.h"
#import "PhotoWizardViewController.h"
#import "ExpandedUILabel.h"
#import "PhotoMapVideoLocationViewController.h"
#import "CSRetinaTileRenderer.h"

static NSString *const LOCATIONSUBSCRIBERID=@"PhotoMap";


@interface PhotoMapViewController()<MKMapViewDelegate>

// outlets
@property (nonatomic,strong) IBOutlet MKMapView							* mapView;//map of current area
@property (nonatomic,strong) IBOutlet ExpandedUILabel					* attributionLabel;// map type label
@property (nonatomic,strong) IBOutlet UINavigationItem					* navigation;
@property (nonatomic,strong) IBOutlet UIBarButtonItem					* photoWizardButton;



// buttons
@property (nonatomic,strong) UIBarButtonItem							* locationButton;
@property (nonatomic,strong) UIButton									* activeLocationSubButton;

// views
@property (nonatomic,strong) PhotoMapImageLocationViewController		* locationImageView;
@property (nonatomic,strong) PhotoMapVideoLocationViewController		* locationVideoView;
@property (nonatomic,strong) PhotoWizardViewController					* photoWizardView;


// state
@property (nonatomic,strong) CLLocation									* currentLocation;
@property (nonatomic,assign) BOOL										photomapQuerying;
@property (nonatomic,assign) BOOL										shouldAcceptLocationUpdates;
@property (nonatomic,assign) BOOL										mapChangedFromUserInteraction;
@property (nonatomic,assign) BOOL										initialLocationComplete;
@property (nonatomic,strong) CSMapSource								* activeMapSource;


@end



@implementation PhotoMapViewController




//
/***********************************************
 * @description		NOTIFICATIONS
 ***********************************************/
//

-(void)listNotificationInterests{
	
	[self initialise];
    
    [notifications addObject:CSMAPSTYLECHANGED];
	[notifications addObject:RETREIVELOCATIONPHOTOSRESPONSE];
	
	
	[super listNotificationInterests];
	
}

-(void)didReceiveNotification:(NSNotification*)notification{
	
	BetterLog(@"");
	
	[super didReceiveNotification:notification];
	
	NSString		*name=notification.name;
	
    if([name isEqualToString:CSMAPSTYLECHANGED]){
        [self didNotificationMapStyleChanged];
    }
	
	if([name isEqualToString:RETREIVELOCATIONPHOTOSRESPONSE]){
        [self didRecievePhotoResponse:notification.object];
    }
	
	
	
}


- (void) didNotificationMapStyleChanged {
	
	
	NSArray *overlays=[_mapView overlaysInLevel:MKOverlayLevelAboveLabels];
	self.activeMapSource=[CycleStreets activeMapSource];
	
	[CSMapTileService updateMapStyleForMap:_mapView toMapStyle:_activeMapSource withOverlays:overlays];
	
	[CSMapTileService updateMapAttributonLabel:_attributionLabel forMap:_mapView forMapStyle:_activeMapSource inView:self.view];
	
}



-(void)didRecievePhotoResponse:(NSDictionary*)dict{
	
	BetterLog(@"");
	
	NSString *status=[dict objectForKey:@"status"];
	
	if([status isEqualToString:SUCCESS]){
	
		[self displayPhotosOnMap];

		_photomapQuerying = NO;
		
	}else{
		_photomapQuerying=NO;
	}
	
	
}


-(void)displayPhotosOnMap{
	
	BetterLog(@"");
	
	PhotoMapListVO *photoList=[PhotoManager sharedInstance].locationPhotoList;
		
	[_mapView removeAnnotations:[_mapView annotationsWithoutUserLocation]];
	
	for (PhotoMapVO *photo in [photoList photos]) {
		
		CSPhotomapAnnotation *annotation=[[CSPhotomapAnnotation alloc]init];
		annotation.coordinate=photo.locationCoords;
		annotation.dataProvider=photo;
		annotation.isUserPhoto=[[PhotoManager sharedInstance] isUserPhoto:photo];
				
		[_mapView addAnnotation:annotation];
		
	}
	
	
}


#pragma mark - Annotation methods

#pragma mark - MKMap Annotations



- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
	
	if ([annotation isKindOfClass:[MKUserLocation class]])
		return nil;
	
	
	static NSString *reuseId = @"CSPhotomapAnnotation";
	CSPhotomapAnnotationView *annotationView = (CSPhotomapAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:reuseId];
	
	if (annotationView == nil){
		annotationView = [[CSPhotomapAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseId];
		annotationView.enabled=YES;
		annotationView.draggable=NO;
				
	} else {
		annotationView.annotation = annotation;
	}
	
	return annotationView;
}


-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view{
	
	if([view.annotation isKindOfClass:[MKUserLocation class]])
		return;
	
	BetterLog(@"Fired");
	
	CSPhotomapAnnotation *annotation=(CSPhotomapAnnotation*)view.annotation;
	PhotoMapVO *photoEntry = (PhotoMapVO *)annotation.dataProvider;
	
	switch (photoEntry.mediaType) {
		case PhotoMapMediaType_Image:
			{
				PhotoMapImageLocationViewController *lv = [[PhotoMapImageLocationViewController alloc] initWithNibName:[PhotoMapImageLocationViewController nibName] bundle:nil];
				lv.dataProvider=photoEntry;
				[self presentModalViewController:lv animated:YES];
				
			}
		break;
				
		case PhotoMapMediaType_Video:
			{
				PhotoMapVideoLocationViewController *lv = [[PhotoMapVideoLocationViewController alloc] initWithNibName:[PhotoMapVideoLocationViewController nibName] bundle:nil];
				lv.dataProvider=photoEntry;
				[self presentModalViewController:lv animated:YES];
			}
		break;
	}
	
	[_mapView deselectAnnotation:annotation animated:NO];
	
}



//
/***********************************************
 * @description			View Methods
 ***********************************************/
//


- (void)viewDidLoad {
	
    [super viewDidLoad];
		
	[self createPersistentUI];
	
	
}


-(void)createPersistentUI{
	
	displaysConnectionErrors=NO;
	_shouldAcceptLocationUpdates=YES;
	_initialLocationComplete=NO;
	
	
	[_mapView setDelegate:self];
	CLLocation *defaultLocation=[UserLocationManager defaultLocation];
	self.currentLocation=defaultLocation;
	[_mapView setCenterCoordinate:[UserLocationManager defaultCoordinate] zoomLevel:10 animated:NO];
	_mapView.userTrackingMode=MKUserTrackingModeFollow;

	
	_attributionLabel.textAlignment=NSTextAlignmentCenter;
	_attributionLabel.backgroundColor=UIColorFromRGBAndAlpha(0x008000, .1);
	
	[self didNotificationMapStyleChanged];
	
	
	self.activeLocationSubButton=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 20, 20)];
	_activeLocationSubButton.tintColor=[UIColor whiteColor];
	[_activeLocationSubButton addTarget:self action:@selector(locationButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
	[_activeLocationSubButton setImage:[UIImage imageNamed:@"CSBarButton_followuser.png"] forState:UIControlStateNormal];
	[_activeLocationSubButton setImage:[UIImage imageNamed:@"CSBarButton_gpsactive.png"] forState:UIControlStateSelected];
	self.locationButton = [[UIBarButtonItem alloc] initWithCustomView:_activeLocationSubButton];
	_locationButton.width = 40;
	
	[self.navigation setLeftBarButtonItem:_locationButton];
	
	
}


-(void)viewWillAppear:(BOOL)animated{
    
    [self createNonPersistentUI];
    
    [super viewWillAppear:animated]; 
    
}


-(void)createNonPersistentUI{
	
	
	if([PhotoManager sharedInstance].autoLoadLocation!=nil){
		
		_shouldAcceptLocationUpdates=NO;
		_mapView.showsUserLocation=NO;
		
		[_mapView setCenterCoordinate:[PhotoManager sharedInstance].autoLoadLocation.coordinate zoomLevel:15 animated:NO];
		
		[PhotoManager sharedInstance].autoLoadLocation=nil;
		
	}else{
		_mapView.showsUserLocation=YES;
	}

	
	[ViewUtilities alignView:_attributionLabel withView:self.view :BURightAlignMode :BUBottomAlignMode :7];
	
	
}


-(void)viewDidDisappear:(BOOL)animated{
	
	_mapView.showsUserLocation=NO;
	
	[super viewDidDisappear:animated];
}


#pragma mark Photo Markers
//
/***********************************************
 * @description			Photo Marker Methods
 ***********************************************/
//

- (void) requestPhotos {
	
	BetterLog(@"");
	
	if (_photomapQuerying) return;
	_photomapQuerying = YES;
	
	CGRect bounds = _mapView.bounds;
	CLLocationCoordinate2D nw = [_mapView convertPoint:bounds.origin toCoordinateFromView:_mapView];
	CLLocationCoordinate2D se = [_mapView convertPoint:CGPointMake(bounds.origin.x + bounds.size.width, bounds.origin.y + bounds.size.height) toCoordinateFromView:_mapView ];
	CLLocationCoordinate2D ne;
	CLLocationCoordinate2D sw;
	ne.latitude = nw.latitude;
	ne.longitude = se.longitude;
	sw.latitude = se.latitude;
	sw.longitude = nw.longitude;
	
	self.currentLocation=[[CLLocation alloc]initWithLatitude:nw.latitude longitude:nw.longitude];
	
	[self fetchPhotoMarkersNorthEast:ne SouthWest:sw];	
	
}




- (void)fetchPhotoMarkersNorthEast:(CLLocationCoordinate2D)ne SouthWest:(CLLocationCoordinate2D)sw {
	
	[[PhotoManager sharedInstance] retrievePhotosForLocationBounds:ne withEdge:sw];
	
}



#pragma mark - MapView delegate


- (BOOL)mapViewRegionDidChangeFromUserInteraction
{
	UIView *view = self.mapView.subviews.firstObject;
	//  Look through gesture recognizers to determine whether this region change is from user interaction
	for(UIGestureRecognizer *recognizer in view.gestureRecognizers) {
		if(recognizer.state == UIGestureRecognizerStateBegan || recognizer.state == UIGestureRecognizerStateEnded) {
			return YES;
		}
	}
	
	return NO;
}


- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
	_mapChangedFromUserInteraction = [self mapViewRegionDidChangeFromUserInteraction];
	
	if (_mapChangedFromUserInteraction) {
		_shouldAcceptLocationUpdates=NO;
	}
}


- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
	
	BetterLog(@"");
	
//	if(self.currentLocation!=nil)
//		return;
	
	if(!_shouldAcceptLocationUpdates)
		return;
	
	CLLocation *location=userLocation.location;
	
	CLLocationCoordinate2D centreCoordinate=_mapView.centerCoordinate;
	if([UserLocationManager isSignificantLocationChange:centreCoordinate newLocation:location.coordinate accuracy:4]){
		
		[_mapView setCenterCoordinate:location.coordinate zoomLevel:15 animated:NO];
		
		self.currentLocation=location;
		
		BetterLog(@"currentLocation=%@",_currentLocation);
		
	}else{
		
		_shouldAcceptLocationUpdates=NO;
	}
	
}

- (void)mapViewDidStopLocatingUser:(MKMapView *)mapView{
	
	
	BetterLog(@"");
	
	self.currentLocation=_mapView.userLocation.location;
	
	
}

- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error{
	
	
}


- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
	
	BetterLog(@"");
	
	CLLocationCoordinate2D centreCoordinate=_mapView.centerCoordinate;
	if([UserLocationManager isSignificantLocationChange:_currentLocation.coordinate newLocation:centreCoordinate accuracy:4]){
			[self requestPhotos];
	}else{
		if(_initialLocationComplete==NO){
			_initialLocationComplete=YES;
		}
	}
	
}


- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id <MKOverlay>)overlay{
    
	if ([overlay isKindOfClass:[MKTileOverlay class]]) {
		return [[CSRetinaTileRenderer alloc] initWithTileOverlay:overlay];
		
	}
	
    return nil;
}






#pragma mark - Location


- (IBAction) locationButtonSelected:(id)sender {
	
	if([[UserLocationManager sharedInstance] doesDeviceAllowLocation]){
	
		_activeLocationSubButton.selected=!_activeLocationSubButton.selected;
		
		_shouldAcceptLocationUpdates=YES;
		
		_mapView.showsUserLocation=YES;
		
		[self.mapView setCenterCoordinate:_mapView.userLocation.location.coordinate animated:YES];
		
		[_activeLocationSubButton performSelector:@selector(setSelected:) withObject:@NO afterDelay:1];
		
	}else{
		
		[[UserLocationManager sharedInstance] displayUserLocationAlert];
		
	}
	
}






#pragma mark PhotoWizard support


-(IBAction)showPhotoWizard:(id)sender{
	
	
	PhotoWizardViewController *photoWizard=[[PhotoWizardViewController alloc]initWithNibName:[PhotoWizardViewController nibName] bundle:nil];
	photoWizard.extendedLayoutIncludesOpaqueBars=NO;
	photoWizard.edgesForExtendedLayout = UIRectEdgeNone;
	photoWizard.isModal=YES;
	
	[self presentViewController:photoWizard animated:YES completion:^{
		
	}];
	
}





#pragma mark search response

- (void) didMoveToLocation:(CLLocationCoordinate2D)location {
	BetterLog(@"didMoveToLocation");
	[_mapView setCenterCoordinate: location];
}



- (void)saveLocation:(CLLocationCoordinate2D)location {
	NSMutableDictionary *misc = [NSMutableDictionary dictionaryWithDictionary:[[CycleStreets sharedInstance].files misc]];
	[misc setValue:[NSString stringWithFormat:@"%f", location.latitude] forKey:@"latitude"];
	[misc setValue:[NSString stringWithFormat:@"%f", location.longitude] forKey:@"longitude"];
	[[CycleStreets sharedInstance].files setMisc:misc];	
}

- (void)fixLocationAndButtons:(CLLocationCoordinate2D)location {
	//[_mapView setCenterCoordinate:location];
	[self saveLocation:location];	
}


#pragma mark generic class cleanup

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}




@end
