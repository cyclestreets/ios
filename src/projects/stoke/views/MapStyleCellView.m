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

@interface MapStyleCellView()

@property (weak, nonatomic) IBOutlet ExpandedUILabel			*titleLabel;
@property (weak, nonatomic) IBOutlet ExpandedUILabel			*descriptionLabel;
@property (weak, nonatomic) IBOutlet UIImageView				*thumbnailView;

@property (nonatomic,strong) IBOutlet  UIView					*touchView;

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
		self.backgroundColor=UIColorFromRGB(0xDDDDDD);
	}else{
		self.backgroundColor=[UIColor clearColor];
	}
	
}


-(void)awakeFromNib{
	
	
	UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapItem:)];
	tapGesture.numberOfTapsRequired=1;
	[_touchView addGestureRecognizer:tapGesture];
	
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
