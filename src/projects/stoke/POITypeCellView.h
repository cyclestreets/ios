//
//  POITypeCellView.h
//  CycleStreets
//
//  Created by Neil Edwards on 20/10/2011.
//  Copyright (c) 2011 CycleStreets Ltd. All rights reserved.
//

#import "BUTableCellView.h"
#import "POICategoryVO.h"

@interface POITypeCellView : BUTableCellView


@property (nonatomic, strong)	POICategoryVO					*dataProvider;

@end
