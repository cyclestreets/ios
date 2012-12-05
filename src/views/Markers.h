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

//  Markers.h
//  CycleStreets
//
//  Created by Alan Paxton on 04/05/2010.
//

#import <Foundation/Foundation.h>
@class RMMarker;

@interface Markers : NSObject {

}

+ (RMMarker *)marker:(NSString *)name label:(NSString *)label;
+ (RMMarker *)markerStart;
+ (RMMarker *)markerEnd;
+ (RMMarker *)markerWaypoint;
+ (RMMarker *)markerPhoto;
+ (RMMarker *)markerUserPhoto;
+ (RMMarker *)marker:(NSString *)name atAngle:(int)degrees;
+ (RMMarker *)markerBeginArrow:(int)degrees;
+ (RMMarker *)markerEndArrow:(int)degrees;

@end
