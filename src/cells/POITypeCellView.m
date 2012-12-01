//
//  POITypeCellView.m
//  CycleStreets
//
//  Created by Neil Edwards on 20/10/2011.
//  Copyright (c) 2011 CycleStreets Ltd. All rights reserved.
//

#import "POITypeCellView.h"
#import "GlobalUtilities.h"

@implementation POITypeCellView
@synthesize imageView;
@synthesize label;
@synthesize totallabel;
@synthesize dataProvider;
	
	
-(void)initialise{
	
	self.contentView.backgroundColor=UIColorFromRGB(0xe2e0dc);
	
	
}

-(void)populate{
	
	imageView.image=dataProvider.icon;
	label.text=dataProvider.name;
	totallabel.text=[NSString stringWithFormat:@"%i entries",dataProvider.total];
	
}






+(int)rowHeight{
	return STANDARDCELLHEIGHT;
}

@end
