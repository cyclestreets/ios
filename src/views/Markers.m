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
#import "ImageOperations.h"
#import "UKImage.h"
#import "GlobalUtilities.h"
#import "UIImage+Operations.h"

@implementation Markers

+ (RMMarker *)marker:(NSString *)name label:(NSString *)label {
	UIImage *image = [UIImage imageNamed:name];
	RMMarker *marker = [[RMMarker alloc] initWithUIImage:image];
	[marker changeLabelUsingText:label];
	return marker;
}

+ (RMMarker *)markerStart {
	return [Markers marker:@"CSIcon_start_wisp.png" label:nil];
}

+ (RMMarker *)markerIntermediate:(NSString*)index {
	return [Markers marker:@"CSIcon_intermediate_wisp.png" label:index];
}

+ (RMMarker *)markerEnd {
	return [Markers marker:@"CSIcon_finish_wisp.png" label:nil];
}

// never referenced
+ (RMMarker *)markerWaypoint {
	return [Markers marker:@"Map_Pin_Green.png" label:nil];
}

+ (RMMarker *)markerPhoto {
	return [Markers marker:@"UIIcon_photomap.png" label:nil];
}

+ (RMMarker *)markerUserPhoto {
	return [Markers marker:@"UIIcon_userphotomap.png" label:nil];
}

+ (RMMarker *)marker:(NSString *)name atAngle:(int)angle {
	UIImage *image = [UIImage imageNamed:name];
	
	UIImage *rotated=[UIImage rotateImage:image byDegrees:angle];
	RMMarker *marker = [[RMMarker alloc] initWithUIImage:rotated];
	return marker;	
}

+ (RMMarker *)markerBeginArrow:(int)angle {
	
	return [Markers marker:@"CSIcon_MapArrow_start.png" atAngle:angle];
}

+ (RMMarker *)markerEndArrow:(int)angle {
	
	return [Markers marker:@"CSIcon_MapArrow_end.png" atAngle:angle];
}


@end
