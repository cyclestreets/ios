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

//  CSPointVO
//  CycleStreets
//

#import "CSPointVO.h"


//TODO: needs to support provisionName so we can draw different line types for provisions

@implementation CSPointVO


- (BOOL) insideRect:(CGRect)rect {
	if (_point.x < rect.origin.x) return NO;
	if (_point.y < rect.origin.y) return NO;
	if (_point.x > rect.origin.x + rect.size.height) return NO;
	if (_point.y > rect.origin.y + rect.size.width) return NO;
	
	return YES;
}

- (NSString *)description {
	return [NSString stringWithFormat:@"(x=%f,y=%f)", _point.x, _point.y];
}

// getters
-(CLLocationCoordinate2D)coordinate{
	CLLocationCoordinate2D location;
	location.longitude=_point.x;
	location.latitude=_point.y;
	return location;
}


-(MKMapPoint)mapPoint{
	return MKMapPointForCoordinate(self.coordinate);
}




static NSString *kP_KEY = @"point";
static NSString *kIS_WALKING_KEY = @"isWalking";



//===========================================================
//  Keyed Archiving
//
//===========================================================
- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeCGPoint:self.point forKey:kP_KEY];
    [encoder encodeBool:self.isWalking forKey:kIS_WALKING_KEY];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if (self) {
        self.point = [decoder decodeCGPointForKey:kP_KEY];
        self.isWalking = [decoder decodeBoolForKey:kIS_WALKING_KEY];
    }
    return self;
}

@end
