//
//  POICatLocationCellView.m
//  CycleStreets
//
//  Created by Neil Edwards on 21/10/2011.
//  Copyright (c) 2011 CycleStreets Ltd. All rights reserved.
//

#import "POICatLocationCellView.h"

@implementation POICatLocationCellView
@synthesize dataProvider;
@synthesize nameLabel;
@synthesize urlLabel;

//=========================================================== 
// dealloc
//=========================================================== 
- (void)dealloc
{
    [dataProvider release], dataProvider = nil;
    [nameLabel release], nameLabel = nil;
    [urlLabel release], urlLabel = nil;
	
    [super dealloc];
}


-(void)initialise{
	
	
	
	
}

-(void)populate{
	
	nameLabel.text=dataProvider.name;
	urlLabel.text=dataProvider.website;
	
}






+(int)rowHeight{
	return STANDARDCELLHEIGHT;
}

@end
