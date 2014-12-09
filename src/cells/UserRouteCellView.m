//
//  UserRouteCellView.m
//  CycleStreets
//
//  Created by Neil Edwards on 09/12/2014.
//  Copyright (c) 2014 CycleStreets Ltd. All rights reserved.
//

#import "UserRouteCellView.h"
#import "AppConstants.h"
#import "UIView+Additions.h"
#import "CSUserRouteVO.h"

@interface UserRouteCellView()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@end

@implementation UserRouteCellView



-(void)initialise{
	
	
}



-(void)populate{
	
    _nameLabel.text=_dataProvider.name;
    _dateLabel.text=_dataProvider.dateString;
	
}



+(int)rowHeight{
	return 55;
}




@end
