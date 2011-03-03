//
//  AsyncImageView.h
//  RacingUK
//
//  Created by Neil Edwards on 10/08/2009.
//  Copyright 2009 buffer. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kImageViewTAG 1000
#define kAsyncActivityTAG 1001
@interface AsyncImageView : UIView {
	
	NSURLConnection				*connection; //keep a reference to the connection so we can cancel download in dealloc
	NSMutableData				*data; //keep reference to the data so we can collect it as it downloads
	NSString					*filename;
	NSString					*type;
	NSUInteger					*capacity;
	BOOL						notify;
	UIImageView					*imageView;
	BOOL						cacheImage;
}
@property (nonatomic,retain) NSString				*filename;
@property (nonatomic,retain) NSString				*type;
@property (nonatomic) NSUInteger					*capacity;
@property (nonatomic,retain) UIImageView			*imageView;
@property (nonatomic) BOOL							notify;
@property(nonatomic,assign)BOOL cacheImage;

- (void)loadImageFromURL:(NSURL*)url;
-(void)loadImageFromString:(NSString*)url;
-(void)addImageView:(UIImage*)image;
- (UIImage*) image;
-(void)addActivity;
-(void)removeActivity;
-(void)cancel;
@end
