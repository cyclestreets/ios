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


@property (nonatomic, assign) CLLocationCoordinate2D  centreLocation;
@property (nonatomic, strong) NSString                * currentRequestSearchString;
@property (nonatomic, strong) NSString                * searchString;
@property (nonatomic, strong) XMLRequest              * request;
@property (nonatomic, strong) NSMutableArray          * currentPlaces;
@property (nonatomic, strong) UIActivityIndicatorView * activeLookup;
@property (nonatomic, strong) UIView                  * activeBackground;
@property (nonatomic, strong) id<LocationReceiver>    locationReceiver;

- (void) lookupNames;

- (void)didFailLookupwithMessage:(NSString *)message;

@end
