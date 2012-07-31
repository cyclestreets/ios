//
//  EditableTextView.m
//
//
//  Created by Neil Edwards on 10/12/2010.
//  Copyright 2010 buffer. All rights reserved.
//

#import "EditableTextView.h"
#import "GlobalUtilities.h"
#import "AppConstants.h"


@implementation EditableTextView
@synthesize disableLineDrawing;



- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
		self.contentMode=UIViewContentModeTop;
		self.contentStretch=CGRectMake(0, 0, SCREENWIDTH, frame.size.height);
		disableLineDrawing=NO;
		
    }
    return self;
}


// Draw lined background
-(void)drawRect:(CGRect)rect { 
	
	[super drawRect:rect];
	
	if(disableLineDrawing==NO){
		// Get the graphics context 
		CGContextRef ctx = UIGraphicsGetCurrentContext();
		
		// Get the height of a single text line 
		NSString *alpha = @"ABCD"; 
		CGSize textSize = [alpha sizeWithFont:self.font constrainedToSize:self.contentSize lineBreakMode:UILineBreakModeWordWrap]; 
		NSUInteger height = textSize.height;
		// Get the height of the view or contents of the view whichever is bigger 
		//textSize = [self.text sizeWithFont:self.font constrainedToSize:self.contentSize lineBreakMode:UILineBreakModeWordWrap];
		//NSUInteger contentHeight = (rect.size.height > textSize.height) ? (NSUInteger)rect.size.height : textSize.height;
		NSUInteger contentHeight = rect.size.height;
		NSUInteger offset = 6 + height; // MAGIC Number 6 to offset from 0 to get first line OK ??? 
		contentHeight += offset; 
		
		// Draw ruled lines 
		CGContextSetRGBStrokeColor(ctx, .8, .8, .8, 1); 
		for(int i=offset;i < contentHeight;i+=height) { 
			CGPoint lpoints[2] = { CGPointMake(0, i), CGPointMake(rect.size.width, i) }; 
			CGContextStrokeLineSegments(ctx, lpoints, 2); 
		} 
	}
}

 

@end
