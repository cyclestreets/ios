//
//  ItineraryCellView.h
//  CycleStreets
//
//  Created by Neil Edwards on 09/03/2011.
//  Copyright 2011 CycleStreets Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SuperCellView.h"
#import "SegmentVO.h"
#import "LayoutBox.h"
#import "MultiLabelLine.h"
#import "ExpandedUILabel.h"

@interface ItineraryCellView : SuperCellView {
	
	SegmentVO							*dataProvider;
	
	IBOutlet	LayoutBox				*viewContainer;
	IBOutlet ExpandedUILabel			*nameLabel;
	IBOutlet MultiLabelLine				*readoutLabel;
	
	IBOutlet UIImageView				*icon;

}
@property (nonatomic, retain)		SegmentVO		* dataProvider;
@property (nonatomic, retain)		IBOutlet LayoutBox		* viewContainer;
@property (nonatomic, retain)		IBOutlet ExpandedUILabel		* nameLabel;
@property (nonatomic, retain)		IBOutlet MultiLabelLine		* readoutLabel;
@property (nonatomic, retain)		IBOutlet UIImageView		* icon;

+(NSNumber*)heightForCellWithDataProvider:(SegmentVO*)segment;
@end
