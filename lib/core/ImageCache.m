//
//  ImageCache.m
//
//
//  Created by Neil Edwards on 13/07/2009.
//  Copyright 2009 buffer. All rights reserved.
//

#import "ImageCache.h"
#import "GlobalUtilities.h"

@interface ImageCache(Private) 

-(BOOL)createCacheDirectory;
-(void)compactArray:(NSString*)filename;

@end


@implementation ImageCache

SYNTHESIZE_SINGLETON_FOR_CLASS(ImageCache);
@synthesize imageCacheDict;
@synthesize maxItems;
@synthesize cachedItems;
@synthesize cachePath;



- (id) init
{
    self = [super init];
    if (self != nil) {
		
		maxItems=100;
		
        NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
		self.imageCacheDict=dict;
        
        NSMutableArray *arr=[[NSMutableArray alloc]init];
		self.cachedItems=arr;
		
		[self createCacheDirectory];
		
		[[NSNotificationCenter defaultCenter] 
		addObserver:self
		selector:@selector(didReceiveMemoryWarning:)
		name:UIApplicationDidReceiveMemoryWarningNotification  
		object:nil];  
    }
	
	
	
	
	
	
    return self;
}


// needs max size control and purging when full or memory warning recieved

-(UIImage*)imageExists:(NSString*)filename ofType:(NSString*)type{
	
	UIImage *image;
	image=[imageCacheDict objectForKey:filename];
	
	if(image!=nil){
		return image;
	}
	
	NSFileManager* fileManager = [NSFileManager defaultManager];
	BOOL fileisonDisk = [fileManager fileExistsAtPath:[self fileonDiskPath:filename ofType:type]];
	
	if(fileisonDisk==YES){
		image=[self loadImageFromDocuments:[self fileonDiskPath:filename ofType:type]];
		if(image!=nil){
			[self compactArray:filename];
			[imageCacheDict setObject:image forKey:filename];
		}
		
		return image;
	}
	
	return nil;  
}

// saves web loaded image to disk for use on subsequent uses
-(BOOL)saveImageToDisk:(UIImage*)image withName:(NSString*)filename ofType:(NSString*)type{
	

	NSData* data = UIImagePNGRepresentation(image);
	NSString *savepath=[self fileonDiskPath:filename ofType:type];
	
	[data writeToFile:savepath atomically:YES];
	
	return YES;
}


//
/***********************************************
 * @description			TMP Image ache support
 ***********************************************/
//

-(BOOL)saveTmpImageToDisk:(UIImage*)image withName:(NSString*)filename ofType:(NSString*)type{
	
	NSData* data = UIImagePNGRepresentation(image);
	NSString *savepath=[NSString stringWithFormat:@"%@/%@",[self tmpImagePath],filename];
	BetterLog(@"[DEBUG] saveTmpImageToDisk path=%@",savepath);
	[data writeToFile:savepath atomically:YES];
	
	return YES;
}
-(NSString*)tmpImagePath{
	NSString* dir=NSTemporaryDirectory();
	return [dir stringByAppendingPathComponent:kIMAGECACHEIRECTORY];
}

-(void)moveTmpImageToCache:(NSString*)filename{
	
	NSString *tmppath=[NSString stringWithFormat:@"%@/%@",[self tmpImagePath],filename];
	BetterLog(@"[DEBUG] move tmp path=%@",tmppath);
	NSFileManager* fileManager = [NSFileManager defaultManager];
	NSString *topath=[self fileonDiskPath:filename ofType:@""];
	BetterLog(@"[DEBUG] topath=%@",topath);
	NSError	*error;
	if([fileManager fileExistsAtPath:tmppath]){
		[fileManager moveItemAtPath:tmppath toPath:topath error:&error];
		if(error!=nil)
			BetterLog(@"[DEBUG] error=%@",[error description]);
		
		BetterLog(@"[DEBUG] result=%i",[fileManager fileExistsAtPath:topath]);
	}
}


// saves web loaded image to cache for later use
-(BOOL)storeImage:(UIImage*)image withName:(NSString*)filename ofType:(NSString*)type{
	
	[imageCacheDict setObject:image forKey:filename];
	
	return YES;
}


-(NSURL*)urlForImage:(NSString*)filename ofType:(NSString*)type{
	
	// creates url path to server file
	NSString *uniquefilename=[NSString stringWithFormat:@"%@_%@",filename,type];
	NSString *url=[NSString stringWithFormat:@"%@%@/%@",[self serverImagePath],type,uniquefilename];
	
	return [NSURL URLWithString:url];
	
}

// we need a method that does the store in dict but maintains the size of the cache
// ie store in cache (if not found) if cache is now too big purge some items til back under max Mb


-(NSString*)fileonDiskPath:(NSString*)filename ofType:(NSString*)type{
	return [NSString stringWithFormat:@"%@/%@",[self userImagePath],filename];
}


- (UIImage*)loadImageFromDocuments:(NSString*)path {
	NSData* data = [NSData dataWithContentsOfFile:path];
	return [UIImage imageWithData:data];
}


-(NSString*)userImagePath{
	
	if(cachePath==nil){
		NSArray* paths=NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
		NSString* docsdir=[paths objectAtIndex:0];
		self.cachePath=[docsdir stringByAppendingPathComponent:kIMAGECACHEIRECTORY];
	}
	
	return cachePath;
	
}

-(NSString*)serverImagePath{
	return @"";
}

-(BOOL)imageIsInCache:(NSString*)filename ofType:(NSString*)type{
	
	NSString *uniquefilename=[NSString stringWithFormat:@"%@_%@",filename,type];
	UIImage *image=[imageCacheDict objectForKey:uniquefilename];
	if(image==nil){
		return YES;
	}
	return NO;
	
}


-(BOOL)createCacheDirectory{
	
	NSFileManager* fileManager = [NSFileManager defaultManager];
	NSString *ipath=[self userImagePath];
	
	BOOL isDir=YES;
	
	if([fileManager fileExistsAtPath:ipath isDirectory:&isDir]){
		return YES;
	}else {
		
		if([fileManager createDirectoryAtPath:ipath withIntermediateDirectories:NO attributes:nil error:nil ]){
			return YES;
		}else{
			return NO;
		}
	}
	
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// NSNotifications

- (void)didReceiveMemoryWarning:(void*)object {
	// Empty the memory cache when memory is low
	[self removeAll];
}

- (void)removeAll {
	[imageCacheDict removeAllObjects];
	[cachedItems removeAllObjects];
	
}

//
/***********************************************
 * add keys of each item to cachearray, if exceeds max items, start removing images from memory cache
 * this is quite simple, could be improved by using bytes instead of count
 ***********************************************/
//
-(void)compactArray:(NSString*)filename{
	
	[cachedItems addObject:filename];
	
	// if exceeds max remove oldest item
	if([cachedItems count]>maxItems){
		NSString *item=[cachedItems objectAtIndex:0];
		[imageCacheDict removeObjectForKey:item];
		[cachedItems removeObjectAtIndex:0];
	}
	
}

//
/***********************************************
 * does periodic cached file removal to save disk space
 ***********************************************/
//
-(void)removeStaleFiles:(int)interval{
	
	NSFileManager *fm=[NSFileManager defaultManager];
	NSString	*imagecachepath=[self userImagePath];
	NSArray	*cacheFileArray=[ fm contentsOfDirectoryAtPath:imagecachepath error:nil];
	NSDate *now=[NSDate date];
	NSString *filepath;
	NSDictionary *fileInfo;
	NSDate *filedate;
	NSTimeInterval fileage;
	
	for(int i=0;i<[cacheFileArray count];i++){
		
		filepath=[imagecachepath stringByAppendingPathComponent:[cacheFileArray objectAtIndex:i]];
		fileInfo=[fm attributesOfItemAtPath:filepath error:nil];
		filedate=[fileInfo objectForKey:NSFileModificationDate];
		fileage=[now timeIntervalSinceDate:filedate];
		
		if (fileage>interval) {
			if([fm fileExistsAtPath:filepath]){
				[fm removeItemAtPath:filepath error:nil];
			}
		}
		
	}
	
}


-(void)removeImageByName:(NSString*)name withType:(NSString*)type{
	
	NSFileManager *fm=[NSFileManager defaultManager];
	NSString	*imagecachepath=[self userImagePath];
	NSString *filepath=[imagecachepath stringByAppendingPathComponent:[self fileonDiskPath:name ofType:type]];
	
	BOOL fileisonDisk = [fm fileExistsAtPath:filepath];
	
	if(fileisonDisk==YES){
		[fm removeItemAtPath:filepath error:nil];
	}
	
}



@end
