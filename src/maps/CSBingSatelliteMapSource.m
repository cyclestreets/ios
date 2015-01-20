//
//  CSBingSatelliteMapSource.m
//  CycleStreets
//
//  Created by Neil Edwards on 16/01/2015.
//  Copyright (c) 2015 CycleStreets Ltd. All rights reserved.
//

#import "CSBingSatelliteMapSource.h"
#import "StringUtilities.h"

static NSString *const BINGAPIKEY=@"AgHV52-Gik3ea9np4bd9njM-kWOtQuGZne-sV96AeQtq9beH7Z_eumfxrAkYCNmY";

@implementation CSBingSatelliteMapSource


// getters

-(int)maxZoom{
	return 19;
}

-(int)minZoom{
	return 1;
}

-(BOOL)isRetinaEnabled{
	return YES;
}


// for use with new retina tiles
-(NSString*)cacheTileTemplate{
	
	if([self isRetinaEnabled]){
		return @"http://tile.cyclestreets.net/mapnik/%li/%li/%li@%ix.png";
	}else{
		return @"http://tile.cyclestreets.net/mapnik/%li/%li/%li.png";
	}
	
}

// for use directly with map kit, if - (NSURL *)URLForTilePath:(MKTileOverlayPath)path is implemented this is effectively ignored
- (NSString *)remotetileTemplate{
	
	if([self isRetinaEnabled]){
		return @"http://ecn.t2.tiles.virtualearth.net/tiles/h%@.jpeg?g=3218&mkt=en-GB";
	}else{
		return @"http://tile.cyclestreets.net/mapnik/{z}/{x}/{y}.png";
	}
}


- (NSURL *)URLForTilePath:(MKTileOverlayPath)path{
	
	NSString *quadKey=[self convertXZYToQuadKey:path];
	
	NSString *urlstring=NSStringFormat([self remotetileTemplate],quadKey);
	
	NSURL *url= [NSURL URLWithString:urlstring];
	
	return url;
}



-(NSString*)convertXZYToQuadKey:(MKTileOverlayPath)path{
	
	NSMutableString *quadKey=[[NSMutableString alloc]init];
	
	for (int i=path.z; i>0; --i) {
		
		int bitmask=1 << (i - 1);
		int digit=0;
		
		if ((path.x & bitmask) != 0) {
			digit++;
		}
		if ((path.y & bitmask) != 0) {
			digit++;
			digit++;
		}
		
		[quadKey appendFormat:@"%i",digit];
		
	}
	return quadKey;
}


- (NSString *)uniqueTilecacheKey
{
	return MAPPING_BASE_BING_SATELLITE;
}

- (NSString *)shortName
{
	return @"Bing Map";
}

- (NSString *)longDescription
{
	return @"Bing";
}

- (NSString *)shortDescription
{
	return @"Bing Satellite map style";
}

- (NSString *)shortAttribution
{
	return @"© Bing ";
}

- (NSString *)longAttribution
{
	return @"Map data © Microsoft";
}

-(NSString*)thumbnailImage{
	return @"BSMapStyle.png";
}


@end
