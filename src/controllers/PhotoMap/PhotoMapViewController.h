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

//  PhotoMap.h
//  CycleStreets
//
//  Created by Alan Paxton on 06/06/2010.
//

#import <UIKit/UIKit.h>
#import "MapLocationSearchViewController.h"
#import "RMMapViewDelegate.h"
#import "BlueCircleView.h"
#import "SuperViewController.h"
#import "PhotoWizardViewController.h"
#import "SVPulsingAnnotationView.h"

@class RMMapContents;
@class CycleStreets;
@class Location;
@class PhotoMapImageLocationViewController;
@class InitialLocation;


@interface PhotoMapViewController : SuperViewController
<RMMapViewDelegate, LocationReceiver, LocationProvider,GPSLocationProvider> {
	
	
	IBOutlet RMMapView						*mapView;			//map of current area
	IBOutlet UILabel                        *attributionLabel;	// map type label
	RMMapContents							*mapContents;
	
	
	IBOutlet UIBarButtonItem				*gpslocateButton;
	IBOutlet UIBarButtonItem				*photoWizardButton;
	
	
	
	CLLocation								*lastLocation;		// last location
	CLLocation								*currentLocation;
	
	
	PhotoMapImageLocationViewController		*locationView;			//the popup with the contents of a particular location (photomap etc.)
	MapLocationSearchViewController			*mapLocationSearchView;	//the search popup
	
	PhotoWizardViewController				*photoWizardView;
	
	
	InitialLocation							*initialLocation;
	IBOutlet UIView							*introView;
	IBOutlet UIButton						*introButton;
	
	NSMutableArray							*photoMarkers;
	
	BOOL									photomapQuerying;
	BOOL									showingPhotos;
	BOOL									locationManagerIsLocating;
	BOOL									locationWasFound;
	
	BOOL									firstRun;
}

@property (nonatomic, strong) IBOutlet RMMapView		* mapView;
@property (nonatomic, strong) IBOutlet UILabel		* attributionLabel;
@property (nonatomic, strong) RMMapContents		* mapContents;
@property (nonatomic, strong) IBOutlet UIBarButtonItem		* gpslocateButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem		* photoWizardButton;
@property (nonatomic, strong) CLLocationManager		* locationManager;
@property (nonatomic, strong) CLLocation		* lastLocation;
@property (nonatomic, strong) CLLocation		* currentLocation;
@property (nonatomic, strong) PhotoMapImageLocationViewController		* locationView;
@property (nonatomic, strong) MapLocationSearchViewController		* mapLocationSearchView;
@property (nonatomic, strong) PhotoWizardViewController		* photoWizardView;
@property (nonatomic, strong) InitialLocation		* initialLocation;
@property (nonatomic, strong) IBOutlet UIView		* introView;
@property (nonatomic, strong) IBOutlet UIButton		* introButton;
@property (nonatomic, strong) NSMutableArray		* photoMarkers;
@property (nonatomic, assign) BOOL		 photomapQuerying;
@property (nonatomic, assign) BOOL		 showingPhotos;
@property (nonatomic, assign) BOOL		 locationManagerIsLocating;
@property (nonatomic, assign) BOOL		 locationWasFound;
@property (nonatomic, assign) BOOL		 firstRun;



- (IBAction) locationButtonSelected:(id)sender;
-(IBAction)  showPhotoWizard:(id)sender;
- (IBAction) didSearch;

- (IBAction) didIntroButton;

- (void)fetchPhotoMarkersNorthEast:(CLLocationCoordinate2D)ne SouthWest:(CLLocationCoordinate2D)sw;


- (void)startShowingPhotos;


- (void) requestPhotos;
- (void) clearPhotos;

@end
