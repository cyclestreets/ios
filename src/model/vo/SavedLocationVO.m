//
//  SavedLocationVO.m
//  CycleStreets
//
//  Created by Neil Edwards on 14/10/2014.
//  Copyright (c) 2014 CycleStreets Ltd. All rights reserved.
//

#import "SavedLocationVO.h"
#import "GlobalUtilities.h"

@interface SavedLocationVO()

@property (nonatomic,readwrite)  NSString									*locationID;

@end

@implementation SavedLocationVO

- (instancetype)init
{
	self = [super init];
	if (self) {
		_latitude=@(0.0);
		_longitude=@(0.0);
		_locationType=SavedLocationTypeOther;
		_locationID=[GlobalUtilities GUIDString];
	}
	return self;
}


-(NSString*)locationIcon{
	
	
	switch (_locationType) {
		case SavedLocationTypeHome:
		case SavedLocationTypeWork:
			return @"SavedLocation_CellIcon_Home.png";
		break;
			
		default:
			return @"EmptyImage.png";
		break;
	}
	
}



-(CLLocationCoordinate2D)coordinate{
	
	return CLLocationCoordinate2DMake([_latitude doubleValue], [_longitude doubleValue]);
	
}



//- (void)encodeWithCoder:(NSCoder *)aCoder{
//	
//	[aCoder encodeObject:self.title forKey:@"title"];
//	[aCoder encodeObject:self.locationID forKey:@"locationID"];
//	[aCoder encodeObject:self.latitude forKey:@"latitude"];
//	[aCoder encodeObject:self.longitude forKey:@"longitude"];
//	[aCoder encodeInteger:self.locationType forKey:@"locationType"];
//	
//}

@end
