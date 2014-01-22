/** Cycle Atlanta, Copyright 2012, 2013 Georgia Institute of Technology
 *                                    Atlanta, GA. USA
 *
 *   @author Christopher Le Dantec <ledantec@gatech.edu>
 *   @author Anhong Guo <guoanhong@gatech.edu>
 *
 *   Updated/Modified for Atlanta's app deployment. Based on the
 *   CycleTracks codebase for SFCTA.
 *
 ** CycleTracks, Copyright 2009,2010 San Francisco County Transportation Authority
 *                                    San Francisco, CA, USA
 *
 *   @author Matt Paul <mattpaul@mopimp.com>
 *
 *   This file is part of CycleTracks.
 *
 *   CycleTracks is free software: you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as published by
 *   the Free Software Foundation, either version 3 of the License, or
 *   (at your option) any later version.
 *
 *   CycleTracks is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details.
 *
 *   You should have received a copy of the GNU General Public License
 *   along with CycleTracks.  If not, see <http://www.gnu.org/licenses/>.
 */

//
//  CustomView.m
//  CycleTracks
//
//  Copyright 2009-2010 SFCTA. All rights reserved.
//  Written by Matt Paul <mattpaul@mopimp.com> on 9/22/09.
//	For more information on the project, 
//	e-mail Billy Charlton at the SFCTA <billy.charlton@sfcta.org>

#import "CustomView.h"

@implementation CustomView

@synthesize title, image;

const CGFloat kViewWidth = 200;
const CGFloat kViewHeight = 44;

+ (CGFloat)viewWidth
{
    return kViewWidth;
}

+ (CGFloat)viewHeight 
{
    return kViewHeight;
}

- (id)initWithFrame:(CGRect)frame
{
	// use predetermined frame size
	if (self = [super initWithFrame:CGRectMake(0.0, 0.0, kViewWidth, kViewHeight)])
	{
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		self.backgroundColor = [UIColor clearColor];	// make the background transparent
	}
	return self;
}

- (void)drawRect:(CGRect)rect
{
	// draw the image and title using their draw methods
	CGFloat yCoord = (self.bounds.size.height - self.image.size.height) / 2;
	CGPoint point = CGPointMake(10.0, yCoord);
	[self.image drawAtPoint:point];
	
	yCoord = (self.bounds.size.height - MAIN_FONT_SIZE) / 2;
	point = CGPointMake(10.0 + self.image.size.width + 10.0, yCoord);
	[self.title drawAtPoint:point
					forWidth:self.bounds.size.width
					withFont:[UIFont systemFontOfSize:MAIN_FONT_SIZE]
					minFontSize:MIN_MAIN_FONT_SIZE
					actualFontSize:NULL
					lineBreakMode:UILineBreakModeTailTruncation
					baselineAdjustment:UIBaselineAdjustmentAlignBaselines];
}



@end
