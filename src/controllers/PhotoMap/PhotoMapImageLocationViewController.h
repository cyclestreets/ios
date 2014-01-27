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

}
@property (nonatomic, strong)	PhotoMapVO		*dataProvider;


- (void) loadContentForEntry:(PhotoMapVO *)photoEntry;

@end
