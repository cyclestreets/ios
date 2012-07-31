//
//  ImageCache.h
//Explorer
//
//  Created by Neil Edwards on 13/07/2009.
//  Copyright 2009 buffer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SynthesizeSingleton.h"

#define	kIMAGECACHEIRECTORY @"imagecache"

@interface ImageCache : NSObject {
	NSMutableDictionary *imageCacheDict;
	int					maxItems;
	NSMutableArray		*cachedItems;
	
	NSString			*cachePath;
	
}
@property (nonatomic, strong) NSMutableDictionary		* imageCacheDict;
@property (nonatomic, assign) int		 maxItems;
@property (nonatomic, strong) NSMutableArray		* cachedItems;
@property (nonatomic, strong) NSString		* cachePath;

SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(ImageCache);

-(UIImage*)imageExists:(NSString*)filename ofType:(NSString*)type;
-(BOOL)saveImageToDisk:(UIImage*)image withName:(NSString*)filename ofType:(NSString*)type;
-(BOOL)saveTmpImageToDisk:(UIImage*)image withName:(NSString*)filename ofType:(NSString*)type;
-(BOOL)storeImage:(UIImage*)image withName:(NSString*)filename ofType:(NSString*)type;
-(NSString*)fileonDiskPath:(NSString*)filename ofType:(NSString*)type;
-(NSURL*)urlForImage:(NSString*)filename ofType:(NSString*)type;
- (UIImage*)loadImageFromDocuments:(NSString*)path;
-(NSString*)userImagePath;
-(NSString*)serverImagePath;
-(NSString*)tmpImagePath;
-(BOOL)imageIsInCache:(NSString*)filename ofType:(NSString*)type;
- (void)removeAll;

-(void)removeStaleFiles:(int)interval;
-(void)removeImageByName:(NSString*)name withType:(NSString*)type;
-(void)moveTmpImageToCache:(NSString*)filename;
@end
