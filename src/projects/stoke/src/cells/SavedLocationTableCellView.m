//
//  SavedLocationTableCellView.m
//  CycleStreets
//
//  Created by Neil Edwards on 14/10/2014.
//  Copyright (c) 2014 CycleStreets Ltd. All rights reserved.
//

#import "SavedLocationTableCellView.h"

#import "GenericConstants.h"
#import "SavedLocationVO.h"

@interface SavedLocationTableCellView()

@property (weak, nonatomic) IBOutlet UILabel            *titleLabel;
@property (strong, nonatomic) UIImageView        *locationTypeIcon;


@end

@implementation SavedLocationTableCellView



-(void)initialise{
	
	self.locationTypeIcon=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 22, 22)];
	_locationTypeIcon.backgroundColor=[UIColor clearColor];
	self.accessoryView=_locationTypeIcon;
}


-(void)populate{
	
    _titleLabel.text=_dataProvider.title;
    
	_locationTypeIcon.image=[UIImage imageNamed:[_dataProvider locationIcon]];
    
}



+(int)rowHeight{
	
	return STANDARDCELLHEIGHT;
	
}


+(NSNumber*)heightForCellWithDataProvider:(id)data{
	
	return @([SavedLocationTableCellView rowHeight]);
	
}

@end
