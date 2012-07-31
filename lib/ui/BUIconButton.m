//
//  BUIconButton.m
//  RacingUK
//
//  Created by Neil Edwards on 17/11/2011.
//  Copyright (c) 2011 Chroma. All rights reserved.
//

#import "BUIconButton.h"
#import "ButtonUtilities.h"
#import "StyleManager.h"

@implementation BUIconButton
@synthesize index;
@synthesize button;
@synthesize buttonIconImage;
@synthesize buttonBackgroundImage;
@synthesize text;
@synthesize label;
@synthesize textColor;
@synthesize labelFont;
@synthesize labelFitsIcon;
@synthesize maxLabelWidth;
@synthesize buttonSize;



- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		layoutMode=BUVerticalLayoutMode;
		alignMode=BUCenterAlignMode;
		maxLabelWidth=0;
		itemPadding=5;
		buttonSize=CGSizeMake(0, 0);
    }
    return self;
}


-(void)drawUI{
	
	if(buttonSize.width==0){
		UIImage *buttonimage=[[StyleManager sharedInstance] imageForType:[NSString stringWithFormat:@"UIButton_%@_lo",buttonBackgroundImage]];
		buttonSize=buttonimage.size;
	}
	
	self.button=[ButtonUtilities UIIconButton:buttonBackgroundImage iconImage:buttonIconImage height:buttonSize.height width:buttonSize.width midLeftCap:YES midTopCap:YES];
	[self addSubview:button];
	
	
	int lwidth=self.frame.size.width;
	if(labelFitsIcon==YES){
		maxLabelWidth=lwidth;
	}else{
		if(maxLabelWidth==0){
			maxLabelWidth=lwidth*1.2; // abitary slight overlap
		}
	}
	
	
	self.label=[[ExpandedUILabel alloc]initWithFrame:CGRectMake(0, 0, maxLabelWidth, 10)];
	label.textAlignment=UITextAlignmentCenter;
	label.fixedWidth=YES;
	
	if(labelFont!=nil){
		label.font=labelFont;
	}else{
		label.font=[UIFont boldSystemFontOfSize:12];
	}
	
	if(textColor!=nil){
		label.textColor=[UIColor whiteColor];
	}else{
		label.textColor=[[StyleManager sharedInstance] colorForType:textColor];
	}
	
	label.text=text;
	[self addSubview:label];
	 
	
}



@end
