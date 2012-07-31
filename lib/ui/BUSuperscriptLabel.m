//
// SuperscriptLabel.m
//
//
//  Created by Neil Edwards on 06/01/2010.
//  Copyright 2010 Buffer. All rights reserved.
//
// produces a Superscript label ie m²

#import "BUSuperscriptLabel.h"
#import "GlobalUtilities.h"
#import "ViewUtilities.h"
#import "StyleManager.h"
#import "UIView+Additions.h"

@implementation BUSuperscriptLabel
@synthesize labelText;
@synthesize superscriptText;
@synthesize labeltextColor;
@synthesize superscripttextColor;
@synthesize labelFont;
@synthesize shadowColor;
@synthesize mainLabel;
@synthesize superscriptLabel;
@synthesize shadowOffset;
@synthesize centerValueLabel;


-(void)populate{
	
    mainLabel.textColor=[[StyleManager sharedInstance] colorForType:labeltextColor];
	mainLabel.text=labelText;
    superscriptLabel.textColor=[[StyleManager sharedInstance] colorForType:superscripttextColor];
	superscriptLabel.text=superscriptText;
	
	if(centerValueLabel==YES){
		// adjust leftpadding so mainlabel is visually centered
		int pl=(self.width-mainLabel.width)/2;
		self.paddingLeft=pl;
	}else{
		int pl=(self.width-(mainLabel.width+superscriptLabel.width))/2;
		self.paddingLeft=pl;
	}
	
	[self refresh];
}


-(void)setup{
	
	
	self.mainLabel=[[ExpandedUILabel alloc]initWithFrame:CGRectMake(0, 0, 10, 10)];
    mainLabel.multiline=NO;
	mainLabel.font=labelFont;
	mainLabel.shadowOffset=shadowOffset;
	mainLabel.shadowColor=shadowColor;
	mainLabel.textColor=[[StyleManager sharedInstance] colorForType:labeltextColor];
	mainLabel.highlightedTextColor=[UIColor whiteColor];
	[self addSubview:mainLabel];
	
	
	CGFloat superscriptSize=labelFont.pointSize*.5;
	self.superscriptLabel=[[ExpandedUILabel alloc]initWithFrame:CGRectMake(0, 0, 10, 10)];
    superscriptLabel.multiline=NO;
	superscriptLabel.shadowOffset=shadowOffset;
	superscriptLabel.shadowColor=shadowColor;
	superscriptLabel.font=[UIFont systemFontOfSize:superscriptSize];
	superscriptLabel.textColor=[[StyleManager sharedInstance] colorForType:superscripttextColor];
	superscriptLabel.highlightedTextColor=[UIColor whiteColor];
	[self addSubview:superscriptLabel];
	
}


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
		
		self.itemPadding=0;
		self.fixedWidth=YES;
		self.fixedHeight=YES;
		self.alignMode=BUTopAlignMode;
		
		shadowColor=nil;
		shadowOffset=CGSizeMake(0, -1);
		
		centerValueLabel=YES;
    }
    return self;
}

- (id)initWithCoder:(NSCoder*)decoder {
	if (self = [super initWithCoder:decoder]) {
		
		self.itemPadding=0;
		self.fixedWidth=YES;
		self.fixedHeight=YES;
		self.alignMode=BUTopAlignMode;
		
		shadowColor=nil;
		shadowOffset=CGSizeMake(0, -1);
		
		centerValueLabel=YES;
		
    }
    return self;
}



@end
