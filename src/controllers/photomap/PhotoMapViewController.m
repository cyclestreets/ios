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

#import "PhotoWizardViewController.h"

static NSString *const LOCATIONSUBSCRIBERID=@"PhotoMap";


@interface PhotoMapViewController()<MKMapViewDelegate>

@property (nonatomic, strong) IBOutlet MKMapView						* mapView;//map of current area
@property (nonatomic, strong) IBOutlet UILabel							* attributionLabel;// map type label

@property (nonatomic,strong) IBOutlet UINavigationItem					* navigation;


@property (nonatomic, strong) IBOutlet UIBarButtonItem					* gpslocateButton;
@property (nonatomic,strong)  IBOutlet UIBarButtonItem					* locationButton;
@property (nonatomic,strong) UIButton									* activeLocationSubButton;


@property (nonatomic, strong) IBOutlet UIBarButtonItem					* photoWizardButton;

@property (nonatomic, strong) CLLocation								* currentLocation;
@property (nonatomic, strong) PhotoMapImageLocationViewController		* locationView;
@property (nonatomic, strong) PhotoWizardViewController					* photoWizardView;

@property (nonatomic, assign) BOOL										photomapQuerying;

@property (nonatomic,strong)  CSMapSource								* activeMapSource;



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
	
	//	UILabel *mkAttributionLabel = [_mapView.subviews objectAtIndex:1];
	
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
	
	PhotoMapImageLocationViewController *lv = [[PhotoMapImageLocationViewController alloc] initWithNibName:@"PhotoMapImageLocationView" bundle:nil];
	PhotoMapVO *photoEntry = (PhotoMapVO *)annotation.dataProvider;
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
	
	
	[_mapView setDelegate:self];
	_mapView.userTrackingMode=MKUserTrackingModeFollow;
	_mapView.showsUserLocation=YES;
	
	[self didNotificationMapStyleChanged];
	
	
	self.activeLocationSubButton=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 20, 20)];
	_activeLocationSubButton.tintColor=[UIColor whiteColor];
	[_activeLocationSubButton addTarget:self action:@selector(locationButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
	[_activeLocationSubButton setImage:[UIImage imageNamed:@"CSBarButton_location.png"] forState:UIControlStateNormal];
	[_activeLocationSubButton setImage:[UIImage imageNamed:@"CSBarButton_gpsactive.png"] forState:UIControlStateSelected];
	self.locationButton = [[UIBarButtonItem alloc] initWithCustomView:_activeLocationSubButton];
	_locationButton.width = 40;
	
	[self.navigation setLeftBarButtonItem:_locationButton];
	
	
	_attributionLabel.text = [CycleStreets mapAttribution];
	
}


-(void)viewWillAppear:(BOOL)animated{
    
    [self createNonPersistentUI];
    
    [super viewWillAppear:animated]; 
    
}


-(void)createNonPersistentUI{
    
	[self requestPhotos];
	
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


- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
	
//	if(self.currentLocation!=nil)
//		return;
	
	CLLocation *location=userLocation.location;
	
	CLLocationCoordinate2D centreCoordinate=_mapView.centerCoordinate;
	if([UserLocationManager isSignificantLocationChange:centreCoordinate newLocation:location.coordinate accuracy:2]){
		
		self.currentLocation=location;
		[_mapView setCenterCoordinate:location.coordinate zoomLevel:15 animated:YES];
		
	}
	
}

- (void)mapViewDidStopLocatingUser:(MKMapView *)mapView{
	
	
	BetterLog(@"");
	
	self.currentLocation=_mapView.userLocation.location;
	
	_gpslocateButton.style = UIBarButtonItemStylePlain;
	
	
}

- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error{
	
	_gpslocateButton.style = UIBarButtonItemStylePlain;
	
}


- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
	
	CLLocationCoordinate2D centreCoordinate=_mapView.centerCoordinate;
	if([UserLocationManager isSignificantLocationChange:_currentLocation.coordinate newLocation:centreCoordinate accuracy:5])
		[self requestPhotos];
	
	
	
}


- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id <MKOverlay>)overlay{
    
    if ([overlay isKindOfClass:[MKTileOverlay class]]) {
        return [[MKTileOverlayRenderer alloc] initWithTileOverlay:overlay];
        
    }
    
    return nil;
}






#pragma mark - Location


- (IBAction) locationButtonSelected:(id)sender {
	
	_activeLocationSubButton.selected=!_activeLocationSubButton.selected;
	
	[self.mapView setCenterCoordinate:_mapView.userLocation.location.coordinate animated:YES];
	
	[_activeLocationSubButton performSelector:@selector(setSelected:) withObject:@NO afterDelay:1];
	
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
