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

//  Settings.m
//  CycleStreets
//
//  Created by Alan Paxton on 02/03/2010.
//

#import "Settings.h"
#import "CycleStreets.h"
#import "Query.h"
#import "CycleStreetsAppDelegate.h"
#import "Files.h"
#import "Map.h"
#import "UIButton+Blue.h"
#import "Common.h"
#import "AppConstants.h"

@implementation Settings
@synthesize plan;
@synthesize speed;
@synthesize mapStyle;
@synthesize imageSize;
@synthesize routeUnit;
@synthesize planControl;
@synthesize speedControl;
@synthesize mapStyleControl;
@synthesize imageSizeControl;
@synthesize routeUnitControl;
@synthesize controlView;

//=========================================================== 
// dealloc
//=========================================================== 
- (void)dealloc
{
    [plan release], plan = nil;
    [speed release], speed = nil;
    [mapStyle release], mapStyle = nil;
    [imageSize release], imageSize = nil;
    [routeUnit release], routeUnit = nil;
    [planControl release], planControl = nil;
    [speedControl release], speedControl = nil;
    [mapStyleControl release], mapStyleControl = nil;
    [imageSizeControl release], imageSizeControl = nil;
    [routeUnitControl release], routeUnitControl = nil;
    [controlView release], controlView = nil;
	
    [super dealloc];
}




- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        
		//load from saved settings
		CycleStreets *cycleStreets = [CycleStreets sharedInstance];
		NSDictionary *dict = [cycleStreets.files settings];
		self.speed = [dict valueForKey:@"speed"];
		self.plan = [dict valueForKey:@"plan"];
		self.mapStyle = [dict valueForKey:@"mapStyle"];
		self.imageSize = [dict valueForKey:@"imageSize"];
		self.routeUnit = [dict valueForKey:@"routeUnit"];
		
		//default values
		if (self.speed == nil) {
			self.speed = @"12";
		}
		if (self.plan == nil) {
			self.plan = @"balanced";
		}
		
		if (self.mapStyle == nil) {
			self.mapStyle = @"OpenStreetMap";
		}
		
		if (self.imageSize == nil) {
			self.imageSize = @"640px";
		}
		
		if (self.routeUnit == nil) {
			self.routeUnit = @"miles";
		}
		

		[self save];
    }
    return self;
}

- (void) select:(UISegmentedControl *)control byString:(NSString *)selectTitle {
	for (NSInteger i = 0; i < [control numberOfSegments]; i++) {
		NSString *title = [[[control titleForSegmentAtIndex:i] lowercaseString] copy];
		if (NSOrderedSame == [title compare: selectTitle]) {
			control.selectedSegmentIndex = i;
		}
		[title release];
	}	
}


- (void)viewDidLoad {
   
	// NE: fix this old logic
	// Need to copy these out, because setting the selection causes changed() to get called,
	// which causes self.speed and self.plan to get written. So self.plan got the old value out of the control, which it then set. Yuk!
	NSString *newSpeed = [speed copy];
	NSString *newPlan = [plan copy];
	NSString *newImageSize = [imageSize copy];
	NSString *newMapStyle = [mapStyle copy];
	NSString *newRouteUnit = [routeUnit copy];
	
	[self select:speedControl byString:newSpeed];
	[self select:planControl byString:newPlan];
	[self select:imageSizeControl byString:newImageSize];
	[self select:mapStyleControl byString:newMapStyle];
	[self select:routeUnitControl byString:newRouteUnit];
	
	
	self.navigationController.navigationBar.tintColor=[UIColor grayColor];
	
	[self.view addSubview:controlView];
	[(UIScrollView*) self.view setContentSize:CGSizeMake(SCREENWIDTH, controlView.frame.size.height)];
	
	 [super viewDidLoad];
	
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)nullify {
	self.planControl = nil;
	self.speedControl = nil;
	self.imageSizeControl = nil;
	self.mapStyleControl = nil;
	self.routeUnitControl=nil;
	self.controlView=nil;
}

- (void)viewDidUnload {
	[self nullify];
	[super viewDidUnload];
	DLog(@">>>");
}

- (void) save {
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
						  self.speed, @"speed",
						  self.plan, @"plan",
						  self.mapStyle, @"mapStyle",
						  self.imageSize, @"imageSize",
						  self.routeUnit, @"routeUnit",
						  nil];
	CycleStreets *cycleStreets = [CycleStreets sharedInstance];
	[cycleStreets.files setSettings:dict];	
}

- (IBAction) changed {
	self.plan = [[planControl titleForSegmentAtIndex:planControl.selectedSegmentIndex] lowercaseString];
	self.speed = [[speedControl titleForSegmentAtIndex:speedControl.selectedSegmentIndex] lowercaseString];
	self.imageSize = [[imageSizeControl titleForSegmentAtIndex:imageSizeControl.selectedSegmentIndex] lowercaseString];
	self.mapStyle = [[mapStyleControl titleForSegmentAtIndex:mapStyleControl.selectedSegmentIndex] lowercaseString];
	self.routeUnit = [[routeUnitControl titleForSegmentAtIndex:routeUnitControl.selectedSegmentIndex] lowercaseString];
	
	//save changed settings
	[self save];
}



/*
 For debugging, the standard "test" query.
- (IBAction) findRoute {
	Query *query = [Query example];
	CycleStreets *cycleStreets = [CycleStreets sharedInstance];
	CycleStreetsAppDelegate *appDelegate = cycleStreets.appDelegate;
	[appDelegate runQuery:query];
}
 */


@end
