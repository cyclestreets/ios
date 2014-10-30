//
//  MapStyleCellView.m
//  CycleStreets
//
//  Created by Neil Edwards on 10/10/2014.
//  Copyright (c) 2014 CycleStreets Ltd. All rights reserved.
//

#import "MapStyleCellView.h"
#import "ExpandedUILabel.h"
#import "BUTouchView.h"
#import "GlobalUtilities.h"
#import "UIView+Additions.h"
#import "UIColor+AppColors.h"
#import "UIImage+Additions.h"

@interface MapStyleCellView()

@property (weak, nonatomic) IBOutlet ExpandedUILabel			*titleLabel;
@property (weak, nonatomic) IBOutlet ExpandedUILabel			*descriptionLabel;
@property (weak, nonatomic) IBOutlet UIImageView				*thumbnailView;

@property (nonatomic,strong) IBOutlet  UIView					*touchView;
@property (weak, nonatomic) IBOutlet UIImageView *tickIcon;

@end

@implementation MapStyleCellView


- (instancetype)initWithCoder:(NSCoder *)coder
{
	self = [super initWithCoder:coder];
	if (self) {
		
	}
	return self;
}


-(void)setSelected:(BOOL)selected{
	
	if(selected){
		self.backgroundColor=UIColorFromRGB(0xDAD8D3);
	}else{
		self.backgroundColor=[UIColor clearColor];
	}
	
	_tickIcon.visible=selected;
	
}


-(void)awakeFromNib{
	
	
	UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapItem:)];
	tapGesture.numberOfTapsRequired=1;
	[_touchView addGestureRecognizer:tapGesture];
	
	UIImage *tickImage=[UIImage imageNamed:@"CSIcon_mapstyle_tick" tintColor:[UIColor appTintColor] style:UIImageTintedStyleKeepingAlpha];
	_tickIcon.image=tickImage;
	_tickIcon.visible=NO;
	
}


-(void)setDataProvider:(NSDictionary*)data{
	
	if(_dataProvider!=data){
		_dataProvider=data;
		
		[self populate];
		
	}
	
}
									   
-(void)didTapItem:(UITapGestureRecognizer*)gesture{
	
	if(_touchBlock)
		_touchBlock(@"",_dataProvider);
	
}


-(void)populate{
	
	_titleLabel.text=_dataProvider[@"title"];
	_descriptionLabel.text=_dataProvider[@"description"];
	
	[_thumbnailView setImage:[UIImage imageNamed:_dataProvider[@"thumbnailimage"]]];
	
    
}




@end
