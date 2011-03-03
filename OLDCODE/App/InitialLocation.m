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

//  InitialLocation.m
//  CycleStreets
//
//  Created by Alan Paxton on 05/08/2010.
//

#import "InitialLocation.h"
#import "RMMapView.h"
#import "CycleStreets.h"
#import "Files.h"
#import "CSExceptions.h"

static double FADE_DELAY = 5.0;
static double FADE_DURATION = 1.7;

@implementation InitialLocation

@synthesize mapView;
@synthesize locationManager;
@synthesize welcomeView;
@synthesize controller;
@synthesize errorAlert;

- (id) initWithMapView:(RMMapView *)newMapView withController:(UIViewController *)newController {
	if (self = [super init]) {
		mapView = newMapView;
		[mapView retain];
		controller = newController;
		[controller retain];
	}
	return self;
}

- (CLLocationCoordinate2D)defaultCoordinate {
	CLLocationCoordinate2D coordinate;
	coordinate.latitude = 51.40;
	coordinate.longitude = 0.0;
	return coordinate;
}

- (void) save:(CLLocationCoordinate2D)location {
	CycleStreets *cycleStreets = [CycleStreets sharedInstance];
	NSMutableDictionary *misc = [NSMutableDictionary dictionaryWithDictionary:[cycleStreets.files misc]];
	NSString *sLat = [[NSNumber numberWithDouble:location.latitude] stringValue];
	[misc setValue:sLat forKey:@"latitude"];
	NSString *sLon = [[NSNumber numberWithDouble:location.longitude] stringValue];
	[misc setValue:sLon forKey:@"longitude"];
	[cycleStreets.files setMisc:misc];
}

- (UIView *)loadWelcomeView {
	
	static NSString *CellIdentifier = @"InitialLocationView";
	
	UIView *view = nil;
	NSArray *nib = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:nil options:nil];
	if (nib == nil) {
		[CSExceptions exception: [NSString stringWithFormat:@"Could not load nib %@. Does it exist ?", CellIdentifier]];
	}
	for (id obj in nib) {
		if ([obj isKindOfClass:[UIView class]]) {
			view = obj;
		}
	}
	return view;
}

- (void) query {
	CycleStreets *cycleStreets = [CycleStreets sharedInstance];
	NSDictionary *misc = [cycleStreets.files misc];
	NSString *sLat = [misc valueForKey:@"latitude"];
	NSString *sLon = [misc valueForKey:@"longitude"];
	
	CLLocationCoordinate2D initLocation;
	if (sLat != nil && sLon != nil) {
		initLocation.latitude = [sLat doubleValue];
		initLocation.longitude = [sLon doubleValue];
		[self.mapView moveToLatLong:initLocation];
		self.mapView.hidden = NO;
	} else {
		if (self.locationManager == nil) {
			self.locationManager = [[[CLLocationManager alloc] init] autorelease];
			self.locationManager.delegate = self;
		}
		[self.mapView moveToLatLong:[self defaultCoordinate]];
		[self.locationManager startUpdatingLocation];
		if (self.welcomeView == nil) {
			self.welcomeView = [self loadWelcomeView];
		}
		[self.mapView addSubview:self.welcomeView];
	}
}

- (void) showMap {
	self.mapView.hidden = NO;
}

- (void) finish {
	[self.locationManager stopUpdatingLocation];
	[UIView beginAnimations:@"InitialLocationAnimation" context:nil];
	[UIView setAnimationDuration:FADE_DURATION];
	[self.welcomeView setAlpha:0.0];
	[UIView commitAnimations];
	[self.welcomeView performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:FADE_DURATION];
	[self performSelector:@selector(showMap) withObject:nil afterDelay:FADE_DURATION];
}

- (void)startAt:(CLLocationCoordinate2D)coordinate {
	[self.mapView moveToLatLong:coordinate];
	self.mapView.hidden = NO;
	[self.welcomeView setNeedsDisplay];
	[self save:coordinate];	
}

- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation {
	[self startAt:newLocation.coordinate];
	[self performSelector:@selector(finish) withObject:nil afterDelay:FADE_DELAY];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (alertView == self.errorAlert) {
		self.mapView.contents.zoom = 6;
		CLLocationCoordinate2D coordinate = [self defaultCoordinate];
		[self startAt:coordinate];
		[self finish];
	}
}

- (void)locationManager:(CLLocationManager *)manager
	   didFailWithError:(NSError *)error {
	self.errorAlert = [[[UIAlertView alloc] initWithTitle:@"CycleStreets"
												 message:@"CycleStreets is operating without location based features."
												delegate:self
									   cancelButtonTitle:@"OK"
									   otherButtonTitles:nil]
					  autorelease];
	[self.errorAlert show];
}

- (void) dealloc {
	[mapView release];
	mapView = nil;
	[locationManager release];
	locationManager = nil;
	[controller release];
	controller = nil;
	self.welcomeView = nil;
	self.errorAlert = nil;
	[super dealloc];
}

@end
