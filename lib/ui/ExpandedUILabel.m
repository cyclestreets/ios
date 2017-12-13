//
//  ExpandedUILabel.m
// CycleStreets
//
//  Created by Neil Edwards on 25/11/2010.
//  Copyright 2010 buffer. All rights reserved.
//

#import "ExpandedUILabel.h"
#import "GlobalUtilities.h"

@interface ExpandedUILabel()

@end


@implementation ExpandedUILabel


//=========================================================== 
// dealloc
//=========================================================== 
- (void)dealloc
{
	_labelColor = nil;
	
}




// Called when creating containe by code
- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		_insetValue=0;
		self.backgroundColor=[UIColor clearColor];
    }
    return self;
}

// Called when container is in IB
- (id)initWithCoder:(NSCoder*)decoder {
	if (self = [super initWithCoder:decoder]) {
		_insetValue=0;
		self.backgroundColor=[UIColor clearColor];
    }
    return self;
}



/***********************************************************/
//  override super setText so we can adjust the frame size to match the text 
/***********************************************************/

- (void)setText:(NSString *)aText
{
	if(_insetValue>0){
		self.textInsets=UIEdgeInsetsMake(_insetValue, _insetValue, _insetValue, _insetValue);
	}
	
	
    if (super.text != aText) {
        [super setText:aText];
    }
	
}


- (void)setTextInsets:(UIEdgeInsets)textInsets
{
	_textInsets = textInsets;
	[self invalidateIntrinsicContentSize];
}

- (CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines
{
	UIEdgeInsets insets = self.textInsets;
	CGRect rect = [super textRectForBounds:UIEdgeInsetsInsetRect(bounds, insets)
					limitedToNumberOfLines:numberOfLines];

	rect.origin.x    -= insets.left;
	rect.origin.y    -= insets.top;
	rect.size.width  += (insets.left + insets.right);
	rect.size.height += (insets.top + insets.bottom);

	return rect;
}

- (void)drawTextInRect:(CGRect)rect
{
	[super drawTextInRect:UIEdgeInsetsInsetRect(rect, self.textInsets)];
}



@end
