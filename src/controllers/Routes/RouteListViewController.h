//
//  RouteListViewController.h
//  CycleStreets
//
//  Created by neil on 12/03/2011.
//  Copyright 2011 CycleStreets Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SuperViewController.h"

@interface RouteListViewController : SuperViewController {
	
}
@property (nonatomic, strong) NSMutableArray					* dataProvider;
@property (nonatomic, strong) NSDictionary						*configDict;



@end
