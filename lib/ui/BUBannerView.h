//
//  BUBannerView.h
//  Sun NagMe
//
//  Created by Neil Edwards on 05/03/2012.
//  Copyright (c) 2012 Chroma. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"

@interface BUBannerView : UIView{
	
	AsyncImageView			*imageView;
	UIButton				*button;
	
	UIView					*parentView;
	
	NSString				*bannerType;
	
	
	CGRect					initialFrame;
	
	BOOL					isShown;
	BOOL					isLoaded;
	
}
@property (nonatomic, strong) AsyncImageView		* imageView;
@property (nonatomic, strong) UIButton		* button;
@property (nonatomic, strong) UIView		* parentView;
@property (nonatomic, strong) NSString		* bannerType;
@property (nonatomic, assign) CGRect		 initialFrame;
@property (nonatomic, assign) BOOL		 isShown;
@property (nonatomic, assign) BOOL		 isLoaded;

-(void)drawUI;
@end
