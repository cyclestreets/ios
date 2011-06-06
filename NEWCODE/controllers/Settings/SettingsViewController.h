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

//  Settings.h
//  CycleStreets
//
//  Created by Alan Paxton on 02/03/2010.
//

#import <UIKit/UIKit.h>
#import "SettingsVO.h"
#import "RCSwitchOnOff.h"

@interface SettingsViewController : UIViewController {
	
	SettingsVO					*dataProvider;
	
	IBOutlet UISegmentedControl *planControl;
	IBOutlet UISegmentedControl *speedControl;
	IBOutlet UISegmentedControl *mapStyleControl;
	IBOutlet UISegmentedControl *imageSizeControl;
	IBOutlet UISegmentedControl *routeUnitControl;
	IBOutlet RCSwitchOnOff		*routePointSwitch;
	IBOutlet UIView	*controlView;
	
	IBOutlet	UILabel			*speedTitleLabel;
}

@property (nonatomic, retain)		SettingsVO				* dataProvider;
@property (nonatomic, retain)		IBOutlet UISegmentedControl				* planControl;
@property (nonatomic, retain)		IBOutlet UISegmentedControl				* speedControl;
@property (nonatomic, retain)		IBOutlet UISegmentedControl				* mapStyleControl;
@property (nonatomic, retain)		IBOutlet UISegmentedControl				* imageSizeControl;
@property (nonatomic, retain)		IBOutlet UISegmentedControl				* routeUnitControl;
@property (nonatomic, retain)		IBOutlet RCSwitchOnOff				* routePointSwitch;
@property (nonatomic, retain)		IBOutlet UIView				* controlView;
@property (nonatomic, retain)		IBOutlet UILabel				* speedTitleLabel;

- (IBAction) changed:(id)sender;

- (void) save;

-(void)updateRouteUnitDisplay;

@end
