//
//  CSSegmentFooterView.h
//  CycleStreets
//
//  Created by Neil Edwards on 23/03/2011.
//  Copyright 2011 CycleStreets Ltd. All rights reserved.
//

// readout view for RouteSegmentViewController map view (RouteSegmentViewController.h)

#import <UIKit/UIKit.h>
#import "LayoutBox.h"
#import "ExpandedUILabel.h"
#import "MultiLabelLine.h"
#import "SegmentVO.h"

@interface CSSegmentFooterView : LayoutBox {
	
	SegmentVO					*dataProvider;
	
	BOOL						hasCapitalizedTurn;
	
	LayoutBox					*contentContainer;
	ExpandedUILabel				*roadNameLabel;
	ExpandedUILabel				*roadTypeLabel;
	ExpandedUILabel				*capitalizedTurnLabel;
	
	LayoutBox					*readoutContainer;
	MultiLabelLine				*timeLabel;
	MultiLabelLine				*distLabel;
	MultiLabelLine				*totalLabel;
	
	ExpandedUILabel				*segmentIndexLabel;
	
	UIImageView					*iconView;
	UIImageView					*roadTypeiconView;

}
@property (nonatomic, strong)	SegmentVO		*dataProvider;
@property (nonatomic)	BOOL		hasCapitalizedTurn;
@property (nonatomic, strong)	LayoutBox		*contentContainer;
@property (nonatomic, strong)	ExpandedUILabel		*roadNameLabel;
@property (nonatomic, strong)	ExpandedUILabel		*roadTypeLabel;
@property (nonatomic, strong)	ExpandedUILabel		*capitalizedTurnLabel;
@property (nonatomic, strong)	LayoutBox		*readoutContainer;
@property (nonatomic, strong)	MultiLabelLine		*timeLabel;
@property (nonatomic, strong)	MultiLabelLine		*distLabel;
@property (nonatomic, strong)	MultiLabelLine		*totalLabel;
@property (nonatomic, strong)	ExpandedUILabel		*segmentIndexLabel;
@property (nonatomic, strong)	IBOutlet UIImageView		*iconView;
@property (nonatomic, strong)	IBOutlet UIImageView		*roadTypeiconView;

-(void)initialise;
-(void)updateLayout;

+ (NSString *)segmentDirectionIcon:(NSString *)segmentDirectionType;
@end
