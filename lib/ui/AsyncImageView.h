//
//  AsyncImageView.h
//  RacingUK
//
//  Created by Neil Edwards on 10/08/2009.
//  Copyright 2009 buffer. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AsyncImageViewDelegate <NSObject>

@optional
-(void)ImageDidLoadWithImage:(UIImage*)image;
-(void)ImageDidFail;


@end



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
	
	BOOL						resizeToFit;
	
	// delegate
	id<AsyncImageViewDelegate> delegate;
	
}
@property (nonatomic, retain)		NSString		* filename;
@property (nonatomic, retain)		NSString		* type;
@property (nonatomic)		NSUInteger		* capacity;
@property (nonatomic)		BOOL		 notify;
@property (nonatomic, retain)		IBOutlet UIImageView		* imageView;
@property (nonatomic)		BOOL		 cacheImage;
@property (nonatomic)		BOOL		 resizeToFit;
@property (nonatomic, assign)		id<AsyncImageViewDelegate>		 delegate;

- (void)loadImageFromURL:(NSURL*)url;
-(void)loadImageFromString:(NSString*)url;
-(void)addImageView:(UIImage*)image;
- (UIImage*) image;
-(void)addActivity;
-(void)removeActivity;
-(void)cancel;
@end
