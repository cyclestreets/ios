/*

Copyright (C) 2010  CycleStreets Ltd

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

*/

//  BlueCircleView.m
//  CycleStreets
//
//  Created by Alan Paxton on 24/05/2010.
//

#import "BlueCircleView.h"


@implementation BlueCircleView

@synthesize locationProvider;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {

	CGContextRef ctx = UIGraphicsGetCurrentContext();
	
	double radius = [locationProvider getRadius];
	CGContextSetLineWidth( ctx, radius);
	CGContextSetStrokeColorWithColor(ctx, [UIColor colorWithRed:0.2 green:0.2 blue:1.0 alpha:0.75].CGColor);
	CGContextAddArc( ctx,
					[locationProvider getX],
					[locationProvider getY],
					radius * 1.5,
					0,
					2*3.142,
					0);
	CGContextStrokePath(ctx);
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	[self setNeedsDisplay];
	[self.nextResponder touchesEnded:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	[self setNeedsDisplay];
	[self.nextResponder touchesMoved:touches withEvent:event];
}

- (void)dealloc {
	self.locationProvider = nil;
	
    [super dealloc];
}

@end
