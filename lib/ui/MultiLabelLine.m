//
//  RKMultiLabelLine.m
//  RacingUK
//
//  Created by neil on 05/01/2010.
//  Copyright 2010 Chroma. All rights reserved.
//

#import "MultiLabelLine.h"
#import "GlobalUtilities.h"
#import "StyleManager.h"

@implementation MultiLabelLine
@synthesize labels;
@synthesize fonts;
@synthesize colors;
@synthesize showShadow;

/***********************************************************/
// dealloc
/***********************************************************/
- (void)dealloc
{
    [labels release], labels = nil;
    [fonts release], fonts = nil;
    [colors release], colors = nil;
	
    [super dealloc];
}



// Called when container is in IB
- (id)initWithCoder:(NSCoder*)decoder {
	if (self = [super initWithCoder:decoder]) {
		self.paddingLeft=0;
		self.horizontalGap=5;
    }
    return self;
}


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
		self.paddingLeft=0;
		self.horizontalGap=5;
    }
    return self;
}



-(void)drawUI{
	
	[self removeAllSubViews];
	
	for(int i=0;i<[labels count];i++){
		CGFloat twidth=[GlobalUtilities calculateWidthOfText:[labels objectAtIndex:i] :[fonts objectAtIndex:i]];
		UILabel *label=[[UILabel alloc]initWithFrame:CGRectMake(0, 0,  twidth, self.frame.size.height)];
		label.backgroundColor=[UIColor clearColor];
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
		label.text=[labels objectAtIndex:i];
		[self addSubview:label];
		[label release];
	}
	
}



@end
