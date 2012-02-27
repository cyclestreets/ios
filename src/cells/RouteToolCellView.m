//
//  RouteToolCellView.m
//  CycleStreets
//
//  Created by Neil Edwards on 27/02/2012.
//  Copyright (c) 2012 CycleStreets Ltd. All rights reserved.
//

#import "RouteToolCellView.h"
#import "ViewUtilities.h"

@implementation RouteToolCellView



-(void)initialise{
	
	self.contentView.backgroundColor=UIColorFromRGB(0x444444);
	
	[ViewUtilities drawUIViewInsetShadow:self.contentView];
	
	
}

@end
