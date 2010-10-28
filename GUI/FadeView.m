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

//  FadeView.m
//  CycleStreets
//
//  Created by Alan Paxton on 07/06/2010.
//

#import "FadeView.h"

@implementation FadeView

@synthesize animatedSubview;

- (void)animateSubviewAway:(UIView *)view subview:(UIView *)subview {
	if (subview == nil || view == nil) return;
	self.animatedSubview = subview;
	[view addSubview:subview];
	[view bringSubviewToFront:subview];
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:2.0];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
	self.animatedSubview.alpha = 0.0;
	[UIView commitAnimations];
}

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	[self.animatedSubview removeFromSuperview];
}

-(void)dealloc {
	self.animatedSubview = nil;
	
	[super dealloc];
}

@end
