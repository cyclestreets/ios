//
//  OpenStreetMapsSource.m
//
// Copyright (c) 2008-2013, Route-Me Contributors
// All rights reserved.
//


#import "CSOpenStreetMapSource.h"
#import "AppConstants.h"
#import "GlobalUtilities.h"

@interface CSOpenStreetMapSource()

@property (nonatomic,strong) NSCache									*cache;
@property (nonatomic,strong) NSOperationQueue							*operationQueue;

@property (nonatomic,assign) BOOL										retinaEnabled;

@end

@implementation CSOpenStreetMapSource


- (instancetype)init
{
	self = [super init];
	if (self) {
		self.cache=[[NSCache alloc]init];
		_cache.countLimit=100;
		self.operationQueue=[[NSOperationQueue alloc]init];
		_retinaEnabled=NO;
		[self createCacheDirectory];
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
	NSString *fileKey = [self stringFromTileOverlayPath:path];
	[self loadCachedTileFromFileSystem:path];
	NSPurgeableData *cachedData = [self.cache objectForKey:fileKey];
	
	if (cachedData) {
		//BetterLog(@"tile from cache");
		result(cachedData, nil);
	} else {
		NSURLRequest *request = [NSURLRequest requestWithURL:[self URLForTilePath:path] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:20];
		[NSURLConnection sendAsynchronousRequest:request queue:self.operationQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
			
			NSPurgeableData *cachedData=nil;
			if(data) {
				//BetterLog(@"tile from remote");
				cachedData = [NSPurgeableData dataWithData:data];
				[self.cache setObject:cachedData forKey: fileKey];
				[self saveTile:cachedData toFileSystemWithTilePath:path];
			}
			result(data, connectionError);
			
		}];
	}
}


-(void)loadCachedTileFromFileSystem:(MKTileOverlayPath)path{
	
	NSFileManager* fileManager = [NSFileManager defaultManager];
	NSString *dirpath=[self filePath];
	NSString *fileKey=[self stringFromTileOverlayPath:path];
	NSString *filePath=[dirpath stringByAppendingPathComponent:fileKey];
	
	BOOL isDir=NO;
	NSPurgeableData *fileData=nil;
	if([fileManager fileExistsAtPath:filePath isDirectory:&isDir]){
		fileData=[NSPurgeableData dataWithContentsOfFile:filePath];
	}
	
	if(fileData!=nil){
		[self.cache setObject:fileData forKey:fileKey];
	}
}


// ie OpenStreetMap_12_34_65@2x.png"
-(NSString*)stringFromTileOverlayPath:(MKTileOverlayPath)path{
	
	if(_retinaEnabled){
		return [NSString stringWithFormat:@"%@_%li_%li_%li@%ix.png",[self uniqueTilecacheKey],(long)path.z,(long)path.x, (long)path.y, (int)path.contentScaleFactor];
	}else{
		return [NSString stringWithFormat:@"%@_%li_%li_%li.png",[self uniqueTilecacheKey],(long)path.z,(long)path.x, (long)path.y];
	}
	
	
}

-(void)saveTile:(NSPurgeableData*)data toFileSystemWithTilePath:(MKTileOverlayPath)path{
	
	NSString *fileKey=[self stringFromTileOverlayPath:path];
	NSString *filePath=[[self filePath] stringByAppendingPathComponent:fileKey];
	
	BOOL result=[data writeToFile:filePath atomically:YES];
	
	if(!result){
		BetterLog(@"[WARNING] Tilecache: file for %@ didnt complete",filePath);
	}
	
}


-(BOOL)createCacheDirectory{
	
	NSFileManager* fileManager = [NSFileManager defaultManager];
	NSString *filepath=[self filePath];
	
	BOOL isDir=YES;
	
	if([fileManager fileExistsAtPath:filepath isDirectory:&isDir]){
		return YES;
	}else {
		
		if([fileManager createDirectoryAtPath:filepath withIntermediateDirectories:NO attributes:nil error:nil ]){
			return YES;
		}else{
			return NO;
		}
	}
	
}

- (NSString *) filePath {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [[paths objectAtIndex:0] copy];
	return [documentsDirectory stringByAppendingPathComponent:[self uniqueTilecacheKey]];
}



// end


- (NSURL *)URLForTilePath:(MKTileOverlayPath)path{
	
	if(_retinaEnabled){
		
		NSString *tileURLString=[NSString stringWithFormat:[self cacheTileTemplate],(long)path.z,(long)path.x, (long)path.y, (int)path.contentScaleFactor];
		return [NSURL URLWithString:tileURLString];
		
	}else{
		
		NSString *tileURLString=[NSString stringWithFormat:[self cacheTileTemplate],(long)path.z,(long)path.x, (long)path.y];
		return [NSURL URLWithString:tileURLString];
		
	}
	
}

// for use with new retina tiles
-(NSString*)cacheTileTemplate{
	
	if(_retinaEnabled){
		return @"http://tile.cyclestreets.net/mapnik/%li/%li/%li@%ix.png";
	}else{
		return @"http://tile.cyclestreets.net/mapnik/%li/%li/%li.png";
	}

}

// for use directly with map kit, if - (NSURL *)URLForTilePath:(MKTileOverlayPath)path is implemented this is effectively ignored
- (NSString *)tileTemplate{
	
	if(_retinaEnabled){
		return @"http://tile.cyclestreets.net/mapnik/{z}/{x}/{y}/{s}.png";
	}else{
		return @"http://tile.cyclestreets.net/mapnik/{z}/{x}/{y}.png";
	}
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
