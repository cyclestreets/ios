//
//  AsyncImageView.m
//
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
@synthesize	tmpCacheOnly;
@synthesize	useKitty;
@synthesize delegate;

- (void)dealloc {
	
delegate=nil;
	[self removeActivity];
	
}

- (id)initWithFrame:(CGRect)frame 
{
    if (self = [super initWithFrame:frame]) 
    {
        notify=NO;  
		useKitty=NO;
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
		if(useKitty==NO){
			[self cancel];
		}else{
			[self loadPlaceHolderImage];
		}
		
	}

	
}



-(void)cancel{
	
	[connection cancel];
	
	imageView.image=nil;
	
	if (data!=nil) { 
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
		NSInteger statusCode = [((NSHTTPURLResponse *)response) statusCode];
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
	connection=nil;
	[self removeActivity];
	
	if(useKitty==YES){
		[self loadPlaceHolderImage];
	}
}


- (void)connectionDidFinishLoading:(NSURLConnection*)theConnection {
	
	//BetterLog(@" cacheImage=%i for filename=%@",cacheImage,filename);
	
	connection=nil;
	
	UIImage *image=[UIImage imageWithData:data];
	
	if(cacheImage==YES){
		//NSLog(@"[DEBUG] cacheing loaded image for %@",filename);
		if(tmpCacheOnly==YES){
			[[ImageCache sharedInstance] saveTmpImageToDisk:image withName:filename ofType:type];
		}else {
			[[ImageCache sharedInstance] saveImageToDisk:image withName:filename ofType:type];
		}
		
		
	}
	
	if(notify==YES){
		
		NSDictionary *dict=[[NSDictionary alloc] initWithObjectsAndKeys:image,@"image",nil];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"AsyncImageLoaded" object: nil userInfo:dict ];
		
	}else{
		[self addImageView:image];
	}
	
	[self removeActivity];
	
	data=nil;
	
	
}


-(void)loadPlaceHolderImage{
	
	self.filename=[StringUtilities stringWithUUID];
	self.type=@"placeholder";
	
	NSString *errorURL=[NSString stringWithFormat:@"http://placekitten.com/%i/%i",(int)self.frame.size.width,(int)self.frame.size.height];
	[self loadImageFromString:errorURL];
}


-(void)addImageView:(UIImage*)image{
	
	if(imageView==nil){
		imageView = [[UIImageView alloc] init];
		imageView.contentMode = UIViewContentModeScaleAspectFit;
		imageView.autoresizingMask = ( UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight );
		imageView.tag=kImageViewTAG;
		[self addSubview:imageView];
	}
	
	imageView.image=image;
	imageView.frame = self.bounds;
	[imageView setNeedsLayout];
	[self setNeedsLayout];
	
}


- (UIImage*) image {
	UIImageView* iv = (UIImageView *)[self viewWithTag:kImageViewTAG];
	return [iv image];
}

@end
