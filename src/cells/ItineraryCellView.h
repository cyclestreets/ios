//
//  ItineraryCellView.h
//  CycleStreets
//
//  Created by Neil Edwards on 09/03/2011.
//  Copyright 2011 CycleStreets Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BUTableCellView.h"
#import "SegmentVO.h"
#import "LayoutBox.h"
#import "MultiLabelLine.h"
#import "ExpandedUILabel.h"

@interface ItineraryCellView : BUTableCellView {
	
	SegmentVO							*dataProvider;
	
	IBOutlet	LayoutBox				*viewContainer;
	IBOutlet ExpandedUILabel			*nameLabel;
	IBOutlet MultiLabelLine				*readoutLabel;
	
	IBOutlet UIImageView				*icon;

}
@property (nonatomic, strong)		SegmentVO		* dataProvider;
@property (nonatomic, strong)		IBOutlet LayoutBox		* viewContainer;
@property (nonatomic, strong)		IBOutlet ExpandedUILabel		* nameLabel;
@property (nonatomic, strong)		IBOutlet MultiLabelLine		* readoutLabel;
@property (nonatomic, strong)		IBOutlet UIImageView		* icon;

+(NSNumber*)heightForCellWithDataProvider:(SegmentVO*)segment;
@end
