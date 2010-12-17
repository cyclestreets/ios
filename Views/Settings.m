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
@synthesize plan;
@synthesize speed;
@synthesize mapStyle;
@synthesize imageSize;
@synthesize planControl;
@synthesize speedControl;
@synthesize mapStyleControl;
@synthesize imageSizeControl;
@synthesize clearAccountButton;
@synthesize controlView;
@synthesize accountNameLabel;


//=========================================================== 
// dealloc
//=========================================================== 
- (void)dealloc
{
    [plan release], plan = nil;
    [speed release], speed = nil;
    [mapStyle release], mapStyle = nil;
    [imageSize release], imageSize = nil;
    [planControl release], planControl = nil;
    [speedControl release], speedControl = nil;
    [mapStyleControl release], mapStyleControl = nil;
    [imageSizeControl release], imageSizeControl = nil;
    [clearAccountButton release], clearAccountButton = nil;
    [controlView release], controlView = nil;
    [accountNameLabel release], accountNameLabel = nil;
	
    [super dealloc];
}






 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
		
		//load from saved settings
		CycleStreets *cycleStreets = [CycleStreets sharedInstance];
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
			self.mapStyle = @"OpenStreetMap";
		}
		
		if (self.imageSize == nil) {
			self.imageSize = @"320px";
		}
		
		//[self.clearAccountButton setupBlue];
		
		

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


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
   
	
	// Need to copy these out, because setting the selection causes changed() to get called,
	// which causes self.speed and self.plan to get written. So self.plan got the old value out of the control, which it then set. Yuk!
	NSString *newSpeed = [speed copy];
	NSString *newPlan = [plan copy];
	NSString *newImageSize = [imageSize copy];
	NSString *newMapStyle = [mapStyle copy];
	
	[self select:speedControl byString:newSpeed];
	[self select:planControl byString:newPlan];
	[self select:imageSizeControl byString:newImageSize];
	[self select:mapStyleControl byString:newMapStyle];
	
	
	self.navigationController.navigationBar.tintColor=[UIColor grayColor];
	
	[self.view addSubview:controlView];
	[(UIScrollView*) self.view setContentSize:CGSizeMake(320, controlView.frame.size.height)];
	
	[self createBlueButton:clearAccountButton withText:@"Log out"];
	
	
	 [super viewDidLoad];
	
}


-(void)createBlueButton:(UIButton*)button withText:(NSString*)text{
	
	UIFont *font=button.titleLabel.font;
	
	
	// Configure background image(s)
	[button setBackgroundImage:[[UIImage imageNamed:@"blueButton.png"] stretchableImageWithLeftCapWidth:9 topCapHeight:0 ] forState:UIControlStateNormal];
	
	
	
	// Configure title(s)
	[button setTitle:text forState:UIControlStateNormal];
	button.titleLabel.userInteractionEnabled=NO;
	button.titleLabel.font=font;
	[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[button setTitleShadowColor:[UIColor colorWithRed:.25 green:.25 blue:.25 alpha:1] forState:UIControlStateNormal];
	button.titleLabel.textAlignment=UITextAlignmentCenter;
	button.titleLabel.shadowOffset=CGSizeMake(0, -1);
	
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)nullify {
	self.planControl = nil;
	self.speedControl = nil;
	self.imageSizeControl = nil;
	self.mapStyleControl = nil;
	self.clearAccountButton = nil;
	self.controlView=nil;
	self.accountNameLabel=nil;
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
	CycleStreets *cycleStreets = [CycleStreets sharedInstance];
	[cycleStreets.files setSettings:dict];	
}

- (IBAction) changed {
	//bring all visible fields in line with the values in the tabs
	self.plan = [[planControl titleForSegmentAtIndex:planControl.selectedSegmentIndex] lowercaseString];
	self.speed = [[speedControl titleForSegmentAtIndex:speedControl.selectedSegmentIndex] lowercaseString];
	self.imageSize = [[imageSizeControl titleForSegmentAtIndex:imageSizeControl.selectedSegmentIndex] lowercaseString];
	self.mapStyle = [[mapStyleControl titleForSegmentAtIndex:mapStyleControl.selectedSegmentIndex] lowercaseString];
	
	//save changed settings
	[self save];
}

- (IBAction) didClearAccount {
	CycleStreets *cycleStreets = [CycleStreets sharedInstance];
	[cycleStreets.files resetPasswordInKeyChain];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"NotificationClearAccount" object:nil];
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
