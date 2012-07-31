//
//  BUBannerView.m
//  Sun NagMe
//
//  Created by Neil Edwards on 05/03/2012.
//  Copyright (c) 2012 Chroma. All rights reserved.
//

#import "BUBannerView.h"
#import "BannerManager.h"
#import "StringUtilities.h"

@implementation BUBannerView
@synthesize imageView;
@synthesize button;
@synthesize parentView;
@synthesize bannerType;
@synthesize initialFrame;
@synthesize isShown;
@synthesize isLoaded;




- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		self.initialFrame=frame;
        [self drawUI];
    }
    return self;
}



-(void)drawUI{
	
	AsyncImageView *iview=[[AsyncImageView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
	iview.cacheImage=YES;
	[self addSubview:iview];
	
	NSString *imageurl=[[BannerManager sharedInstance] imageURLForBannerType:bannerType];
	iview.filename=[StringUtilities fileNameFromURL:imageurl :@"/"];
	[iview loadImageFromString:imageurl];
	
	UIButton *bannerButton=[UIButton buttonWithType:UIButtonTypeCustom];
	bannerButton.frame=CGRectMake(0, 0, self.width, self.height);
	[bannerButton addTarget:self action:@selector(bannerButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:bannerButton];
	
	[parentView addSubview:self];
	
	
}


-(void)showBanner:(BOOL)show{
	
	if(show==YES){
		
		[UIView animateWithDuration:0.4f 
							  delay:0 
							options:UIViewAnimationCurveEaseOut 
						 animations:^{ 
							 CGRect footerframe=self.frame;
							 footerframe.origin.y=initialFrame.origin.y-self.height;
							 self.frame=footerframe;
						 }
						 completion:^(BOOL finished){
							 isShown=YES;
						 }];
		
		
	}else {
		[UIView animateWithDuration:0.7f 
							  delay:0 
							options:UIViewAnimationCurveEaseOut 
						 animations:^{ 
							 CGRect footerframe=self.frame;
							 footerframe.origin.y=initialFrame.origin.y;
							 self.frame=footerframe;
						 }
						 completion:^(BOOL finished){
							 isShown=NO;
						 }];
	}
	
	
}


-(IBAction)bannerButtonSelected:(id)sender{
	
	[[BannerManager sharedInstance] remoteBannerButtonSelected:bannerType];
	
}


@end
