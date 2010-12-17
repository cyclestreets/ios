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
#import "Namefinder2.h"
#import "RMMapViewDelegate.h"
#import "BlueCircleView.h"
@class CycleStreets;
@class Location;
@class Location2;
@class InitialLocation;

@interface PhotoMap : UIViewController
<RMMapViewDelegate, CLLocationManagerDelegate, LocationReceiver, LocationProvider> {
	
	
	RMMapView *mapView;				//map of current area
	BlueCircleView *blueCircleView;	//overlay GPS location
	
	CLLocationManager *locationManager; //move out of this class into app, or app sub, if/when we generalise.
	Location2 *locationView;			//the popup with the contents of a particular location (photomap etc.)
	CLLocation *lastLocation;		//the last one
	
	UIActivityIndicatorView *loading;
	
	InitialLocation *initialLocation;
	UIBarButtonItem *locationButton;
	UIBarButtonItem *showPhotosButton;
	Namefinder2 *namefinder;			//the search popup
	
	//Welcome
	UITextView *introView;
	UIButton *introButton;
	
	NSMutableArray *photoMarkers;
	
	BOOL photomapQuerying;
	BOOL doingLocation;
	BOOL showingPhotos;
}

@property (nonatomic, retain) IBOutlet UIBarButtonItem *locationButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *showPhotosButton;
@property (nonatomic, retain) IBOutlet RMMapView *mapView;
@property (nonatomic, retain) IBOutlet BlueCircleView *blueCircleView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *loading;
@property (nonatomic, retain) IBOutlet UILabel *attributionLabel;

@property (nonatomic, retain) IBOutlet UIView *introView;
@property (nonatomic, retain) IBOutlet UIButton *introButton;

- (IBAction) didZoomIn;
- (IBAction) didZoomOut;
- (IBAction) didLocation;
- (IBAction) didShowPhotos;
- (IBAction) didSearch;

- (IBAction) didIntroButton;

- (void)fetchPhotoMarkersNorthEast:(CLLocationCoordinate2D)ne SouthWest:(CLLocationCoordinate2D)sw;

- (void)stopDoingLocation;
- (void)startDoingLocation;
- (void)stopShowingPhotos;
- (void)startShowingPhotos;

- (void) requestPhotos;
- (void) clearPhotos;

@end
