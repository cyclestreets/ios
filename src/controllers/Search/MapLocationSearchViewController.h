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

//  Namefinder2.h
//  CycleStreets
//
//  Created by Alan Paxton on 02/08/2010.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
@class XMLRequest;

@protocol LocationReceiver
- (void) didMoveToLocation:(CLLocationCoordinate2D)location;
@end

@interface MapLocationSearchViewController : UITableViewController
<UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchDisplayDelegate> {
	
	id<LocationReceiver>				locationReceiver;
	CLLocationCoordinate2D				centreLocation;
	@private NSString					*currentRequestSearchString;
	@private NSString					*searchString;
	@private XMLRequest					*request;
	@private NSMutableArray				*currentPlaces;
	@private UIActivityIndicatorView	*activeLookup;
	@private UIView						*activeBackground;
}

@property (nonatomic, retain) id<LocationReceiver> locationReceiver;
@property CLLocationCoordinate2D centreLocation;
@property (nonatomic, copy) NSString *searchString;
@property (nonatomic, copy) NSString *currentRequestSearchString;
@property (nonatomic, retain) XMLRequest *request;
@property (nonatomic, retain) NSMutableArray *currentPlaces;
@property (nonatomic, retain) UIActivityIndicatorView *activeLookup;
@property (nonatomic, retain) UIView *activeBackground;

- (void) lookupNames;

@end
