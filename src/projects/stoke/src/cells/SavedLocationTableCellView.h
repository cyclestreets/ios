//
//  SavedLocationTableCellView.h
//  CycleStreets
//
//  Created by Neil Edwards on 14/10/2014.
//  Copyright (c) 2014 CycleStreets Ltd. All rights reserved.
//

#import "BUTableCellView.h"

@class SavedLocationVO;

@interface SavedLocationTableCellView : BUTableCellView

@property (nonatomic,strong)  SavedLocationVO							*dataProvider;

@end
