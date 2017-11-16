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
#import "AppDelegate.h"
#import "Files.h"
#import "MapViewController.h"
#import "GenericConstants.h"
#import "AppConstants.h"
#import "SettingsManager.h"
#import "GlobalUtilities.h"
#import "BUHorizontalMenuView.h"
#import "BuildTargetConstants.h"
#import "ViewUtilities.h"
#import "MapStyleCellView.h"

@interface SettingsViewController()<BUHorizontalMenuDataSource,BUHorizontalMenuDelegate>

@property (nonatomic, strong)		SettingsVO								* dataProvider;
@property (nonatomic, strong)		IBOutlet UISegmentedControl				* planControl;
@property (nonatomic, strong)		IBOutlet UISegmentedControl				* speedControl;
@property (strong, nonatomic) IBOutlet BUHorizontalMenuView *mapStyleControl;

@property (nonatomic, strong)		IBOutlet UISegmentedControl				* imageSizeControl;
@property (nonatomic, strong)		IBOutlet UISegmentedControl				* routeUnitControl;
@property (nonatomic, strong)		IBOutlet UISwitch						* routePointSwitch;
@property (nonatomic, strong)		IBOutlet UIView							* controlView;
@property (nonatomic, strong)		IBOutlet UILabel						* speedTitleLabel;

@property (nonatomic,strong)		NSArray									*mapStyleDataProvider;


@end

@implementation SettingsViewController



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
	
	self.dataProvider=[SettingsManager sharedInstance].dataProvider;
	
	[self select:_speedControl byString:_dataProvider.speed];
	[self select:_planControl byString:_dataProvider.plan];
	[self select:_imageSizeControl byString:_dataProvider.imageSize];
	//[self select:_mapStyleControl byString:[_dataProvider.mapStyle lowercaseString]];
	[self select:_routeUnitControl byString:_dataProvider.routeUnit];
	_routePointSwitch.on=_dataProvider.showRoutePoint;
	
	[_routeUnitControl addTarget:self action:@selector(changed:) forControlEvents:UIControlEventValueChanged];
	[_planControl addTarget:self action:@selector(changed:) forControlEvents:UIControlEventValueChanged];
	[_imageSizeControl addTarget:self action:@selector(changed:) forControlEvents:UIControlEventValueChanged];
	[_speedControl addTarget:self action:@selector(changed:) forControlEvents:UIControlEventValueChanged];
	[_routePointSwitch addTarget:self action:@selector(changed:) forControlEvents:UIControlEventValueChanged];
	
	
	self.mapStyleDataProvider=[CycleStreets appMapStylesDataProvider];
	[_mapStyleControl reloadData];
	[_mapStyleControl setSelectedIndex:[self selectedMapStyle:_dataProvider.mapStyle] animated:YES];
	
	[self.view addSubview:_controlView];
	[(UIScrollView*) self.view setContentSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, _controlView.frame.size.height)];
	
	 [super viewDidLoad];
	
}

-(NSInteger)selectedMapStyle:(NSString*)mapStyle{
	
	NSInteger index=[_mapStyleDataProvider indexOfObjectPassingTest:^BOOL(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
		
		if([obj[@"id"] isEqualToString:mapStyle]){
			*stop = YES;
			return YES;
		}
		return NO;
	}];
	
	if(index==NSNotFound)
		return 0;
	
	return index;
}


- (void) save {

	[[SettingsManager sharedInstance] saveData];	
}


- (IBAction) changed:(id)sender {
	
	BetterLog(@"");
	
	// Note: we have to update the routeunit first then update the linked segments before getting the definitive values;
	_dataProvider.routeUnit = [[_routeUnitControl titleForSegmentAtIndex:_routeUnitControl.selectedSegmentIndex] lowercaseString];
	_dataProvider.plan = [[_planControl titleForSegmentAtIndex:_planControl.selectedSegmentIndex] lowercaseString];
	_dataProvider.imageSize = [[_imageSizeControl titleForSegmentAtIndex:_imageSizeControl.selectedSegmentIndex] lowercaseString];
	_dataProvider.showRoutePoint = _routePointSwitch.isOn;
	
	
	
	[self updateRouteUnitDisplay];
	
	_dataProvider.speed = [[_speedControl titleForSegmentAtIndex:_speedControl.selectedSegmentIndex] lowercaseString];
	
	[[SettingsManager sharedInstance] saveData];
	
}

-(void)updateRouteUnitDisplay{
	
	if([_dataProvider.routeUnit isEqualToString:MILES]){
		_speedTitleLabel.text=@"Route speed (mph)";
		
		[_speedControl setTitle:@"10" forSegmentAtIndex:0];
		[_speedControl setTitle:@"12" forSegmentAtIndex:1];
		[_speedControl setTitle:@"15" forSegmentAtIndex:2];
		
	}else {
		_speedTitleLabel.text=@"Route speed (km/h)";
		
		[_speedControl setTitle:@"16" forSegmentAtIndex:0];
		[_speedControl setTitle:@"20" forSegmentAtIndex:1];
		[_speedControl setTitle:@"24" forSegmentAtIndex:2];
	}
	
}



#pragma mark - BUHorizontalmenu delegate


- (NSInteger) numberOfItemsForMenu:(BUHorizontalMenuView*) menuView{
	return _mapStyleDataProvider.count;
}



-(UIView<BUHorizontalMenuItem>*)menuViewItemForIndex:(NSInteger)index{
	
	MapStyleCellView *itemView=[ViewUtilities loadInstanceOfView:[MapStyleCellView class] fromNibNamed:@"MapStyleCellView"];
	
	itemView.dataProvider=_mapStyleDataProvider[index];
	
	return itemView;
	
}


- (void)horizMenu:(BUHorizontalMenuView*) menuView itemSelectedAtIndex:(NSInteger) index{
	
	NSDictionary *mapDict=_mapStyleDataProvider[index];
	_dataProvider.mapStyle=mapDict[@"id"];
	
	[[SettingsManager sharedInstance] saveData];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"NotificationMapStyleChanged" object:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



@end
