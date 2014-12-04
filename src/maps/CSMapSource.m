//
//  CSMapSource.m
//  CycleStreets
//
//  Created by Neil Edwards on 04/06/2014.
//  Copyright (c) 2014 CycleStreets Ltd. All rights reserved.
//

#import "CSMapSource.h"
#import "GlobalUtilities.h"
#import "AppConstants.h"

@interface CSMapSource()

@property (nonatomic,strong) NSCache									*cache;
@property (nonatomic,strong) NSOperationQueue							*operationQueue;


@end

@implementation CSMapSource


- (instancetype)init
{
	self = [super init];
	if (self) {
		self.cache=[[NSCache alloc]init];
		_cache.countLimit=100;
		self.operationQueue=[[NSOperationQueue alloc]init];
		[self createCacheDirectory];
	}
	return self;
}


// Prelim support for cacheing tiles

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
	
	// convert path values to zoom+1
	
	if([self isRetinaEnabled]){
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
	
	if([self isRetinaEnabled]){
		
		NSString *tileURLString=[NSString stringWithFormat:[self cacheTileTemplate],(long)path.z,(long)path.x, (long)path.y, (int)path.contentScaleFactor];
		return [NSURL URLWithString:tileURLString];
		
	}else{
		
		NSString *tileURLString=[NSString stringWithFormat:[self cacheTileTemplate],(long)path.z,(long)path.x, (long)path.y];
		return [NSURL URLWithString:tileURLString];
		
	}
	
}

// MUST BE OVERRIDDEN BY SUBCLASSES
-(NSString*)cacheTileTemplate{
	BetterLog(@"[ERROR] MUST BE OVERRIDDEN BY SUBCLASSES");
	return nil;
	
}

@end
