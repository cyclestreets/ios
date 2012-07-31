//
//  ExpandableTextView.m
//  RacingUK
//
//  Created by neil on 31/01/2012.
//  Copyright (c) 2012 Chroma. All rights reserved.
//

#import "ExpandableTextView.h"

@interface ExpandableTextView(Private)

-(void)updateText;

@end

@implementation ExpandableTextView
@synthesize fixedWidth;

// Called when creating containe by code
- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		fixedWidth=NO;
		self.backgroundColor=[UIColor clearColor];
    }
    return self;
}

// Called when container is in IB
- (id)initWithCoder:(NSCoder*)decoder {
	if (self = [super initWithCoder:decoder]) {
		fixedWidth=NO;
		self.backgroundColor=[UIColor clearColor];
    }
    return self;
}



/***********************************************************/
//  override super setText so we can adjust the frame size to match the text 
/***********************************************************/

- (void)setText:(NSString *)aText
{
    if (super.text != aText) {
        [super setText:aText];
		[self updateText];
    }
}



-(void)updateText{
	CGRect tframe=self.frame;
	self.scrollEnabled=NO;
	CGFloat theight=[GlobalUtilities calculateHeightOfTextFromWidth:self.text :self.font :tframe.size.width-10 :UILineBreakModeWordWrap];
	tframe.size.height=theight;	
	self.frame=tframe;
}

@end
