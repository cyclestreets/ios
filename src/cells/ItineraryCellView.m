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
#import "LayoutBox.h"
#import "MultiLabelLine.h"
#import "ExpandedUILabel.h"

@interface ItineraryCellView()

@property (nonatomic, weak)		IBOutlet LayoutBox		* viewContainer;
@property (nonatomic, weak)		IBOutlet ExpandedUILabel		* nameLabel;
@property (nonatomic, weak)		IBOutlet MultiLabelLine		* readoutLabel;
@property (nonatomic, weak)		IBOutlet UIImageView		* icon;

@end


@implementation ItineraryCellView



-(void)initialise{
	
	_viewContainer.layoutMode=BUVerticalLayoutMode;
	_viewContainer.paddingLeft=0;
	_viewContainer.paddingTop=7;
	_viewContainer.paddingBottom=7;
	_viewContainer.itemPadding=0;
	[_viewContainer initFromNIB];
	
	NSMutableArray *fonts=[NSMutableArray arrayWithObjects:[UIFont boldSystemFontOfSize:13],[UIFont systemFontOfSize:13],[UIFont systemFontOfSize:13],nil];
	NSMutableArray *colors=[NSMutableArray arrayWithObjects:UIColorFromRGB(0xFF8000),UIColorFromRGB(0x007F00),UIColorFromRGB(0x404040),nil];
	
	_readoutLabel.fonts=fonts;
	_readoutLabel.colors=colors;



}

-(void)populate{
	
	_nameLabel.text=[_dataProvider roadName];
	
	NSMutableArray *arr=[[NSMutableArray alloc] init];
	
	[arr addObject:[_dataProvider timeString]];
	[arr addObject:[NSString stringWithFormat:@"%4ldm", (long)[_dataProvider segmentDistance]]];
	
	float totalMiles = ((float)([_dataProvider startDistance]+[_dataProvider segmentDistance]))/1600;
	[arr addObject:[NSString stringWithFormat:@"(%3.1f miles)", totalMiles]];
	
	_icon.image=[UIImage imageNamed:_dataProvider.provisionIcon];
	
	_readoutLabel.labels=arr;
	[_readoutLabel drawUI];
	
	[_viewContainer refresh];
	
	[ViewUtilities alignView:_icon withView:_viewContainer :BUNoneLayoutMode :BUCenterAlignMode];

}



+(NSNumber*)heightForCellWithDataProvider:(SegmentVO*)segment{
	
	int height=7;
	
	height+=[GlobalUtilities calculateHeightOfTextFromWidth:[segment roadName] :[UIFont boldSystemFontOfSize:16]   :248 :NSLineBreakByWordWrapping];
	height+=5;
	height+=[GlobalUtilities calculateHeightOfTextFromWidth:[segment timeString] :[UIFont systemFontOfSize:13] :248 :NSLineBreakByClipping];
	height+=7;
	
	return [NSNumber numberWithInt:height];
}




+(int)rowHeight{
	return STANDARDCELLHEIGHT;
}


@end
