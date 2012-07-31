//
//  ExpandedUILabel.m
// CycleStreets
//
//  Created by Neil Edwards on 25/11/2010.
//  Copyright 2010 buffer. All rights reserved.
//

#import "ExpandedUILabel.h"
#import "GlobalUtilities.h"

@interface ExpandedUILabel(Private)
-(void)updateText;

@end


@implementation ExpandedUILabel
@synthesize multiline;
@synthesize fixedWidth;
@synthesize insetValue;
@synthesize labelColor;
@synthesize hasShadow;

//=========================================================== 
// dealloc
//=========================================================== 
- (void)dealloc
{
    labelColor = nil;
	
}




// Called when creating containe by code
- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		multiline=YES;
		fixedWidth=NO;
		insetValue=0;
		self.backgroundColor=[UIColor clearColor];
    }
    return self;
}

// Called when container is in IB
- (id)initWithCoder:(NSCoder*)decoder {
	if (self = [super initWithCoder:decoder]) {
		multiline=YES;
		fixedWidth=NO;
		insetValue=0;
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
    
    if(hasShadow==YES){
		self.shadowColor=[UIColor whiteColor];
		self.shadowOffset=CGSizeMake(0, 1);
	}
}




-(void)updateText{
	if(multiline==YES){
		self.numberOfLines=0;
		CGRect tframe=self.frame;
		CGFloat theight=[GlobalUtilities calculateHeightOfTextFromWidth:self.text :self.font :tframe.size.width :UILineBreakModeWordWrap];
		tframe.size.height=theight;
		self.frame=tframe;
	}else {
		self.numberOfLines=1;
		CGRect tframe=self.frame;
		CGFloat twidth=[GlobalUtilities calculateWidthOfText:self.text :self.font];
		if(fixedWidth==NO){
			CGFloat theight=[GlobalUtilities calculateHeightOfTextFromWidth:self.text :self.font :twidth :UILineBreakModeWordWrap];
			tframe.size.height=MAX(theight,tframe.size.height);			
		}else {
			self.lineBreakMode=UILineBreakModeTailTruncation;
			twidth=MIN(twidth,tframe.size.width);
		}
		if(insetValue>0)
			twidth=twidth+insetValue*2;
		
		tframe.size.width=twidth;
		self.frame=tframe;
	}

}


@end
