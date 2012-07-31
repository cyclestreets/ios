//
//  PhotoWizardCategoryCellView.m
//  CycleStreets
//
//  Created by neil on 04/07/2012.
//  Copyright (c) 2012 CycleStreets Ltd. All rights reserved.
//

#import "PhotoWizardCategoryCellView.h"
#import "GlobalUtilities.h"

@implementation PhotoWizardCategoryCellView
@synthesize itemLabel;
@synthesize dataProvider;



-(void)initialise{
	
	self.backgroundView.backgroundColor=UIColorFromRGB(0xDADADA);
	
}



-(void)populate{
	
	itemLabel.text=dataProvider.name;
	
	
}



+(int)rowHeight{
	return SHORTCELLHEIGHT;
}

@end
