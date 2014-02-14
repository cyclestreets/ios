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
//

#import "SettingsViewController.h"
#import "AppConstants.h"
#import "SettingsManager.h"
#import "GlobalUtilities.h"


@interface SettingsViewController()

@property (nonatomic, strong)		IBOutlet UISegmentedControl				* mapStyleControl;
@property (nonatomic, strong)		IBOutlet UISegmentedControl				* routeUnitControl;
@property (nonatomic, strong)		IBOutlet UISegmentedControl				* imageSizeControl;
@property (nonatomic, strong)		IBOutlet UISwitch						* autoEndSwitch;

@property(nonatomic,weak) IBOutlet UIView									*viewContainer;

@end


@implementation SettingsViewController




- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        
		[SettingsManager sharedInstance];
		self.dataProvider=[SettingsManager sharedInstance].dataProvider;
		
    }
    return self;
}

- (void) select:(UISegmentedControl *)control byString:(NSString *)selectTitle {
	for (NSInteger i = 0; i < [control numberOfSegments]; i++) {
		NSString *title = [[control titleForSegmentAtIndex:i] lowercaseString];
		if (NSOrderedSame == [title compare: selectTitle]) {
			control.selectedSegmentIndex = i;
			break;
		}
	}	
}


- (void)viewDidLoad {
	
	
	[self select:_mapStyleControl byString:[_dataProvider.mapStyle lowercaseString]];
	[self select:_routeUnitControl byString:_dataProvider.routeUnit];
	[self select:_imageSizeControl byString:_dataProvider.imageSize];
	//_autoEndSwitch.on=_dataProvider.autoEndRoute;
	
	[_routeUnitControl addTarget:self action:@selector(changed:) forControlEvents:UIControlEventValueChanged];
	[_mapStyleControl addTarget:self action:@selector(changed:) forControlEvents:UIControlEventValueChanged];
	[_imageSizeControl addTarget:self action:@selector(changed:) forControlEvents:UIControlEventValueChanged];
	[_autoEndSwitch addTarget:self action:@selector(changed:) forControlEvents:UIControlEventValueChanged];

	
	[self.view addSubview:_viewContainer];
	[(UIScrollView*) self.view setContentSize:CGSizeMake(SCREENWIDTH, _viewContainer.frame.size.height)];
	
	 [super viewDidLoad];
	
}


- (void) save {

	[[SettingsManager sharedInstance] saveData];	
}


- (IBAction) changed:(id)sender {
	
	BetterLog(@"");
	
	// Note: we have to update the routeunit first then update the linked segments before getting the definitive values;
	_dataProvider.routeUnit = [[_routeUnitControl titleForSegmentAtIndex:_routeUnitControl.selectedSegmentIndex] lowercaseString];
	_dataProvider.mapStyle = [_mapStyleControl titleForSegmentAtIndex:_mapStyleControl.selectedSegmentIndex];
	_dataProvider.imageSize = [[_imageSizeControl titleForSegmentAtIndex:_imageSizeControl.selectedSegmentIndex] lowercaseString];
	
	//_dataProvider.autoEndRoute = _autoEndSwitch.isOn;
	
	UISegmentedControl *control=(UISegmentedControl*)sender;
	
	if(control==_mapStyleControl)
		[[NSNotificationCenter defaultCenter] postNotificationName:MAPSTYLECHANGED object:nil];
	
	//if(control==_routeUnitControl)
	//	[[NSNotificationCenter defaultCenter] postNotificationName:MAPUNITCHANGED object:nil];
	
	
	[[SettingsManager sharedInstance] saveData];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}




@end
