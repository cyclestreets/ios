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
#import "UserLocationManager.h"
#import "ButtonUtilities.h"
#import "RouteManager.h"

static double FADE_DELAY = 0;
static double FADE_DURATION = 1.0;
static int CLOSEBUTTONTAG=7777;
static NSString *const LOCATIONSUBSCRIBERID=@"InitialLocation";


@implementation InitialLocation

@synthesize mapView;
@synthesize welcomeView;
@synthesize controller;
@synthesize closeButton;


- (id) initWithMapView:(RMMapView *)newMapView withController:(UIViewController *)newController {
	if (self = [super init]) {
		mapView = newMapView;
		controller = newController;
		
		[[NSNotificationCenter defaultCenter]
		 addObserver:self
		 selector:@selector(didReceiveNotification:)
		 name:GPSLOCATIONCOMPLETE
		 object:nil];
		
		[[NSNotificationCenter defaultCenter]
		 addObserver:self
		 selector:@selector(didReceiveNotification:)
		 name:GPSLOCATIONFAILED
		 object:nil];
		
		
		
		
		
	}
	return self;
}


-(void)didReceiveNotification:(NSNotification*)notification{
	
	
	if([notification.name isEqualToString:GPSLOCATIONCOMPLETE]){
		CLLocation *location=(CLLocation*) notification.object;
		[self locationDidComplete:location.coordinate];
	}
	if([notification.name isEqualToString:GPSLOCATIONFAILED]){
		[self locationDidFail];
	}
	
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
	
	for (id obj in nib) {
		if ([obj isKindOfClass:[UIView class]]) {
			view = obj;
			
			self.closeButton=(UIButton*)[view viewWithTag:CLOSEBUTTONTAG];
			
			[ButtonUtilities styleIBButton:closeButton type:@"green" text:@"Plan a route"];
			[closeButton addTarget:self action:@selector(closeOverlayView:) forControlEvents:UIControlEventTouchUpInside];
			//closeButton.enabled=![CLLocationManager locationServicesEnabled];
			
		}
	}
	return view;
}

- (void) initiateLocation {
	
	CycleStreets *cycleStreets = [CycleStreets sharedInstance];
	NSDictionary *misc = [cycleStreets.files misc];
	NSString *sLat = [misc valueForKey:@"latitude"];
	NSString *sLon = [misc valueForKey:@"longitude"];
	
	CLLocationCoordinate2D initLocation;
	if (sLat != nil && sLon != nil) {
		
		BOOL hasSelectedRoute=[[RouteManager sharedInstance] hasSelectedRoute];
		
		if(hasSelectedRoute==NO){
			
			initLocation.latitude = [sLat doubleValue];
			initLocation.longitude = [sLon doubleValue];
			[self.mapView moveToLatLong:initLocation];
			
		}
		
		self.mapView.hidden = NO;
		
		
	} else {
		
		BOOL hasSelectedRoute=[[RouteManager sharedInstance] hasSelectedRoute];
		
		if([CLLocationManager locationServicesEnabled]==YES){
			
			if(hasSelectedRoute==NO){
				
				[[UserLocationManager sharedInstance] startUpdatingLocationForSubscriber:LOCATIONSUBSCRIBERID];
				
				[self.mapView moveToLatLong:[UserLocationManager defaultCoordinate]];
				
			}
			
		}else {
			[self locationDidFail];
		}
		
		if(hasSelectedRoute==NO){
		
			if (self.welcomeView == nil) {
				self.welcomeView = [self loadWelcomeView];
			}
			[self.controller.view addSubview:self.welcomeView];
			
		}
		
	}
}


-(IBAction)closeOverlayView:(id)sender{
	
	[UIView animateWithDuration:FADE_DURATION
						  delay:FADE_DELAY 
						options:UIViewAnimationCurveLinear 
					 animations:^{ 
						 self.welcomeView.alpha=0.0f;
					 }
					 completion:^(BOOL finished){
						 self.mapView.hidden = NO;
						 [self.welcomeView removeFromSuperview];
					 }];
	
	
}


- (void)locationDidComplete:(CLLocationCoordinate2D)coordinate {
	
	[self startAt:coordinate];
	
	closeButton.enabled=YES;
	
	
}

- (void)startAt:(CLLocationCoordinate2D)coordinate {
	[self.mapView moveToLatLong:coordinate];
	self.mapView.hidden = NO;
	[self.welcomeView setNeedsDisplay];
	[self save:coordinate];	
}




- (void)locationDidFail{
	
	self.mapView.contents.zoom = 12;
	CLLocationCoordinate2D coordinate = [UserLocationManager defaultCoordinate];
	[self locationDidComplete:coordinate];
	
}


@end
