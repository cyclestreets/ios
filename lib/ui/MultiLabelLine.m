//
//  MultiLabelLine.m
//
//
//  Created by neil on 05/01/2010.
//  Copyright 2010 Buffer. All rights reserved.
//

#import "MultiLabelLine.h"
#import "GlobalUtilities.h"
#import "StyleManager.h"
#import "ExpandedUILabel.h"
#import "AppConstants.h"

@implementation MultiLabelLine
@synthesize labels;
@synthesize fonts;
@synthesize colors;
@synthesize textAligns;
@synthesize showShadow;
@synthesize labelWidth;
@synthesize labelisFixedWidth;
@synthesize valueWidth;
@synthesize valueisFixedWidth;
@synthesize containerisFixedWidth;
@synthesize ignoreEmptyStrings;
@synthesize labelsAreColumns;
@synthesize useInitialFrameHeight;
@synthesize initWidth;
@synthesize initFrame;



// Called when container is in IB
- (id)initWithCoder:(NSCoder*)decoder {
	if (self = [super initWithCoder:decoder]) {
		[self initialise];
    }
    return self;
}


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
		[self initialise];
    }
    return self;
}


// override SetFrame so initFrame is kept in sync
- (void)setFrame:(CGRect)aFrame
{
	[super setFrame:aFrame];
    initFrame=aFrame;
}
 


-(void)initialise{
	
	containerisFixedWidth=NO;
	labelisFixedWidth=NO;
	valueisFixedWidth=NO;
	ignoreEmptyStrings=NO;
	labelsAreColumns=NO;
    initFrame=self.frame;
    initWidth=initFrame.size.width;
	useInitialFrameHeight=YES;
	
	self.layoutMode=BUHorizontalLayoutMode;
	self.alignMode=BUCenterAlignMode;
	self.paddingLeft=0;
	self.itemPadding=5;
		
}


-(void)drawUI{
	
	
	[self removeAllSubViews];
	if(useInitialFrameHeight==YES)
		[self setFrame:initFrame];
	
	if(labelsAreColumns==YES){
		self.alignMode=BUTopAlignMode;
	}
	
	for(int i=0;i<[labels count];i++){
		
		NSString *labelString=[labels objectAtIndex:i];
		BOOL	skipLabel=NO;
		
		if(ignoreEmptyStrings==YES){
			if([labelString isEqualToString:EMPTYSTRING]){
				skipLabel=YES;
			}
		}
		
		if(skipLabel==NO){
		
			CGFloat twidth=0;
			
			if(i==0){
				if(labelisFixedWidth==NO){
					twidth=[GlobalUtilities calculateWidthOfText:labelString :[fonts objectAtIndex:i]];
				}else {
					twidth=labelWidth;
				}
			}else {
				
				if(valueisFixedWidth==NO){
					twidth=[GlobalUtilities calculateWidthOfText:labelString :[fonts objectAtIndex:i]];
				}else {
					twidth=valueWidth;
				}
		
			}
			
			if(containerisFixedWidth==YES){
				twidth=MIN(twidth,initWidth);
			}

			ExpandedUILabel *label=[[ExpandedUILabel alloc]initWithFrame:CGRectMake(0, 0,  twidth, useInitialFrameHeight==YES ? initFrame.size.height : 10)];
			
			if(i==0 && labelisFixedWidth==YES){
				label.multiline=YES;
			}else {
				label.multiline=NO;
			}
			
			if(i==1 && valueisFixedWidth==YES){
				label.multiline=YES;
			}else {
				label.multiline=NO;
			}
			
			if(twidth>=initWidth){
				label.multiline=YES;
			}
			
			label.font=[fonts objectAtIndex:i];
			id color=[colors objectAtIndex:i];
			if([color isKindOfClass:[UIColor class]]){
				label.textColor=color;
			}else {
				label.textColor=[[StyleManager sharedInstance] colorForType:[colors objectAtIndex:i]];
			}
			label.highlightedTextColor=[UIColor whiteColor];
			if(showShadow==YES){
				label.shadowColor=[UIColor whiteColor];
				label.shadowOffset=CGSizeMake(0, 1);
			}
			
			if(textAligns!=nil){
				label.textAlignment=UNBOX_INT([textAligns objectAtIndex:i]);
			}
			
			label.text=labelString;
			[self addSubview:label];
			
		}
	}
	
	if(containerisFixedWidth==YES){
		if(width>initWidth){
			self.layoutMode=BUVerticalLayoutMode;
			self.alignMode=BULeftAlignMode;
			itemPadding=0;
			[self refresh];
		}
	}
	
	
}



@end
