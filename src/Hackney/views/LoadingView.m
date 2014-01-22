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
//  LoadingView.m
//  LoadingView
//
//  Created by Matt Gallagher on 12/04/09.
//  Copyright Matt Gallagher 2009. All rights reserved.
// 
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//

#import "LoadingView.h"
#import <QuartzCore/QuartzCore.h>

#define DEFAULT_LABEL_WIDTH		200.
#define DEFAULT_LABEL_HEIGHT	80.

//
// NewPathWithRoundRect
//
// Creates a CGPathRect with a round rect of the given radius.
//
CGPathRef NewPathWithRoundRect(CGRect rect, CGFloat cornerRadius)
{
	//
	// Create the boundary path
	//
	CGMutablePathRef path = CGPathCreateMutable();
	CGPathMoveToPoint(path, NULL,
		rect.origin.x,
		rect.origin.y + rect.size.height - cornerRadius);

	// Top left corner
	CGPathAddArcToPoint(path, NULL,
		rect.origin.x,
		rect.origin.y,
		rect.origin.x + rect.size.width,
		rect.origin.y,
		cornerRadius);

	// Top right corner
	CGPathAddArcToPoint(path, NULL,
		rect.origin.x + rect.size.width,
		rect.origin.y,
		rect.origin.x + rect.size.width,
		rect.origin.y + rect.size.height,
		cornerRadius);

	// Bottom right corner
	CGPathAddArcToPoint(path, NULL,
		rect.origin.x + rect.size.width,
		rect.origin.y + rect.size.height,
		rect.origin.x,
		rect.origin.y + rect.size.height,
		cornerRadius);

	// Bottom left corner
	CGPathAddArcToPoint(path, NULL,
		rect.origin.x,
		rect.origin.y + rect.size.height,
		rect.origin.x,
		rect.origin.y,
		cornerRadius);

	// Close the path at the rounded rect
	CGPathCloseSubpath(path);
	
	return path;
}

@implementation LoadingView

@synthesize loadingLabel, activityIndicatorView;
//
// loadingViewInView:
//
// Constructor for this view. Creates and adds a loading view for covering the
// provided aSuperview.
//
// Parameters:
//    aSuperview - the superview that will be covered by the loading view
//
// returns the constructed view, already added as a subview of the aSuperview
//	(and hence retained by the superview)
//
+ (id)loadingViewInView:(UIView *)aSuperview messageString:(NSString *)message
{
    if (message==NULL)
        NSLocalizedString(@"Loading...", nil);
    
	// LoadingView *loadingView = [[[LoadingView alloc] initWithFrame:[aSuperview bounds]] autorelease];
	CGRect frame    = CGRectMake(floor(0.5 * (320 - DEFAULT_LABEL_WIDTH)),
								 floor(0.5 * ([[UIScreen mainScreen] bounds].size.height - DEFAULT_LABEL_HEIGHT)), 
								 DEFAULT_LABEL_WIDTH, DEFAULT_LABEL_HEIGHT);
	LoadingView *loadingView = [[LoadingView alloc] initWithFrame:frame];
	
	if (!loadingView)
	{
		return nil;
	}
	
	loadingView.opaque = NO;
	loadingView.autoresizingMask =
		UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[aSuperview addSubview:loadingView];

	/*
	const CGFloat DEFAULT_LABEL_WIDTH = 280.0;
	const CGFloat DEFAULT_LABEL_HEIGHT = 50.0;
	 */ //[lblText setFrame:CGRectMake(10, 21, 100, 250)];
	CGRect labelFrame = CGRectMake(0, 0, DEFAULT_LABEL_WIDTH, 35.);
	loadingView.loadingLabel =
		[[UILabel alloc]
		 initWithFrame:labelFrame];
	loadingView.loadingLabel.text = message;
	loadingView.loadingLabel.textColor = [UIColor whiteColor];
    loadingView.loadingLabel.numberOfLines = 3;
    loadingView.loadingLabel.lineBreakMode = UILineBreakModeWordWrap;
	loadingView.loadingLabel.backgroundColor = [UIColor clearColor];
	loadingView.loadingLabel.textAlignment = UITextAlignmentCenter;
	loadingView.loadingLabel.font = [UIFont boldSystemFontOfSize:[UIFont labelFontSize]];
	loadingView.loadingLabel.autoresizingMask =
		UIViewAutoresizingFlexibleLeftMargin |
		UIViewAutoresizingFlexibleRightMargin |
		UIViewAutoresizingFlexibleTopMargin |
		UIViewAutoresizingFlexibleBottomMargin;
	
	[loadingView addSubview:loadingView.loadingLabel];
	loadingView.activityIndicatorView = [[UIActivityIndicatorView alloc]
										 initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	CGRect activityIndicatorRect = loadingView.activityIndicatorView.frame;
    loadingView.activityIndicatorView.hidesWhenStopped = YES;
	activityIndicatorRect.origin.x = 0.5 * (loadingView.frame.size.width - activityIndicatorRect.size.width);
	activityIndicatorRect.origin.y = loadingView.loadingLabel.frame.origin.y + loadingView.loadingLabel.frame.size.height + 10.;
	loadingView.activityIndicatorView.frame = activityIndicatorRect;	
	
	loadingView.activityIndicatorView.autoresizingMask =
		UIViewAutoresizingFlexibleLeftMargin |
		UIViewAutoresizingFlexibleRightMargin |
		UIViewAutoresizingFlexibleTopMargin |
		UIViewAutoresizingFlexibleBottomMargin;
	
	[loadingView.activityIndicatorView startAnimating];
	[loadingView addSubview:loadingView.activityIndicatorView];
	
	CGFloat totalHeight = loadingView.loadingLabel.frame.size.height + loadingView.activityIndicatorView.frame.size.height;
	labelFrame.origin.x = floor(0.5 * (loadingView.frame.size.width - DEFAULT_LABEL_WIDTH));
	labelFrame.origin.y = floor(0.5 * (loadingView.frame.size.height - totalHeight));
	loadingView.loadingLabel.frame = labelFrame;
	
	// Set up the fade-in animation
	CATransition *animation = [CATransition animation];
	[animation setType:kCATransitionFade];
	[[aSuperview layer] addAnimation:animation forKey:@"layerAnimation"];
	
	return loadingView;
}

//
// changes the message to 'completeMessage' and removes the view after a delay.
//
//
- (void)loadingComplete:(NSString *)completeMessage delayInterval:(NSTimeInterval)delay
{
    self.loadingLabel.text=completeMessage;
    
//    CGFloat totalHeight = self.loadingLabel.frame.size.height;
//    CGRect labelFrame = CGRectMake(0, 0, DEFAULT_LABEL_WIDTH, 35.);
//	labelFrame.origin.x = floor(0.5 * (self.frame.size.width - DEFAULT_LABEL_WIDTH));
//	labelFrame.origin.y = floor(0.5 * (self.frame.size.height - totalHeight));
    
    CGSize maxLabelSize = CGSizeMake(DEFAULT_LABEL_WIDTH, 400);
    CGSize labelSize = [self.loadingLabel.text sizeWithFont:self.loadingLabel.font constrainedToSize:maxLabelSize lineBreakMode:self.loadingLabel.lineBreakMode];
    
    CGRect newFrame = self.loadingLabel.frame;
    newFrame.size.height = labelSize.height;
    
    CGFloat totalHeight = newFrame.size.height;
    newFrame.origin.x = floor(0.5 * (self.frame.size.width - DEFAULT_LABEL_WIDTH));
    newFrame.origin.y = floor(0.5 * (self.frame.size.height - totalHeight));
    
    self.loadingLabel.frame = newFrame;
	
//    self.loadingLabel.frame = labelFrame;
    [self.activityIndicatorView stopAnimating];

    [self performSelector:@selector(removeView) withObject:nil afterDelay:delay];
}
//
// removeView
//
// Animates the view out from the superview. As the view is removed from the
// superview, it will be released.
//
- (void)removeView
{
	UIView *aSuperview = [self superview];
	[super removeFromSuperview];

	// Set up the animation
	CATransition *animation = [CATransition animation];
	[animation setType:kCATransitionFade];
	
	[[aSuperview layer] addAnimation:animation forKey:@"layerAnimation"];
}

//
// drawRect:
//
// Draw the view.
//
- (void)drawRect:(CGRect)rect
{
	rect.size.height -= 1;
	rect.size.width -= 1;
	
	const CGFloat RECT_PADDING = 0.;
	rect = CGRectInset(rect, RECT_PADDING, RECT_PADDING);
	
	const CGFloat ROUND_RECT_CORNER_RADIUS = 10;
	rect.origin.x = rect.origin.x + (rect.size.width - 200) / 2;
	rect.origin.y = rect.origin.y + (rect.size.height - 80) / 2;
	rect.size.width = 200;
	rect.size.height = 80;
	
	//const CGFloat ROUND_RECT_CORNER_RADIUS = 5.0;
	CGPathRef roundRectPath = NewPathWithRoundRect(rect, ROUND_RECT_CORNER_RADIUS);
	
	CGContextRef context = UIGraphicsGetCurrentContext();

	const CGFloat BACKGROUND_OPACITY = 0.5;
	CGContextSetRGBFillColor(context, 0, 0, 0, BACKGROUND_OPACITY);
	CGContextAddPath(context, roundRectPath);
	CGContextFillPath(context);

	const CGFloat STROKE_OPACITY = 0.25;
	CGContextSetRGBStrokeColor(context, 1, 1, 1, STROKE_OPACITY);
	CGContextAddPath(context, roundRectPath);
	CGContextStrokePath(context);
	
	CGPathRelease(roundRectPath);
}

//
// dealloc
//
// Release instance memory.
//
- (void)dealloc
{
    self.loadingLabel = nil;
    self.activityIndicatorView = nil;
    
}

@end
