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
#import "BUIconActionSheet.h"
#import <MessageUI/MessageUI.h>
#import <Twitter/Twitter.h>

@interface PhotoMapImageLocationViewController : SuperViewController <AsyncImageViewDelegate,BUIconActionSheetDelegate,MFMailComposeViewControllerDelegate,MFMessageComposeViewControllerDelegate>{
	
	PhotoMapVO							*dataProvider;
	
	UINavigationBar						*navigationBar;
	UIScrollView						*scrollView;
	
	
	LayoutBox							*viewContainer;
	
	AsyncImageView						*imageView;
	ExpandedUILabel						*imageLabel;
	
	CopyLabel							*titleLabel;

}
@property (nonatomic, strong)	PhotoMapVO		*dataProvider;
@property (nonatomic, strong)	UINavigationBar		*navigationBar;
@property (nonatomic, strong)	UIScrollView		*scrollView;
@property (nonatomic, strong)	LayoutBox		*viewContainer;
@property (nonatomic, strong)	AsyncImageView		*imageView;
@property (nonatomic, strong)	ExpandedUILabel		*imageLabel;
@property (nonatomic, strong)	CopyLabel		*titleLabel;

- (void) loadContentForEntry:(PhotoMapVO *)photoEntry;

@end
