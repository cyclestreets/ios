//
//  CSSegmentFooterView.h
//  CycleStreets
//
//  Created by Neil Edwards on 23/03/2011.
//  Copyright 2011 CycleStreets Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LayoutBox.h"
#import "ExpandedUILabel.h"
#import "MultiLabelLine.h"

@interface CSSegmentFooterView : LayoutBox {
	
	NSDictionary				*dataProvider;
	
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
@property (nonatomic, retain)	NSDictionary		*dataProvider;
@property (nonatomic)	BOOL		hasCapitalizedTurn;
@property (nonatomic, retain)	LayoutBox		*contentContainer;
@property (nonatomic, retain)	ExpandedUILabel		*roadNameLabel;
@property (nonatomic, retain)	ExpandedUILabel		*roadTypeLabel;
@property (nonatomic, retain)	ExpandedUILabel		*capitalizedTurnLabel;
@property (nonatomic, retain)	LayoutBox		*readoutContainer;
@property (nonatomic, retain)	MultiLabelLine		*timeLabel;
@property (nonatomic, retain)	MultiLabelLine		*distLabel;
@property (nonatomic, retain)	MultiLabelLine		*totalLabel;
@property (nonatomic, retain)	ExpandedUILabel		*segmentIndexLabel;
@property (nonatomic, retain)	IBOutlet UIImageView		*iconView;
@property (nonatomic, retain)	IBOutlet UIImageView		*roadTypeiconView;

-(void)initialise;
-(void)updateLayout;

+ (NSString *)segmentDirectionIcon:(NSString *)segmentDirectionType;
@end
