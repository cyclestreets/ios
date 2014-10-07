//
//  PhotoWizardCategoryCellView.m
//  CycleStreets
//
//  Created by neil on 04/07/2012.
//  Copyright (c) 2012 CycleStreets Ltd. All rights reserved.
//

#import "PhotoWizardCategoryCellView.h"
#import "GlobalUtilities.h"
#import "PhotoCategoryVO.h"

@interface PhotoWizardCategoryCellView()


@end

@implementation PhotoWizardCategoryCellView


-(void)initialise{
	
	self.backgroundView.backgroundColor=UIColorFromRGB(0xDADADA);
}



-(void)populate{
	
	_itemLabel.text=_dataProvider.name;
	
	
}



+(int)rowHeight{
	return SHORTCELLHEIGHT;
}

@end
