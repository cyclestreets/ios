//
//  ItinerarayHeaderView.m
//  CycleStreets
//
//  Created by Neil Edwards on 07/12/2012.
//  Copyright (c) 2012 CycleStreets Ltd. All rights reserved.
//

#import "ItinerarayHeaderView.h"
#import "UIView+Additions.h"
#import "ItineraryInfoContainer.h"

@interface ItinerarayHeaderView()


@property(nonatomic,strong)  ItineraryInfoContainer					*infoContainer;
@property(nonatomic,strong)  ItineraryInfoContainer					*infoContainer;


@end

@implementation ItinerarayHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialise];
    }
    return self;
}


-(void)initialise{
	
	// create header items
	
}



-(void)itemSelected:(int)index{
	
	// is it open or closed
	
	
	// tell item to add its child view
	
	// update
	
	
	// tell parent view to update table height
	
}




@end
