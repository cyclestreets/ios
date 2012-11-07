//
//  WayPointViewController.h
//  CycleStreets
//
//  Created by Neil Edwards on 31/10/2012.
//  Copyright (c) 2012 CycleStreets Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SuperViewController.h"
#import "IIViewDeckController.h"

@interface WayPointViewController : SuperViewController<UITableViewDataSource,UITableViewDelegate,IIViewDeckControllerDelegate>

@property(nonatomic,strong)  NSMutableArray         *dataProvider;


@end
