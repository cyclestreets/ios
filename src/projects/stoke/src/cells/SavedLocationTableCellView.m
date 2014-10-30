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

#import "GlobalUtilities.h"
#import "UIImage+Additions.h"
#import "UIColor+AppColors.h"
#import "ViewUtilities.h"

@interface SavedLocationTableCellView()

@property (weak, nonatomic) IBOutlet UILabel						*titleLabel;
@property (strong, nonatomic) IBOutlet UIImageView					*locationTypeIcon;


@end

@implementation SavedLocationTableCellView



-(void)initialise{
	
}

-(void)layoutSubviews{
	
	[super layoutSubviews];
	
	[ViewUtilities alignView:_locationTypeIcon withView:self.contentView :BURightAlignMode :BUCenterAlignMode :10];
	
	
}

-(void)populate{
	
    _titleLabel.text=_dataProvider.title;
    
	_locationTypeIcon.image=[UIImage imageNamed:[_dataProvider locationIcon] tintColor:[UIColor appTintColor] style:UIImageTintedStyleKeepingAlpha];
    
}



+(int)rowHeight{
	
	return STANDARDCELLHEIGHT;
	
}


+(NSNumber*)heightForCellWithDataProvider:(id)data{
	
	return @([SavedLocationTableCellView rowHeight]);
	
}

@end
