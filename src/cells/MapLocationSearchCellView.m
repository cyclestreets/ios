//
//  MapLocationSearchCellView.m
//  CycleStreets
//
//  Created by Gaby Jones on 11/06/2012.
//  Copyright (c) 2012 CycleStreets Ltd. All rights reserved.
//

#import "MapLocationSearchCellView.h"

@implementation MapLocationSearchCellView
@synthesize dataProvider;
@synthesize titleLabel;
@synthesize nearLabel;
@synthesize distanceLabel;



-(void)initialise{
	
}


-(void)populate{
	
	
	titleLabel.text=dataProvider.name;
	nearLabel.text=dataProvider.near;
	distanceLabel.text=dataProvider.distanceString;
	
	
}


+(int)rowHeight{
	return 44;
}

@end
