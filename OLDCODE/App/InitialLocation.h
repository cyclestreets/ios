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

//  InitialLocation.h
//  CycleStreets
//
//  Created by Alan Paxton on 05/08/2010.
//

#import <Foundation/Foundation.h>
@class RMMapView;
#import <CoreLocation/CoreLocation.h>
@class InitialLocationController;

@interface InitialLocation : NSObject <CLLocationManagerDelegate, UIAlertViewDelegate> {
	RMMapView *mapView;
	UIViewController *controller;
	CLLocationManager *locationManager;
	UIView *welcomeView;
	UIAlertView *errorAlert;
}

@property (nonatomic, readonly) RMMapView *mapView;
@property (nonatomic, readonly) UIViewController *controller;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) UIView *welcomeView;
@property (nonatomic, retain) UIAlertView *errorAlert;

- (id) initWithMapView:(RMMapView *)mapView withController:(UIViewController *)controller;

- (void) finish;

@end
