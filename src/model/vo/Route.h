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

//  Route.h
//  CycleStreets
//
//  Created by Alan Paxton on 03/03/2010.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
@class SegmentVO;

@interface Route : NSObject {
	NSMutableArray *segments;
	NSDictionary *header;
	
	NSString		*userRouteName;
}
@property (nonatomic, retain)	NSMutableArray		*segments;
@property (nonatomic, retain)	NSDictionary		*header;
@property (nonatomic, retain)	NSString		*userRouteName;


// getters
@property (nonatomic, readonly)	NSString	*timeString;
@property (nonatomic, readonly)	NSString	*lengthString;
@property (nonatomic, readonly)	NSString	*speedString;
@property (nonatomic, readonly)	NSString	*dateString;
@property (nonatomic, readonly)	NSString	*planString;



- (id) initWithElements:(NSDictionary *)elements;

+ (NSArray *) routeXMLElementNames;

- (int) numSegments;

- (SegmentVO *) segmentAtIndex:(int)index;

- (NSString *) itinerary;

- (CLLocationCoordinate2D) northEast;
- (CLLocationCoordinate2D) insetNorthEast;

- (CLLocationCoordinate2D) southWest;
- (CLLocationCoordinate2D) insetSouthWest;

- (NSString *) name;

- (NSInteger) speed;

- (NSNumber *) length;

- (NSString *) plan;

- (NSInteger) time;

- (NSString *) date;

- (void) setUIElements:(NSObject *)view;/*or controller*/





@end
