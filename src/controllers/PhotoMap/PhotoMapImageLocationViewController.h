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

}


- (void) loadContentForEntry:(PhotoMapVO *)photoEntry;

@end
