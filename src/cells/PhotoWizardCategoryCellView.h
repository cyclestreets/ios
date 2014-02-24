//
//  PhotoWizardCategoryCellView.h
//  CycleStreets
//
//  Created by neil on 04/07/2012.
//  Copyright (c) 2012 CycleStreets Ltd. All rights reserved.
//

#import "BUTableCellView.h"
@class PhotoCategoryVO;

@interface PhotoWizardCategoryCellView : BUTableCellView{
	
	
}

@property (nonatomic, strong)	PhotoCategoryVO			*dataProvider;
@property (nonatomic, weak)	IBOutlet UILabel			*itemLabel;


@end
