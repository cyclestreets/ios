//
//  POITypeCellView.m
//  CycleStreets
//
//  Created by Neil Edwards on 20/10/2011.
//  Copyright (c) 2011 CycleStreets Ltd. All rights reserved.
//

#import "POITypeCellView.h"
#import "GlobalUtilities.h"
#import "ImageCache.h"

@interface POITypeCellView()

@property (nonatomic, weak)	IBOutlet UIImageView			*iconView;
@property (nonatomic, weak)	IBOutlet UILabel				*label;

@end

@implementation POITypeCellView
	
	
-(void)initialise{
	
	
	
}

-(void)populate{
	
	_iconView.image=[[ImageCache sharedInstance] imageExists:_dataProvider.imageName ofType:nil];
	_label.text=_dataProvider.name;
	
}






+(int)rowHeight{
	return STANDARDCELLHEIGHT;
}

@end
