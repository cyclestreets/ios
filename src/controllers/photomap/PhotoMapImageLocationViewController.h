//
//  PhotoMapImageLocationViewController.h
//  CycleStreets
//
//  Created by Neil Edwards on 20/04/2011.
//  Copyright 2011 CycleStreets Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SuperViewController.h"

@class PhotoMapVO;

@interface PhotoMapImageLocationViewController : SuperViewController {

}
@property (nonatomic, strong)	PhotoMapVO		*dataProvider;


- (void) loadContentForEntry:(PhotoMapVO *)photoEntry;

@end
