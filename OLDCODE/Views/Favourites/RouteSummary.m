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
#import "RouteManager.h"

@implementation RouteSummary
@synthesize route;
@synthesize routeButton;
@synthesize name;
@synthesize time;
@synthesize length;
@synthesize plan;
@synthesize speed;
@synthesize icon;
@synthesize routeidLabel;
@synthesize contentView;

/***********************************************************/
// dealloc
/***********************************************************/
- (void)dealloc
{
    [route release], route = nil;
    [routeButton release], routeButton = nil;
    [name release], name = nil;
    [time release], time = nil;
    [length release], length = nil;
    [plan release], plan = nil;
    [speed release], speed = nil;
    [icon release], icon = nil;
    [routeidLabel release], routeidLabel = nil;
    [contentView release], contentView = nil;
	
    [super dealloc];
}



- (id)initWithRoute:(Route *)newRoute {
	if (self = [super init]) {
		self.route = newRoute;
	}
	return self;
}


- (void)viewDidLoad {
	
    [super viewDidLoad];
	[self.routeButton setupBlue];
	[self.route setUIElements:self];
	self.title = [NSString stringWithFormat:@"Route #%@", [route itinerary]];
	
	routeidLabel.text=[NSString stringWithFormat:@"#%@", [route itinerary]];
	
	[self.view addSubview:contentView];
	[(UIScrollView*) self.view setContentSize:CGSizeMake(320, contentView.frame.size.height)];

}



- (void)selectRoute {
	[self.navigationController popViewControllerAnimated:YES];
	
	[[RouteManager sharedInstance] selectRoute:self.route];
	
	[[CycleStreets sharedInstance].appDelegate showTabBarViewControllerByName:@"map"];
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
    [super didReceiveMemoryWarning];
    
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
}



@end
