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

@interface PhotoMapImageLocationViewController : UIViewController <AsyncImageViewDelegate>{
	
	PhotoMapVO							*dataProvider;
	
	UINavigationBar						*navigationBar;
	UIScrollView						*scrollView;
	
	LayoutBox							*viewContainer;
	
	AsyncImageView						*imageView;
	ExpandedUILabel						*imageLabel;

}
@property (nonatomic, retain)		PhotoMapVO		* dataProvider;
@property (nonatomic, retain)		IBOutlet UINavigationBar		* navigationBar;
@property (nonatomic, retain)		IBOutlet UIScrollView		* scrollView;
@property (nonatomic, retain)		LayoutBox		* viewContainer;
@property (nonatomic, retain)		AsyncImageView		* imageView;
@property (nonatomic, retain)		ExpandedUILabel		* imageLabel;

- (void) loadContentForEntry:(PhotoMapVO *)photoEntry;

@end
