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

@implementation Settings

@synthesize speed;
@synthesize plan;
@synthesize mapStyle;
@synthesize imageSize;
@synthesize speedControl;
@synthesize planControl;
@synthesize imageSizeControl;
@synthesize mapStyleTable;
@synthesize mapStyles;
@synthesize clearAccountButton;

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
		
		//list of known styles
		self.mapStyles = [Map mapStyles];
		
		//load from saved settings
		CycleStreets *cycleStreets = (CycleStreets *)[CycleStreets sharedInstance:[CycleStreets class]];
		NSDictionary *dict = [cycleStreets.files settings];
		self.speed = [dict valueForKey:@"speed"];
		self.plan = [dict valueForKey:@"plan"];
		self.mapStyle = [dict valueForKey:@"mapStyle"];
		self.imageSize = [dict valueForKey:@"imageSize"];
		
		//default values
		if (self.speed == nil) {
			self.speed = @"12";
		}
		if (self.plan == nil) {
			self.plan = @"balanced";
		}
		
		if (self.mapStyle == nil) {
			self.mapStyle = [self.mapStyles objectAtIndex:0];
		}
		
		if (self.imageSize == nil) {
			self.imageSize = @"320px";
		}
		
		[self.clearAccountButton setupBlue];

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

- (void)selectMap {
	NSInteger index = 0;
	for (int i = 0; i < [mapStyles count]; i++) {
		if ([[mapStyles objectAtIndex:i] isEqualToString:mapStyle]) {
			index = i;
		}
	}
	[self.mapStyleTable selectRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]
									animated:NO
							  scrollPosition:UITableViewScrollPositionTop];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	// Need to copy these out, because setting the selection causes changed() to get called,
	// which causes self.speed and self.plan to get written. So self.plan got the old value out of the control, which it then set. Yuk!
	NSString *newSpeed = [speed copy];
	NSString *newPlan = [plan copy];
	NSString *newImageSize = [imageSize copy];
	
	[self select:speedControl byString:newSpeed];
	[self select:planControl byString:newPlan];
	[self select:imageSizeControl byString:newImageSize];
	[self performSelector:@selector(selectMap) withObject:nil afterDelay:1.0];
	
	self.mapStyleTable.delegate = self;
	self.mapStyleTable.dataSource = self;
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)nullify {
	self.planControl = nil;
	self.speedControl = nil;
	self.imageSizeControl = nil;
	self.mapStyleTable = nil;
	self.clearAccountButton = nil;
}

- (void)viewDidUnload {
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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
						  nil];
	CycleStreets *cycleStreets = (CycleStreets *)[CycleStreets sharedInstance:[CycleStreets class]];
	[cycleStreets.files setSettings:dict];	
}

- (IBAction) changed {
	//bring all visible fields in line with the values in the tabs
	self.plan = [[planControl titleForSegmentAtIndex:planControl.selectedSegmentIndex] lowercaseString];
	self.speed = [[speedControl titleForSegmentAtIndex:speedControl.selectedSegmentIndex] lowercaseString];
	self.imageSize = [[imageSizeControl titleForSegmentAtIndex:imageSizeControl.selectedSegmentIndex] lowercaseString];
	
	//save changed settings
	[self save];
}

- (IBAction) didClearAccount {
	CycleStreets *cycleStreets = (CycleStreets *)[CycleStreets sharedInstance:[CycleStreets class]];
	[cycleStreets.files resetPasswordInKeyChain];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"NotificationClearAccount" object:nil];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	self.mapStyle = [self.mapStyles objectAtIndex:indexPath.row];
	[self save];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"NotificationMapStyleChanged" object:self.mapStyle];	
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	if (section == 0) {
		return [self.mapStyles count];
	} else {
		return 0;
	}
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"MapStyleTableCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
	}
	
	// Configure the cell...
	cell.textLabel.text = [self.mapStyles objectAtIndex:indexPath.row];
    return cell;
}


/*
 For debugging, the standard "test" query.
- (IBAction) findRoute {
	Query *query = [Query example];
	CycleStreets *cycleStreets = (CycleStreets *)[CycleStreets sharedInstance:[CycleStreets class]];
	CycleStreetsAppDelegate *appDelegate = cycleStreets.appDelegate;
	[appDelegate runQuery:query];
}
 */

- (void)dealloc {
	[self nullify];
	
	//these don't get nullified, as they don't come back on viewDidLoad.
	self.plan = nil;
	self.speed = nil;
	self.imageSize = nil;
	self.mapStyle = nil;
	self.mapStyles = nil;

    [super dealloc];
}

@end
