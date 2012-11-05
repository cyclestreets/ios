//
//  WayPointCellView.m
//  CycleStreets
//
//  Created by Neil Edwards on 05/11/2012.
//  Copyright (c) 2012 CycleStreets Ltd. All rights reserved.
//

#import "WayPointCellView.h"
#import "GlobalUtilities.h"
#import "UIView+Additions.h"

@interface WayPointCellView()

@property (unsafe_unretained, nonatomic) IBOutlet UIImageView		*iconImageView;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel			*nameLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel			*locationLabel;


@end



@implementation WayPointCellView



-(void)initialise{
	
	self.contentView.backgroundColor=UIColorFromRGB(0xe2e0dc);
	
	
}



-(void)populate{
	
	
	_nameLabel.text=_dataProvider.name;
	
	// location string
	
	// icon based on waypointIndex
	
	if(_waypointIndex==0){
		_iconImageView.image=[UIImage imageNamed:@"CSIcon_start_wisp.png"];
	}else{
		if(_waypointIndex%2==0){
			_iconImageView.image=[UIImage imageNamed:@"CSIcon_finish_wisp.png"];
		}else{
			_iconImageView.image=[UIImage imageNamed:@"CSIcon_intermediate_wisp.png"];
		}
	}
	
}



+(int)rowHeight{
	return STANDARDCELLHEIGHT;
}


@end
