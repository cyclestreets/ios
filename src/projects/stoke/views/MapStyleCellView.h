//
//  MapStyleCellView.h
//  CycleStreets
//
//  Created by Neil Edwards on 10/10/2014.
//  Copyright (c) 2014 CycleStreets Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BUHorizontalMenuView.h"
#import "GenericConstants.h"


@interface MapStyleCellView : UIView<BUHorizontalMenuItem>

@property (nonatomic,strong)  NSDictionary                      *dataProvider;

@property (nonatomic,copy)  GenericEventBlock                   touchBlock;


-(void)setSelected:(BOOL)selected;

@end
