//
//  POITypeCellView.m
//  CycleStreets
//
//  Created by Neil Edwards on 20/10/2011.
//  Copyright (c) 2011 CycleStreets Ltd. All rights reserved.
//

#import "POITypeCellView.h"
#import "POICategoryVO.h"

@interface POITypeCellView()

@property (nonatomic, weak)	IBOutlet UIImageView    * imageView;
@property (nonatomic, weak)	IBOutlet UILabel        * label;
@property (nonatomic, weak)	IBOutlet UILabel        * totallabel;

@end

@implementation POITypeCellView

	
-(void)initialise{
	
	
	
	
}

-(void)populate{
	
	self.imageView.image=_dataProvider.icon;
	_label.text=_dataProvider.name;
	_totallabel.text=[NSString stringWithFormat:@"%i entries",_dataProvider.total];
	
}






+(int)rowHeight{
	return STANDARDCELLHEIGHT;
}

@end
