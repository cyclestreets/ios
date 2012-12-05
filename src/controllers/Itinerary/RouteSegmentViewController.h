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

//  RouteSegmentViewController.h
//  CycleStreets
//
//  Created by Alan Paxton on 12/03/2010.
//

#import <UIKit/UIKit.h>
#import "RouteVO.h"
#import "RMMapView.h"
#import "BlueCircleView.h"
#import "RouteLineView.h"
#import "ExpandedUILabel.h"
#import "GradientView.h"
#import "CSSegmentFooterView.h"

@class PhotoMapImageLocationViewController;
@class QueryPhoto;

@interface RouteSegmentViewController : UIViewController <CLLocationManagerDelegate, RMMapViewDelegate, LocationProvider, PointListProvider> {
	
	CSSegmentFooterView                     *footerView;
	BOOL                                    footerIsHidden;
	BOOL                                    photoIconsVisisble;
	
	IBOutlet RMMapView                      *mapView;
	IBOutlet BlueCircleView                 *blueCircleView;	//overlay GPS location
	CLLocation                              *lastLocation;		//the last one
	IBOutlet RouteLineView                  *lineView;		//overlay route lines on top of map
	IBOutlet UILabel                        *attributionLabel;
	RMMapContents							*mapContents;
	
	NSMutableArray                          *photoMarkers;
	
	//toolbar
	UIBarButtonItem                         *locationButton;
	UIBarButtonItem                         *infoButton;
	UIBarButtonItem                         *photoIconButton;
	UIBarButtonItem                         *prevPointButton;
	UIBarButtonItem                         *nextPointButton;
	
	
	//current route
	RouteVO                                 *route;
	NSInteger                               index;
	NSInteger                               photosIndex;//check that the photos we are loading relate to the current stage
	
	RMMarker                                *markerLocation;	
	CLLocationManager                       *locationManager;
	BOOL                                    doingLocation;
	PhotoMapImageLocationViewController     *locationView;
	QueryPhoto                              *queryPhoto;
}

@property (nonatomic, strong) CSSegmentFooterView		* footerView;
@property (nonatomic) BOOL		 footerIsHidden;
@property (nonatomic) BOOL		 photoIconsVisisble;
@property (nonatomic, strong) IBOutlet RMMapView		* mapView;
@property (nonatomic, strong) IBOutlet BlueCircleView		* blueCircleView;
@property (nonatomic, strong) CLLocation		* lastLocation;
@property (nonatomic, strong) IBOutlet RouteLineView		* lineView;
@property (nonatomic, strong) IBOutlet UILabel		* attributionLabel;
@property (nonatomic, strong) RMMapContents		* mapContents;
@property (nonatomic, strong) NSMutableArray		* photoMarkers;
@property (nonatomic, strong) IBOutlet UIBarButtonItem		* locationButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem		* infoButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem		* photoIconButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem		* prevPointButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem		* nextPointButton;
@property (nonatomic, strong) RouteVO		* route;
@property (nonatomic) NSInteger		 index;
@property (nonatomic) NSInteger		 photosIndex;
@property (nonatomic, strong) RMMarker		* markerLocation;
@property (nonatomic, strong) CLLocationManager		* locationManager;
@property (nonatomic) BOOL		 doingLocation;
@property (nonatomic, strong) PhotoMapImageLocationViewController		* locationView;
@property (nonatomic, strong) QueryPhoto		* queryPhoto;

//toolbar
- (IBAction) didRoute;
- (IBAction) didLocation;
- (IBAction) didPrev;
- (IBAction) didNext;
- (IBAction) didToggleInfo;
-(IBAction)photoIconButtonSelected;



- (void)setSegmentIndex:(NSInteger)newIndex;

-(void)updateFooterPositions;

-(void)updateMapPhotoMarkers;
- (void) clearPhotos;

@end
