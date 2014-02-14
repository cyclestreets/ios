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
#import "RMMapLayer.h"
#import "RMMarker.h"
#import "RMAnnotation.h"
#import "CycleStreets.h"
#import "AppDelegate.h"
#import "Route.h"
#import "SegmentVO.h"
#import <CoreLocation/CoreLocation.h>

#import "PhotoMapListVO.h"
#import "PhotoMapVO.h"
#import "PhotoMapImageLocationViewController.h"
#import "Markers.h"
#import "RMMapView.h"
#import "CSPointVO.h"
#import "RouteLineView.h"
#import "Files.h"
#import "GlobalUtilities.h"
#import "ButtonUtilities.h"
#import "HudManager.h"
#import "PhotoManager.h"
#import "UserLocationManager.h"
#import "UIView+Additions.h"
#import "RMUserLocation.h"

#import "PhotoWizardViewController.h"

static NSString *const LOCATIONSUBSCRIBERID=@"PhotoMap";


@interface PhotoMapViewController()

@property (nonatomic, strong) IBOutlet RMMapView						* mapView;//map of current area
@property (nonatomic, strong) IBOutlet UILabel							* attributionLabel;// map type label

@property (nonatomic, strong) IBOutlet UIBarButtonItem					* gpslocateButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem					* photoWizardButton;

@property (nonatomic, strong) CLLocation								* currentLocation;
@property (nonatomic, strong) PhotoMapImageLocationViewController		* locationView;
@property (nonatomic, strong) PhotoWizardViewController					* photoWizardView;

@property (nonatomic, assign) BOOL										photomapQuerying;


-(void)didRecievePhotoResponse:(NSDictionary*)dict;
-(void)displayPhotosOnMap;
- (void) didNotificationMapStyleChanged;
- (IBAction) locationButtonSelected:(id)sender;
-(IBAction)  showPhotoWizard:(id)sender;
- (void)fetchPhotoMarkersNorthEast:(CLLocationCoordinate2D)ne SouthWest:(CLLocationCoordinate2D)sw;
- (void) requestPhotos;

@end



@implementation PhotoMapViewController




//
/***********************************************
 * @description		NOTIFICATIONS
 ***********************************************/
//

-(void)listNotificationInterests{
	
	[self initialise];
    
    [notifications addObject:MAPSTYLECHANGED];
	[notifications addObject:RETREIVELOCATIONPHOTOSRESPONSE];
	
	
	[super listNotificationInterests];
	
}

-(void)didReceiveNotification:(NSNotification*)notification{
	
	BetterLog(@"");
	
	[super didReceiveNotification:notification];
	
	NSString		*name=notification.name;
	
    if([name isEqualToString:MAPSTYLECHANGED]){
        [self didNotificationMapStyleChanged];
    }
	
	if([name isEqualToString:RETREIVELOCATIONPHOTOSRESPONSE]){
        [self didRecievePhotoResponse:notification.object];
    }
	
	
	
}


- (void) didNotificationMapStyleChanged {
	_mapView.tileSource = [CycleStreets tileSource];
	self.attributionLabel.text = [CycleStreets mapAttribution];
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
		
	[_mapView removeAllAnnotations];
	
	for (PhotoMapVO *photo in [photoList photos]) {
		
		
		RMAnnotation *annotation = [RMAnnotation annotationWithMapView:_mapView coordinate:photo.locationCoords andTitle:nil];
		
		annotation.userInfo=photo;
		
		if([[PhotoManager sharedInstance] isUserPhoto:photo]){
			annotation.annotationIcon = [UIImage imageNamed:@"UIIcon_userphotomap.png"];
			annotation.anchorPoint = CGPointMake(0.5, 1.0);
		}else{
			annotation.annotationIcon = [UIImage imageNamed:@"UIIcon_photomap.png"];
			annotation.anchorPoint = CGPointMake(0.5, 1.0);
		}
		
		
		[_mapView addAnnotation:annotation];
		
	}
	
	
}


#pragma mar - Annotation methods

- (RMMapLayer *)mapView:(RMMapView *)aMapView layerForAnnotation:(RMAnnotation *)annotation
{
  
	RMMapLayer *marker = [[RMMarker alloc] initWithUIImage:annotation.annotationIcon anchorPoint:annotation.anchorPoint];
    
    return marker;
}


- (void)tapOnAnnotation:(RMAnnotation *)annotation onMap:(RMMapView *)map{
	
	PhotoMapImageLocationViewController *lv = [[PhotoMapImageLocationViewController alloc] initWithNibName:@"PhotoMapImageLocationView" bundle:nil];
	PhotoMapVO *photoEntry = (PhotoMapVO *)annotation.userInfo;
	lv.dataProvider=photoEntry;
	[self presentModalViewController:lv animated:YES];
	
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
	
	[RMMapView class];
	[_mapView setDelegate:self];
	[self didNotificationMapStyleChanged];
	_mapView.showsUserLocation=YES;
	_mapView.zoom=15;
	_mapView.userTrackingMode=RMUserTrackingModeNone;
	
}


-(void)viewWillAppear:(BOOL)animated{
    
    [self createNonPersistentUI];
    
    [super viewWillAppear:animated]; 
    
}


-(void)createNonPersistentUI{
    
   
    
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
	CLLocationCoordinate2D nw = [_mapView pixelToCoordinate:bounds.origin];
	CLLocationCoordinate2D se = [_mapView pixelToCoordinate:CGPointMake(bounds.origin.x + bounds.size.width, bounds.origin.y + bounds.size.height)];
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

//
/***********************************************
 * @description			MapView delegate methods
 ***********************************************/
//


-(void)doubleTapOnMap:(RMMapView*)map At:(CGPoint)point{
	
}

- (void) afterMapMove:(RMMapView *)map byUser:(BOOL)wasUserAction {
	[self afterMapChanged:map];
}


- (void) afterMapZoom:(RMMapView *)map byUser:(BOOL)wasUserAction{
	[self afterMapChanged:map];
}

- (void) afterMapChanged: (RMMapView*) map {
	
	CLLocationCoordinate2D centreCoordinate=_mapView.centerCoordinate;
	//if([UserLocationManager isSignificantLocationChange:_currentLocation.coordinate newLocation:centreCoordinate accuracy:5])
	//	[self requestPhotos];
	
}









#pragma mark - Location
//
/***********************************************
 * @description			Location Methods
 ***********************************************/
//

// called when showsUserLocation is set to NO
- (void)mapViewDidStopLocatingUser:(RMMapView *)mapView{
	
	
	BetterLog(@"");
	
	self.currentLocation=_mapView.userLocation.location;
	
	_gpslocateButton.style = UIBarButtonItemStylePlain;
	
	
}

- (void)mapView:(RMMapView *)mapView didUpdateUserLocation:(RMUserLocation *)userLocation{
	
	BetterLog(@"");
	
	CLLocation *location=userLocation.location;
	
//	CLLocationCoordinate2D centreCoordinate=_mapView.centerCoordinate;
//	if([UserLocationManager isSignificantLocationChange:centreCoordinate newLocation:location.coordinate accuracy:5]){
//		
//		self.currentLocation=location;
//		[_mapView setCenterCoordinate:_currentLocation.coordinate animated:YES];
//		
//	}
	
}



- (IBAction) locationButtonSelected:(id)sender {
	
	if(_mapView.userLocationVisible==NO){
		
		if(_mapView.showsUserLocation==YES){
			
			_mapView.showsUserLocation=NO;
			_mapView.showsUserLocation=YES;
			
			_gpslocateButton.style = UIBarButtonItemStyleDone;
		}else{
			_gpslocateButton.style = UIBarButtonItemStylePlain;
		}
	}
	
}

- (void)mapView:(RMMapView *)mapView didFailToLocateUserWithError:(NSError *)error{
	
	_gpslocateButton.style = UIBarButtonItemStylePlain;
	
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
	[_mapView setCenterCoordinate:location];
	[self saveLocation:location];	
}


#pragma mark generic class cleanup

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}




@end
