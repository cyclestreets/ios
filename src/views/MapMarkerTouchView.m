//
//  MapMarketTouchView.m
//  CycleStreets
//
//  Created by Neil Edwards on 22/08/2012.
//  Copyright (c) 2012 CycleStreets Ltd. All rights reserved.
//

#import "MapMarkerTouchView.h"

@implementation MapMarkerTouchView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	[self setNeedsDisplay];
	[self.nextResponder touchesEnded:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	[self setNeedsDisplay];
	[self.nextResponder touchesMoved:touches withEvent:event];
}

@end
