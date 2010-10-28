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

//  CustomButtonView.m
//  CycleStreets
//
//  Created by Alan Paxton on 01/09/2010.
//

#import "CustomButtonView.h"
#import "Common.h"

@implementation CustomButtonView

@synthesize target;

- (id)initWithImage:(UIImage *)image target:(id)newTarget selector:(SEL)newSelector {
	if (self = [super initWithImage:image]) {
		DLog(@">>>");
		self.userInteractionEnabled = YES;
		self.target = newTarget;
		selector = newSelector;
	}
	return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	DLog(@">>>");
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	DLog(@">>>");
	[self.target performSelector:selector];
}

- (void)dealloc {
	self.target = nil;
	[super dealloc];
}

@end
