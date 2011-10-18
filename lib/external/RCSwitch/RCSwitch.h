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

#import <UIKit/UIKit.h>


@interface RCSwitch : UIControl {
	UIImage *knobImage;
	UIImage *knobImagePressed;
	
	UIImage *sliderOff;
	UIImage *sliderOn;
	
	UIImage *buttonEndTrack;
	UIImage *buttonEndTrackPressed;
	
	float percent, oldPercent;
	float knobWidth;
	float endcapWidth;
	CGPoint startPoint;
	float scale;
	
	CGSize lastBoundsSize;
	
	NSDate *endDate;
	BOOL mustFlip;
}

/* Common initialization method for initWithFrame: and initWithCoder: */
- (void)initCommon;

/* Override to regenerate anything you need when the view changes sizes */
- (void)regenerateImages;

/* Override to draw your own custom text or graphics in the track */
- (void)drawUnderlayersInRect:(CGRect)aRect withOffset:(float)offset inTrackWidth:(float)trackWidth;
@property(readwrite,assign) float knobWidth;

- (void)setOn:(BOOL)aBool animated:(BOOL)animated;
@property(readwrite,assign,getter=isOn) BOOL on;

- (void)setEnabled:(BOOL)aBool;
@property(nonatomic,getter=isEnabled) BOOL enabled;

@end
