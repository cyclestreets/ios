//
//  POITypeCellView.m
//  CycleStreets
//
//  Created by Neil Edwards on 20/10/2011.
//  Copyright (c) 2011 CycleStreets Ltd. All rights reserved.
//

#import "POITypeCellView.h"

@implementation POITypeCellView
@synthesize imageView;
@synthesize label;
@synthesize totallabel;
@synthesize dataProvider;

//=========================================================== 
// dealloc
//=========================================================== 
- (void)dealloc
{
    [imageView release], imageView = nil;
    [label release], label = nil;
    [totallabel release], totallabel = nil;
    [dataProvider release], dataProvider = nil;
	
    [super dealloc];
}


	
	
-(void)initialise{
	
	
	
	
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
