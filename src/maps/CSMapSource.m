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

#import "sys/stat.h"


#define fileExpiryAge 14 // this is days
#define directoryMaxSize 25 // this is mb

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
		[self purgeDirectoryForSize];
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
		
		BOOL shouldLoad=[self shouldLoadTileFromFileSystem:filePath];
		if(shouldLoad)
			fileData=[NSPurgeableData dataWithContentsOfFile:filePath];
	}
	
	if(fileData!=nil){
		[self.cache setObject:fileData forKey:fileKey];
	}
}


-(BOOL)shouldLoadTileFromFileSystem:(NSString*)filePath{
	
	NSFileManager* fileManager = [NSFileManager defaultManager];
	NSDate *filedate=[CSMapSource getModificationDateForFileAtPath:filePath];
	NSDate *now=[NSDate date];
	
	NSTimeInterval fileage = [now timeIntervalSinceDate:filedate];
	
	NSInteger cacheinterval=fileExpiryAge*TIME_DAY;
	
	if (fileage<cacheinterval) {
		return YES;
	}else {
		[fileManager removeItemAtPath:filePath error:nil];
		return NO;
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


-(void)purgeDirectoryForSize{
	
	NSFileManager* fileManager = [NSFileManager defaultManager];
	NSString *dirPath=[self filePath];
	NSDictionary *fileInfo=[fileManager attributesOfItemAtPath:dirPath error:nil];
	NSInteger dirSize=[[fileInfo objectForKey:NSFileSize] integerValue];
	
	NSInteger dirMb=dirSize/1000;
	
	if(dirMb>directoryMaxSize){
		
		NSError	*error = nil;
		NSArray *filesArray=[fileManager contentsOfDirectoryAtURL:[NSURL URLWithString:dirPath] includingPropertiesForKeys:@[NSURLPathKey,NSURLCreationDateKey] options:NSDirectoryEnumerationSkipsHiddenFiles error:&error];
		
		if(error != nil) {
			
			BetterLog(@"Error in reading files: %@", [error localizedDescription]);
			return;
			
		}else{
			
			
			dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
				
				BetterLog(@"starting purge file compare");
				
				// sort the files by modification date, this is the slow part.
				NSArray *sortedContent = [filesArray sortedArrayUsingComparator: ^(NSURL *fileDict1, NSURL *fileDict2){
					
					NSDate *file1Date;
					[fileDict1 getResourceValue:&file1Date forKey:NSURLCreationDateKey error:nil];
					
					NSDate *file2Date;
					[fileDict2 getResourceValue:&file2Date forKey:NSURLCreationDateKey error:nil];
					
					
					return [file2Date compare: file1Date];
					
				}];
				
				
				BetterLog(@"completed file compare");
						 
				NSInteger purgeCount=sortedContent.count/4;
				if(purgeCount==0){
					return;
				}
						 
				BetterLog(@"start purge for %i files",purgeCount);
				// do actual file purge, this is quick
				for(NSInteger fileIndex=purgeCount;fileIndex<sortedContent.count;fileIndex++){
						 
					NSURL *fileURL=[sortedContent objectAtIndex:fileIndex];
					
					NSString *filePath;
					[fileURL getResourceValue:&filePath forKey:NSURLPathKey error:nil];
					
					[fileManager removeItemAtPath:filePath error:nil];
				}
				
				BetterLog(@"completed purge for %i files",purgeCount);
					 
			});
				
		}
				
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


+ (NSDate*) getModificationDateForFileAtPath:(NSString*)path {
	struct tm* date; // create a time structure
	struct stat attrib; // create a file attribute structure
	
	stat([path UTF8String], &attrib);   // get the attributes of afile.txt
	
	date = gmtime(&(attrib.st_mtime));  // Get the last modified time and put it into the time structure
	
	NSDateComponents *comps = [[NSDateComponents alloc] init];
	[comps setSecond:   date->tm_sec];
	[comps setMinute:   date->tm_min];
	[comps setHour:     date->tm_hour];
	[comps setDay:      date->tm_mday];
	[comps setMonth:    date->tm_mon + 1];
	[comps setYear:     date->tm_year + 1900];
	
	NSCalendar *cal = [NSCalendar currentCalendar];
	NSTimeZone *tz = [NSTimeZone timeZoneWithAbbreviation:[[NSString alloc] initWithUTF8String:date->tm_zone]];
	cal.timeZone = tz;
	NSDate *modificationDate = [[cal dateFromComponents:comps] addTimeInterval:[[NSTimeZone systemTimeZone] secondsFromGMT]];
	
	
	return modificationDate;
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


-(NSString*)nextTileSubdomainPrefix{
	
	NSArray *tileServerPrefixes=[self tileServeSubDomainPrefixes];
	NSInteger nextServerIndex=self.currentTileServerPrefixIndex+=1;
	if(nextServerIndex==tileServerPrefixes.count)
		nextServerIndex=0;
	
	self.currentTileServerPrefixIndex=nextServerIndex;
	
	return tileServerPrefixes[self.currentTileServerPrefixIndex];
	
}

// MUST BE OVERRIDDEN BY SUBCLASSES
-(NSString*)cacheTileTemplate{
	BetterLog(@"[ERROR] MUST BE OVERRIDDEN BY SUBCLASSES");
	return nil;
	
}

@end
