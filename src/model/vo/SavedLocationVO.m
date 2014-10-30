//
//  SavedLocationVO.m
//  CycleStreets
//
//  Created by Neil Edwards on 14/10/2014.
//  Copyright (c) 2014 CycleStreets Ltd. All rights reserved.
//

#import "SavedLocationVO.h"
#import "GlobalUtilities.h"
#import "GenericConstants.h"

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
	
	return [SavedLocationVO imageForLocationType:_locationType];
	
}



-(void)setCoordinate:(CLLocationCoordinate2D)coord{
	
	self.latitude=@(coord.latitude);
	self.longitude=@(coord.longitude);
	
}

-(CLLocationCoordinate2D)coordinate{
	
	return CLLocationCoordinate2DMake([_latitude doubleValue], [_longitude doubleValue]);
	
}


#pragma mark - getters


-(NSString*)coordinateString{
	
	CLLocationCoordinate2D coordinate=[self coordinate];
	
	return [NSString stringWithFormat:@"%f, %f",coordinate.latitude,coordinate.longitude];
	
}

-(BOOL)isValid{
	
	if([_title isEqualToString:EMPTYSTRING])
		return NO;
	
	if (_latitude==0 || _longitude==0) {
		return NO;
	}
	
	return YES;
	
}


#pragma mark - Class

+(NSArray*)locationTypeDataProvider{
	
	return @[@{@"title":@"Home",@"type":@(SavedLocationTypeHome)},
			 @{@"title":@"Work",@"type":@(SavedLocationTypeWork)},
			 @{@"title":@"Other",@"type":@(SavedLocationTypeOther)}];
	
}

+(NSString*)imageForLocationType:(SavedLocationType)locationType{
	
	switch (locationType) {
		case SavedLocationTypeHome:
			return @"CSIcon_saveloc_home.png";
			break;
		case SavedLocationTypeWork:
			return @"CSIcon_saveloc_work.png";
			break;
			
		default:
			return @"EmptyImage.png";
			break;
	}
}



@end
