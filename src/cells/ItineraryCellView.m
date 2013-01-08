//
//  ItineraryCellView.m
//  CycleStreets
//
//  Created by Neil Edwards on 09/03/2011.
//  Copyright 2011 CycleStreets Ltd. All rights reserved.
//

#import "ItineraryCellView.h"
#import "AppConstants.h"
#import "ViewUtilities.h"
#import "SegmentVO.h"

@implementation ItineraryCellView
@synthesize dataProvider;
@synthesize viewContainer;
@synthesize nameLabel;
@synthesize readoutLabel;
@synthesize icon;


-(void)initialise{
	
	viewContainer.layoutMode=BUVerticalLayoutMode;
	viewContainer.paddingLeft=0;
	viewContainer.paddingTop=7;
	viewContainer.paddingBottom=7;
	viewContainer.itemPadding=0;
	[viewContainer initFromNIB];
	
	NSMutableArray *fonts=[NSMutableArray arrayWithObjects:[UIFont boldSystemFontOfSize:13],[UIFont systemFontOfSize:13],[UIFont systemFontOfSize:13],nil];
	NSMutableArray *colors=[NSMutableArray arrayWithObjects:UIColorFromRGB(0xFF8000),UIColorFromRGB(0x007F00),UIColorFromRGB(0x404040),nil];
	
	readoutLabel.fonts=fonts;
	readoutLabel.colors=colors;



}

-(void)populate{
	
	nameLabel.text=[dataProvider roadName];
	
	NSMutableArray *arr=[[NSMutableArray alloc] init];
	
	[arr addObject:[dataProvider timeString]];
	[arr addObject:[NSString stringWithFormat:@"%4dm", [dataProvider segmentDistance]]];
	
	float totalMiles = ((float)([dataProvider startDistance]+[dataProvider segmentDistance]))/1600;
	[arr addObject:[NSString stringWithFormat:@"(%3.1f miles)", totalMiles]];
	
	icon.image=[UIImage imageNamed:dataProvider.provisionIcon];
	
	readoutLabel.labels=arr;
	[readoutLabel drawUI];
	
	[viewContainer refresh];
	
	[ViewUtilities alignView:icon withView:viewContainer :BUNoneLayoutMode :BUCenterAlignMode];

}



+(NSNumber*)heightForCellWithDataProvider:(SegmentVO*)segment{
	
	int height=7;
	
	height+=[GlobalUtilities calculateHeightOfTextFromWidth:[segment roadName] :[UIFont boldSystemFontOfSize:16]   :248 :UILineBreakModeWordWrap];
	height+=5;
	height+=[GlobalUtilities calculateHeightOfTextFromWidth:[segment timeString] :[UIFont systemFontOfSize:13] :248 :UILineBreakModeClip];
	height+=7;
	
	return [NSNumber numberWithInt:height];
}




+(int)rowHeight{
	return STANDARDCELLHEIGHT;
}


@end
