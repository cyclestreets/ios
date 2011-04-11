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

//  Markers.m
//  CycleStreets
//
//  Created by Alan Paxton on 04/05/2010.
//

#import "Markers.h"
#import "RMMarker.h"
#import "Common.h"
#import "ImageOperations.h"

@implementation Markers

+ (RMMarker *)marker:(NSString *)name label:(NSString *)label {
	UIImage *image = [UIImage imageNamed:name];
	RMMarker *marker = [[[RMMarker alloc] initWithUIImage:image] autorelease];
	[marker changeLabelUsingText:label];
	return marker;
}

+ (RMMarker *)markerStart {
	return [Markers marker:@"CSIcon_start_wisp.png" label:nil];
}

+ (RMMarker *)markerEnd {
	return [Markers marker:@"CSIcon_end_wisp.png" label:nil];
}

+ (RMMarker *)markerWaypoint {
	return [Markers marker:@"map-pin.png" label:nil];
}

+ (RMMarker *)markerPhoto {
	//return [Markers marker:@"map-marker.png" label:nil];
	return [Markers marker:@"photo.png" label:nil];
}

+ (RMMarker *)marker:(NSString *)name atAngle:(int)angle {
	UIImage *image = [UIImage imageNamed:name];
	CGImageRef copy = [ImageOperations CGImageRotatedByAngle:image.CGImage angle:angle];
	UIImage *rotated = [UIImage imageWithCGImage:copy];
	RMMarker *marker = [[[RMMarker alloc] initWithUIImage:rotated] autorelease];
	return marker;	
}

+ (RMMarker *)markerBeginArrow:(int)angle {
	DLog(@"from %d", angle);
	return [Markers marker:@"CSIcon_MapArrow_start.png" atAngle:360-angle];
}

+ (RMMarker *)markerEndArrow:(int)angle {
	DLog(@"to %d", angle);
	return [Markers marker:@"CSIcon_MapArrow_end.png" atAngle:360-angle];
}

@end
