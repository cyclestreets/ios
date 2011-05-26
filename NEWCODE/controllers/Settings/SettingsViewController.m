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

#import "SettingsViewController.h"
#import "CycleStreets.h"
#import "Query.h"
#import "CycleStreetsAppDelegate.h"
#import "Files.h"
#import "MapViewController.h"
#import "UIButton+Blue.h"
#import "Common.h"
#import "AppConstants.h"
#import "SettingsManager.h"
#import "GlobalUtilities.h"

@implementation SettingsViewController
@synthesize dataProvider;
@synthesize planControl;
@synthesize speedControl;
@synthesize mapStyleControl;
@synthesize imageSizeControl;
@synthesize routeUnitControl;
@synthesize controlView;
@synthesize speedTitleLabel;

/***********************************************************/
// dealloc
/***********************************************************/
- (void)dealloc
{
    [dataProvider release], dataProvider = nil;
    [planControl release], planControl = nil;
    [speedControl release], speedControl = nil;
    [mapStyleControl release], mapStyleControl = nil;
    [imageSizeControl release], imageSizeControl = nil;
    [routeUnitControl release], routeUnitControl = nil;
    [controlView release], controlView = nil;
    [speedTitleLabel release], speedTitleLabel = nil;
	
    [super dealloc];
}



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        
		[SettingsManager sharedInstance];
		self.dataProvider=[SettingsManager sharedInstance].dataProvider;
		
    }
    return self;
}

- (void) select:(UISegmentedControl *)control byString:(NSString *)selectTitle {
	for (NSInteger i = 0; i < [control numberOfSegments]; i++) {
		NSString *title = [[[control titleForSegmentAtIndex:i] lowercaseString] copy];
		if (NSOrderedSame == [title compare: selectTitle]) {
			control.selectedSegmentIndex = i;
			break;
		}
		[title release];
	}	
}


- (void)viewDidLoad {
	
	[self select:speedControl byString:dataProvider.speed];
	[self select:planControl byString:dataProvider.plan];
	[self select:imageSizeControl byString:dataProvider.imageSize];
	[self select:mapStyleControl byString:[dataProvider.mapStyle lowercaseString]];
	[self select:routeUnitControl byString:dataProvider.routeUnit];
	
	[routeUnitControl addTarget:self action:@selector(changed:) forControlEvents:UIControlEventValueChanged];
	[planControl addTarget:self action:@selector(changed:) forControlEvents:UIControlEventValueChanged];
	[imageSizeControl addTarget:self action:@selector(changed:) forControlEvents:UIControlEventValueChanged];
	[mapStyleControl addTarget:self action:@selector(changed:) forControlEvents:UIControlEventValueChanged];
	[speedControl addTarget:self action:@selector(changed:) forControlEvents:UIControlEventValueChanged];
	
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

	[[SettingsManager sharedInstance] saveData];	
}

- (IBAction) changed:(id)sender {
	
	// Note: we have to update the routeunit first then update the linked segments before getting the definitive values;
	dataProvider.routeUnit = [[routeUnitControl titleForSegmentAtIndex:routeUnitControl.selectedSegmentIndex] lowercaseString];
	dataProvider.plan = [[planControl titleForSegmentAtIndex:planControl.selectedSegmentIndex] lowercaseString];
	dataProvider.imageSize = [[imageSizeControl titleForSegmentAtIndex:imageSizeControl.selectedSegmentIndex] lowercaseString];
	dataProvider.mapStyle = [mapStyleControl titleForSegmentAtIndex:mapStyleControl.selectedSegmentIndex];
	
	UISegmentedControl *control=(UISegmentedControl*)sender;
	
	if(control==mapStyleControl)
		[[NSNotificationCenter defaultCenter] postNotificationName:@"NotificationMapStyleChanged" object:nil];
	
	[self updateRouteUnitDisplay];
	
	dataProvider.speed = [[speedControl titleForSegmentAtIndex:speedControl.selectedSegmentIndex] lowercaseString];
	
	[[SettingsManager sharedInstance] saveData];
}

-(void)updateRouteUnitDisplay{
	
	if([dataProvider.routeUnit isEqualToString:MILES]){
		speedTitleLabel.text=@"Route speed (mph)";
		
		[speedControl setTitle:@"10" forSegmentAtIndex:0];
		[speedControl setTitle:@"12" forSegmentAtIndex:1];
		[speedControl setTitle:@"15" forSegmentAtIndex:2];
		
	}else {
		speedTitleLabel.text=@"Route speed (kmh)";
		
		[speedControl setTitle:@"16" forSegmentAtIndex:0];
		[speedControl setTitle:@"20" forSegmentAtIndex:1];
		[speedControl setTitle:@"24" forSegmentAtIndex:2];
	}
	
}


@end
