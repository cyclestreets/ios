//
//  POICatLocationCellView.m
//  CycleStreets
//
//  Created by Neil Edwards on 21/10/2011.
//  Copyright (c) 2011 CycleStreets Ltd. All rights reserved.
//

#import "POICatLocationCellView.h"
#import "POILocationVO.h"

@interface POICatLocationCellView()

@property (nonatomic, strong)	IBOutlet UILabel		*nameLabel;
@property (nonatomic, strong)	IBOutlet UILabel		*urlLabel;

@end

@implementation POICatLocationCellView


-(void)initialise{
	
	
	
	
}

-(void)populate{
	
	_nameLabel.text=_dataProvider.name;
	_urlLabel.text=_dataProvider.website;
	
}






+(int)rowHeight{
	return STANDARDCELLHEIGHT;
}

@end
