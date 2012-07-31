//
//  PhotoWizardCategoryCellView.h
//  CycleStreets
//
//  Created by neil on 04/07/2012.
//  Copyright (c) 2012 CycleStreets Ltd. All rights reserved.
//

#import "BUTableCellView.h"
#import "PhotoCategoryVO.h"

@interface PhotoWizardCategoryCellView : BUTableCellView{
	
	
	IBOutlet		UILabel			*itemLabel;
	
	PhotoCategoryVO					*dataProvider;
	
}
@property (nonatomic, strong)	IBOutlet UILabel			*itemLabel;
@property (nonatomic, strong)	PhotoCategoryVO			*dataProvider;
@end
