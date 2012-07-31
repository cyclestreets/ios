//
//  AsyncImageView.h
//
//
//  Created by Neil Edwards on 10/08/2009.
//  Copyright 2009 buffer. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kImageViewTAG 1000
#define kAsyncActivityTAG 1001

@protocol AsyncImageViewDelegate <NSObject>

@optional

-(void)asyncImageDidLoad;

@end

@interface AsyncImageView : UIView {
	
	NSURLConnection				*connection; //keep a reference to the connection so we can cancel download in dealloc
	NSMutableData				*data; //keep reference to the data so we can collect it as it downloads
	NSString					*filename;
	NSString					*type;
	NSUInteger					*capacity;
	BOOL						notify;
	UIImageView					*imageView;
	BOOL						cacheImage;
	BOOL						tmpCacheOnly;
	
	
	//testing only
	BOOL						useKitty;
	
	id<AsyncImageViewDelegate>		__unsafe_unretained delegate;
	
}
@property (nonatomic,strong) NSString				*filename;
@property (nonatomic,strong) NSString				*type;
@property (nonatomic) NSUInteger					*capacity;
@property (nonatomic,strong) UIImageView			*imageView;
@property (nonatomic) BOOL							notify;
@property(nonatomic,assign)BOOL cacheImage;
@property(nonatomic,assign)BOOL tmpCacheOnly;
@property (nonatomic) BOOL							useKitty;

@property (nonatomic, unsafe_unretained) id<AsyncImageViewDelegate> delegate;

- (void)loadImageFromURL:(NSURL*)url;
-(void)loadImageFromString:(NSString*)url;
-(void)addImageView:(UIImage*)image;
- (UIImage*) image;
-(void)addActivity;
-(void)removeActivity;
-(void)cancel;

- (void)connection:(NSURLConnection *)theConnection didFailWithError:(NSError *)error;


-(void)loadPlaceHolderImage;
@end
