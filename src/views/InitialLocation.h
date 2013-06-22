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
#import <CoreLocation/CoreLocation.h>
@class RMMapView;
@class InitialLocationController;


@interface InitialLocation : NSObject  {
	RMMapView *__unsafe_unretained mapView;
	UIViewController *__unsafe_unretained controller;
	UIView *welcomeView;
	
	UIButton		*closeButton;
}

@property (unsafe_unretained, nonatomic, readonly) RMMapView *mapView;
@property (unsafe_unretained, nonatomic, readonly) UIViewController *controller;
@property (nonatomic, strong) UIView *welcomeView;
@property (nonatomic, strong) UIButton		* closeButton;

- (id) initWithMapView:(RMMapView *)mapView withController:(UIViewController *)controller;

- (void)locationDidFail;
- (void)locationDidComplete:(CLLocationCoordinate2D)coordinate;

- (void)startAt:(CLLocationCoordinate2D)coordinate;

-(void)didReceiveNotification:(NSNotification*)notification;

@end
