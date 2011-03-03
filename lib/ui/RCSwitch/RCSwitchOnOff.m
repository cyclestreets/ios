/*
 Copyright (c) 2010 Robert Chin
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

#import "RCSwitchOnOff.h"


@implementation RCSwitchOnOff

- (void)initCommon
{
	[super initCommon];
	onText = [UILabel new];
	onText.text = NSLocalizedString(@"ON", @"Switch localized string");
	onText.textColor = [UIColor whiteColor];
	onText.font = [UIFont boldSystemFontOfSize:17];
	onText.shadowColor = [UIColor colorWithWhite:0.175 alpha:1.0];
	
	offText = [UILabel new];
	offText.text = NSLocalizedString(@"OFF", @"Switch localized string");
	offText.textColor = [UIColor grayColor];
	offText.font = [UIFont boldSystemFontOfSize:17];	
}

- (void)dealloc
{
	[onText release];
	[offText release];
	[super dealloc];
}

- (void)drawUnderlayersInRect:(CGRect)aRect withOffset:(float)offset inTrackWidth:(float)trackWidth
{
	{
		CGRect textRect = aRect;
		textRect.origin.x += 14.0 + (offset - trackWidth);
		[onText drawTextInRect:textRect];	
	}
	
	{
		CGRect textRect = aRect;
		textRect.origin.x += (offset + trackWidth);
		[offText drawTextInRect:textRect];
	}	
}

@end
