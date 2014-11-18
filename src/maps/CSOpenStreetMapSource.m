//
//  OpenStreetMapsSource.m
//
// Copyright (c) 2008-2013, Route-Me Contributors
// All rights reserved.
//


#import "CSOpenStreetMapSource.h"
#import "AppConstants.h"


@interface CSOpenStreetMapSource()

@property NSCache			*cache;
@property NSOperationQueue	*operationQueue;

@end

@implementation CSOpenStreetMapSource


- (instancetype)init
{
	self = [super init];
	if (self) {
		self.cache=[[NSCache alloc]init];
		self.operationQueue=[[NSOperationQueue alloc]init];
	}
	return self;
}


-(int)maxZoom{
	return 19;
}

-(int)minZoom{
	return 1;
}

// Prelim supporrt for cacheing tiles

- (void)loadTileAtPath:(MKTileOverlayPath)path result:(void (^)(NSData *data, NSError *error))result
{
	if (!result) {
		return;
	}
	NSString *keyPath = [self stringFromTileOverlayPath:path];
	[self loadCachedTileFromFileSystem:path];
	NSPurgeableData *cachedData = [self.cache objectForKey:[self URLForTilePath:path]];
	
	if (cachedData) {
		result(cachedData, nil);
	} else {
		NSURLRequest *request = [NSURLRequest requestWithURL:[self URLForTilePath:path] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:20];
		[NSURLConnection sendAsynchronousRequest:request queue:self.operationQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
			
			NSPurgeableData *cachedData=nil;
			if(data) {
				cachedData = [NSPurgeableData dataWithData:data];
				[self.cache setObject:cachedData forKey: keyPath];
				[self saveTile:cachedData toFileSystemWithTilePath:path];
			}
			result(data, connectionError);
			
		}];
	}
}


-(NSPurgeableData*)loadCachedTileFromFileSystem:(MKTileOverlayPath)path{
	
	// check file system
	
	// if there load and add to cache
	
	// return
	
	return nil;
}


-(NSString*)stringFromTileOverlayPath:(MKTileOverlayPath)path{
	return EMPTYSTRING;
	
}

-(void)saveTile:(NSPurgeableData*)data toFileSystemWithTilePath:(MKTileOverlayPath)path{
	
	// tiles should go in map source directorys
	// then z_x_y.png format inc scale @2x
	
}

// end


- (NSURL *)URLForTilePath:(MKTileOverlayPath)path{
	
	//NSString *tileURLString=[NSString stringWithFormat:@"http://tile.cyclestreets.net/mapnik/%li/%li/%li@%ix.png",(long)path.z,(long)path.x, (long)path.y, (int)path.contentScaleFactor];
	//return [NSURL URLWithString:tileURLString];
	
	NSString *tileURLString=[NSString stringWithFormat:@"http://tile.cyclestreets.net/mapnik/%li/%li/%li.png",(long)path.z,(long)path.x, (long)path.y];
	return [NSURL URLWithString:tileURLString];
	
}


- (NSString *)tileTemplate{
	
	return @"http://tile.cyclestreets.net/mapnik/{z}/{x}/{y}.png";

	//return @"http://tile.cyclestreets.net/mapnik/{z}/{x}/{y}@{s}x.png";
}

- (NSString *)uniqueTilecacheKey
{
	return MAPPING_BASE_OSM;
}

- (NSString *)shortName
{
	return @"Open Street Map";
}

- (NSString *)longDescription
{
	return @"Open Street Map, the free wiki world map, provides freely usable map data for all parts of the world, under the Creative Commons Attribution-Share Alike 2.0 license.";
}

- (NSString *)shortDescription
{
	return @"General map style";
}

- (NSString *)shortAttribution
{
	return @"© OpenStreetMap contributors";
}

- (NSString *)longAttribution
{
	return @"Map data © OpenStreetMap, licensed under Creative Commons Share Alike By Attribution.";
}

-(NSString*)thumbnailImage{
	return @"OSMMapStyle.png";
}



@end
