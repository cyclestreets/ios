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

//  Stage.h
//  CycleStreets
//
//  Created by Alan Paxton on 12/03/2010.
//

#import <UIKit/UIKit.h>
#import "Route.h"
#import "RMMapView.h"
#import "BlueCircleView.h"
#import "RouteLineView.h"
#import "ExpandedUILabel.h"
#import "GradientView.h"
#import "CSSegmentFooterView.h"

@class PhotoMapImageLocationViewController;
@class QueryPhoto;

@interface Stage : UIViewController <CLLocationManagerDelegate, RMMapViewDelegate, LocationProvider, PointListProvider> {
	
	CSSegmentFooterView				*footerView;
	BOOL							footerIsHidden;
	
	IBOutlet RMMapView *mapView;
	IBOutlet BlueCircleView *blueCircleView;	//overlay GPS location
	CLLocation *lastLocation;		//the last one
	IBOutlet RouteLineView *lineView;		//overlay route lines on top of map
	IBOutlet UILabel *attributionLabel;
	
	//toolbar
	UIBarButtonItem *locationButton;
	UIBarButtonItem *infoButton;
	UIBarButtonItem *segmentInStage;
	UIBarButtonItem *prev;
	UIBarButtonItem *next;
	
	//current route
	Route *route;
	NSInteger index;
	NSInteger photosIndex;//check that the photos we are loading relate to the current stage
	
	RMMarker *markerLocation;	
	CLLocationManager *locationManager;
	BOOL doingLocation;
	PhotoMapImageLocationViewController *locationView;
	QueryPhoto *queryPhoto;
}
@property (nonatomic, retain)		CSSegmentFooterView		* footerView;
@property (nonatomic)		BOOL		 footerIsHidden;
@property (nonatomic, retain)		IBOutlet RMMapView		* mapView;
@property (nonatomic, retain)		IBOutlet BlueCircleView		* blueCircleView;
@property (nonatomic, retain)		CLLocation		* lastLocation;
@property (nonatomic, retain)		IBOutlet RouteLineView		* lineView;
@property (nonatomic, retain)		IBOutlet UILabel		* attributionLabel;
@property (nonatomic, retain)		IBOutlet UIBarButtonItem		* locationButton;
@property (nonatomic, retain)		IBOutlet UIBarButtonItem		* infoButton;
@property (nonatomic, retain)		IBOutlet UIBarButtonItem		* segmentInStage;
@property (nonatomic, retain)		IBOutlet UIBarButtonItem		* prev;
@property (nonatomic, retain)		IBOutlet UIBarButtonItem		* next;
@property (nonatomic, retain)		Route		* route;
@property (nonatomic)		NSInteger		 index;
@property (nonatomic)		NSInteger		 photosIndex;
@property (nonatomic, retain)		RMMarker		* markerLocation;
@property (nonatomic, retain)		CLLocationManager		* locationManager;
@property (nonatomic)		BOOL		 doingLocation;
@property (nonatomic, retain)		PhotoMapImageLocationViewController		* locationView;
@property (nonatomic, retain)		QueryPhoto		* queryPhoto;


//toolbar
- (IBAction) didRoute;
- (IBAction) didMap;
- (IBAction) didLocation;
- (IBAction) didPrev;
- (IBAction) didNext;
- (IBAction) didToggleInfo;

//standard interface
- (void)setRoute:(Route *)newRoute;

- (void)setSegmentIndex:(NSInteger)newIndex;

-(void)updateFooterPositions;

@end
