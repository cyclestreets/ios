//
//  CSCycleNorthMapSource.m
//  CycleStreets
//
//  Created by Neil Edwards on 09/10/2014.
//  Copyright (c) 2014 CycleStreets Ltd. All rights reserved.
//

#import "CSCycleNorthMapSource.h"

@implementation CSCycleNorthMapSource


-(int)maxZoom{
	return 19;
}

-(int)minZoom{
	return 1;
}

-(BOOL)isRetinaEnabled{
	return NO;
}




// for use with new retina tiles
-(NSString*)cacheTileTemplate{
	
	if([self isRetinaEnabled]){
		return @"http://tile.cyclestreets.net/cyclenorthstaffs/%li/%li/%li@%ix.png";
	}else{
		return @"http://tile.cyclestreets.net/cyclenorthstaffs/%li/%li/%li.png";
	}
	
}

// for use directly with map kit, if - (NSURL *)URLForTilePath:(MKTileOverlayPath)path is implemented this is effectively ignored
- (NSString *)tileTemplate{
	
	if([self isRetinaEnabled]){
		return @"http://tile.cyclestreets.net/cyclenorthstaffs/{z}/{x}/{y}/{s}.png";
	}else{
		return @"http://tile.cyclestreets.net/cyclenorthstaffs/{z}/{x}/{y}.png";
	}
}




- (NSString *)uniqueTilecacheKey
{
	return MAPPING_BASE_CYCLENORTH;
}

- (NSString *)shortName
{
	return @"Cycle North Staffs";
}

- (NSString *)longDescription
{
	return @"Cycle North Staffs";
}

- (NSString *)shortDescription
{
	return @"Cycle North Staffs cycle map";
}

- (NSString *)shortAttribution
{
	return @" © Cycle North Staffs; data © OpenStreetMap contributors ";
}

- (NSString *)longAttribution
{
	return @"Map data © Cycle North Staffs, licensed under Creative Commons Share Alike By Attribution.";
}


-(NSDictionary*)settingsDict{
	
	return @{@"id":self.uniqueTilecacheKey, @"title":self.shortName,@"description":self.shortDescription,@"thumbnailimage":self.thumbnailImage};
	
}

-(NSString*)thumbnailImage{
	return @"CNSMapStyle.png";
}


@end
