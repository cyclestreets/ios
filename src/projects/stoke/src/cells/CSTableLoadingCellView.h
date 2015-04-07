//
//  CSTableLoadingCellView.h
//  CycleStreets
//
//  Created by Neil Edwards on 07/04/2015.
//  Copyright (c) 2015 CycleStreets Ltd. All rights reserved.
//

#import "BUTableCellView.h"

@interface CSTableLoadingCellView : BUTableCellView


-(void)updateLoadingText:(NSString*)str;

-(void)updateLoading:(BOOL)loading;

@end
