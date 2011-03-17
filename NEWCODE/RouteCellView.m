//
//  RouteCellView.m
//  CycleStreets
//
//  Created by neil on 17/03/2011.
//  Copyright 2011 CycleStreets Ltd. All rights reserved.
//

#import "RouteCellView.h"
#import "AppConstants.h"

@implementation RouteCellView
@synthesize dataProvider;

//=========================================================== 
// dealloc
//=========================================================== 
- (void)dealloc
{
    [dataProvider release], dataProvider = nil;
	
    [super dealloc];
}



-(void)initialise{
	
	
}


-(void)populate{
	
	
	
	
}



+(int)rowHeight{
	return STANDARDCELLHEIGHT;
}

+(NSString*)cellIdentifier{
	return @"RouteCellIdentifier";
}


@end
