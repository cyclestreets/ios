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

//  RouteSummary.m
//  CycleStreets
//
//  Created by Alan Paxton on 05/09/2010.
//

#import "RouteSummary.h"
#import "CycleStreets.h"
#import "CycleStreetsAppDelegate.h"
#import "Stage.h"
#import "Route.h"
#import "UIButton+Blue.h"

@implementation RouteSummary

@synthesize routeButton;

@synthesize name;
@synthesize time;
@synthesize length;
@synthesize plan;
@synthesize speed;	

- (id)initWithRoute:(Route *)newRoute {
	if (self = [super init]) {
		self.route = newRoute;
	}
	return self;
}

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	[self.routeButton setupBlue];
	[self.route setUIElements:self];
	self.title = [NSString stringWithFormat:@"Route #%@", [route itinerary]];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)selectRoute {
	CycleStreets *cycleStreets = (CycleStreets *)[CycleStreets sharedInstance:[CycleStreets class]];
	[self.navigationController popViewControllerAnimated:YES];
	[cycleStreets.appDelegate selectRoute:self.route];
	
	// and flip to the route table with the selected route in it.
	cycleStreets.appDelegate.tabBarController.selectedViewController = (UITableViewController *)cycleStreets.appDelegate.map;
}	

- (IBAction) didRouteButton {
	[self selectRoute];
}

- (void)setRoute:(Route *)newRoute {
	[newRoute retain];
	[route release];
	route = newRoute;
	[self.route setUIElements:self];
	self.title = [NSString stringWithFormat:@"Route #%@", [self.route itinerary]];
}

- (Route *)route {
	return route;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
