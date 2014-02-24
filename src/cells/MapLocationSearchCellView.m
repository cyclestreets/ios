//
//  MapLocationSearchCellView.m
//  CycleStreets
//
//  Created by Gaby Jones on 11/06/2012.
//  Copyright (c) 2012 CycleStreets Ltd. All rights reserved.
//

#import "MapLocationSearchCellView.h"
#import "NamedPlace.h"

@interface MapLocationSearchCellView()

@property (nonatomic, weak) IBOutlet UILabel		* titleLabel;
@property (nonatomic, weak) IBOutlet UILabel		* nearLabel;
@property (nonatomic, weak) IBOutlet UILabel		* distanceLabel;

@end

@implementation MapLocationSearchCellView


-(void)initialise{
	
}


-(void)populate{
	
	
	_titleLabel.text=_dataProvider.name;
	_nearLabel.text=_dataProvider.near;
	_distanceLabel.text=_dataProvider.distanceString;
	
	
}


+(int)rowHeight{
	return 44;
}

@end
