//
//  HCSSavedTrackCellView.h
//  CycleStreets
//
//  Created by Neil Edwards on 23/01/2014.
//  Copyright (c) 2014 CycleStreets Ltd. All rights reserved.
//

#import "BUTableCellView.h"
@class Trip;

@interface HCSSavedTrackCellView : BUTableCellView

@property (nonatomic,strong) Trip          *dataProvider;


@end
