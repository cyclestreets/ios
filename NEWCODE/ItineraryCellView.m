//
//  ItineraryCellView.m
//  CycleStreets
//
//  Created by Neil Edwards on 09/03/2011.
//  Copyright 2011 CycleStreets Ltd. All rights reserved.
//

#import "ItineraryCellView.h"
#import "AppConstants.h"

@implementation ItineraryCellView
@synthesize dataProvider;
@synthesize viewContainer;
@synthesize nameLabel;
@synthesize readoutLabel;
@synthesize icon;

/***********************************************************/
// dealloc
/***********************************************************/
- (void)dealloc
{
    [dataProvider release], dataProvider = nil;
    [viewContainer release], viewContainer = nil;
    [nameLabel release], nameLabel = nil;
    [readoutLabel release], readoutLabel = nil;
    [icon release], icon = nil;
	
    [super dealloc];
}



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
	
	[arr addObject:[NSString stringWithFormat:@"%02d:%02d", dataProvider.startTime/60, dataProvider.startTime%60]];
	[arr addObject:[NSString stringWithFormat:@"%4dm", [dataProvider segmentDistance]]];
	
	float totalMiles = ((float)([dataProvider startDistance]+[dataProvider segmentDistance]))/1600;
	[arr addObject:[NSString stringWithFormat:@"(%3.1f miles)", totalMiles]];
	
	NSString *imageName = [SegmentVO provisionIcon:[dataProvider provisionName]];
	icon.image=[UIImage imageNamed:imageName];
	
	readoutLabel.labels=arr;
	[arr release];
	[readoutLabel drawUI];
	
	[viewContainer refresh];

}



+(NSNumber*)heightForCellWithDataProvider:(SegmentVO*)segment{
	
	int height=7;
	
	height+=[GlobalUtilities calculateHeightOfTextFromWidth:[segment roadName] :[UIFont boldSystemFontOfSize:16]   :UIWIDTH :UILineBreakModeWordWrap];
	height+=5;
	height+=[GlobalUtilities calculateHeightOfTextFromWidth:[NSString stringWithFormat:@"%i",segment.startTime] :[UIFont systemFontOfSize:13] :UIWIDTH :UILineBreakModeClip];
	height+=7;
	
	return [NSNumber numberWithInt:height];
}




+(int)rowHeight{
	return STANDARDCELLHEIGHT;
}


@end
