//
//  PhotoMapImageLocationViewController.h
//  CycleStreets
//
//  Created by Neil Edwards on 20/04/2011.
//  Copyright 2011 CycleStreets Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ExpandedUILabel.h"
#import "AsyncImageView.h"
#import "LayoutBox.h"
#import "PhotoMapVO.h"
#import "CopyLabel.h"
#import "SuperViewController.h"

@interface PhotoMapImageLocationViewController : SuperViewController <AsyncImageViewDelegate>{
	
	PhotoMapVO							*dataProvider;
	
	UINavigationBar						*navigationBar;
	UIScrollView						*scrollView;
	
	LayoutBox							*viewContainer;
	
	AsyncImageView						*imageView;
	ExpandedUILabel						*imageLabel;
	
	CopyLabel							*titleLabel;

}
@property (nonatomic, retain)	PhotoMapVO		*dataProvider;
@property (nonatomic, retain)	UINavigationBar		*navigationBar;
@property (nonatomic, retain)	UIScrollView		*scrollView;
@property (nonatomic, retain)	LayoutBox		*viewContainer;
@property (nonatomic, retain)	AsyncImageView		*imageView;
@property (nonatomic, retain)	ExpandedUILabel		*imageLabel;
@property (nonatomic, retain)	CopyLabel		*titleLabel;

- (void) loadContentForEntry:(PhotoMapVO *)photoEntry;

@end
