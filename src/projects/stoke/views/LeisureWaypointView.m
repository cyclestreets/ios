//
//  LeisureWaypointView.m
//  CycleStreets
//
//  Created by Neil Edwards on 27/10/2014.
//  Copyright (c) 2014 CycleStreets Ltd. All rights reserved.
//

#import "LeisureWaypointView.h"
#import "UIView+Additions.h"
#import "BUTouchView.h"
#import "GlobalUtilities.h"
#import "UIColor+AppColors.h"
#import "UIImage+Additions.h"

#import "WayPointVO.h"

@interface LeisureWaypointView()

@property (weak, nonatomic) IBOutlet UILabel		*intermediateLabel;
@property (weak, nonatomic) IBOutlet UIImageView	*iconImageView;
@property (weak, nonatomic) IBOutlet UIImageView	*tickIcon;
@property (weak, nonatomic) IBOutlet UIView			*touchView;

@end


@implementation LeisureWaypointView

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



-(void)didTapItem:(UITapGestureRecognizer*)gesture{
	
	if(_touchBlock)
		_touchBlock(@"",_dataProvider);
	
}


-(void)populate{
	
	switch (_dataProvider.waypointType) {
		case WayPointTypeStart:
			_iconImageView.image=[UIImage imageNamed:@"CSIcon_start_wisp.png"];
			_intermediateLabel.text=EMPTYSTRING;
			break;
		case WayPointTypeFinish:
			_iconImageView.image=[UIImage imageNamed:@"CSIcon_finish_wisp.png"];
			_intermediateLabel.text=EMPTYSTRING;
			break;
		case WayPointTypeIntermediate:
			_iconImageView.image=[UIImage imageNamed:@"CSIcon_intermediate_wisp.png"];
			_intermediateLabel.text=[NSString stringWithFormat:@"%i",1];
			break;
	}
	
	
}

@end
