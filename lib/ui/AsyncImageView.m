//
//  AsyncImageView.m
//  RacingUK
//
//  Created by Neil Edwards on 10/08/2009.
//  Copyright 2009 buffer. All rights reserved.
//

#import "AsyncImageView.h"
#import "ImageCache.h"
#import "GlobalUtilities.h"
#import "ViewUtilities.h"
#import "StringUtilities.h"

#define NSHTTPPropertyStatusCodeKey @"Image404Error"

@implementation AsyncImageView
@synthesize filename;
@synthesize type;
@synthesize capacity;
@synthesize notify;
@synthesize imageView;
@synthesize cacheImage;
@synthesize resizeToFit;
@synthesize delegate;


- (void)dealloc {
	
	[self removeActivity];
	[connection cancel];
	[connection release], connection=nil;
	[data release],data=nil; 
	[filename release],filename=nil;
	[type release],type=nil;
	imageView=nil;
	delegate=nil;
	
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame 
{
    if (self = [super initWithFrame:frame]) 
    {
        notify=NO;  
		cacheImage=YES;
		type=@"image";
    }
    return self;
}



-(void)loadImageFromString:(NSString*)urlString{
	
	
	NSURL *url=[StringUtilities validateURL:urlString];
	if(url!=nil){
		[self loadImageFromURL:url];
	}else {
		[self cancel];
	}

	
}



-(void)cancel{
	
	[connection cancel];
	
	imageView.image=nil;
	
	if (data!=nil) { 
		[data release]; 
		data=nil;
	}
	
	[self removeActivity];
	
}


- (void)loadImageFromURL:(NSURL*)url {
	
	if(cacheImage==YES){
		[self cancel];
		UIImage	 *image=[[ImageCache sharedInstance] imageExists:filename ofType:type];
		if(image!=nil){
			[self addImageView:image];
			return;
		}
	}else {
		[self cancel];
	}

	
	
	NSURLRequest* request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
	connection = [[NSURLConnection alloc] initWithRequest:request delegate:self]; 
	
	[self addActivity];
}


-(void)addActivity{
	
	[self removeActivity];
	
	UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	CGRect aframe=CGRectMake(0, 0, 20, 20);
	activity.frame=aframe;
	[ViewUtilities alignView:activity withView:self :BUCenterAlignMode :BUCenterAlignMode];
	activity.tag=kAsyncActivityTAG;
	[activity startAnimating];
	[self addSubview:activity];
	[activity release];
}

-(void)removeActivity{
	
	UIActivityIndicatorView* activity = (UIActivityIndicatorView *)[self viewWithTag:kAsyncActivityTAG];
	if(activity!=nil){
		[activity stopAnimating];
		[activity removeFromSuperview];
		activity=nil;
	}
}

// catches any 404 errors and calls didFailWithError, otherwise connectionDidFinishLoading will execute with the erorr page as the data
- (void)connection:(NSURLConnection *)theConnection didReceiveResponse:(NSURLResponse *)response{

	if ([response respondsToSelector:@selector(statusCode)])
	{
		int statusCode = [((NSHTTPURLResponse *)response) statusCode];
		if (statusCode >= 400)
		{
			[connection cancel];  // stop connecting; no more delegate messages
			NSDictionary *errorInfo
			= [NSDictionary dictionaryWithObject:[NSString stringWithFormat:
												  NSLocalizedString(@"Server returned status code %d",@""),
												  statusCode]
										  forKey:NSLocalizedDescriptionKey];
			NSError *statusError
			= [NSError errorWithDomain:NSHTTPPropertyStatusCodeKey
								  code:statusCode
							  userInfo:errorInfo];
			[self connection:connection didFailWithError:statusError];
		}
	}
	
}



- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)incrementalData {
	if (data==nil) { data = [[NSMutableData alloc] initWithCapacity:2048]; } 
	[data appendData:incrementalData];
}

- (void)connection:(NSURLConnection *)theConnection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite{
	// for progress indicating
}

- (void)connection:(NSURLConnection *)theConnection didFailWithError:(NSError *)error
{
	
	[connection cancel];
	[connection release]; 
	connection=nil;
	[self removeActivity];
	
	// should we add error icon
	
}


- (void)connectionDidFinishLoading:(NSURLConnection*)theConnection {
	
	//BetterLog(@" cacheImage=%i for filename=%@",cacheImage,filename);
	
	[connection release];
	connection=nil;
	
	UIImage *image=[UIImage imageWithData:data];
	
	if(cacheImage==YES){
		//NSLog(@"[DEBUG] cacheing loaded image for %@",filename);
		[[ImageCache sharedInstance] saveImageToDisk:image withName:filename ofType:type];
	}
	
	if(notify==YES){
		
		NSDictionary *dict=[[NSDictionary alloc] initWithObjectsAndKeys:image,@"image",nil];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"AsyncImageLoaded" object: nil userInfo:dict ];
		[dict release];
		
	}else{
		[self addImageView:image];
	}
	
	[self removeActivity];
	
	[data release]; 
	data=nil;
	
	
}


-(void)addImageView:(UIImage*)image{
	
	if(imageView==nil){
		imageView = [[UIImageView alloc] init];
		imageView.contentMode = UIViewContentModeScaleAspectFit;
		imageView.autoresizingMask = ( UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight );
		imageView.tag=kImageViewTAG;
		[self addSubview:imageView];
		[imageView release];
	}
	
	imageView.image=image;
	if(resizeToFit==YES){
		CGRect iframe=imageView.frame;
		iframe.size.height=image.size.height;
		imageView.frame=iframe;
	}else {
		imageView.frame = self.bounds;
	}

	
	[imageView setNeedsLayout];
	[self setNeedsLayout];
	
}


- (UIImage*) image {
	UIImageView* iv = (UIImageView *)[self viewWithTag:kImageViewTAG];
	return [iv image];
}

@end
