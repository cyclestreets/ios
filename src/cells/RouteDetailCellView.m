//
//  RouteDetailCellView.m
//  CycleStreets
//
//  Created by Neil Edwards on 01/02/2013.
//  Copyright (c) 2013 CycleStreets Ltd. All rights reserved.
//

#import "RouteDetailCellView.h"
#import "GlobalUtilities.h"


@implementation RouteDetailCellView



-(void)initialise{
	
	
	UIView *bgview=[[UIView alloc]initWithFrame:self.frame];
	bgview.backgroundColor=UIColorFromRGB(0xe2e0dc);
	self.backgroundView=bgview;
}


-(void)populate{
	
	
}



+(int)rowHeight{
	return 70;
}



@end
