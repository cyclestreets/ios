//
//  ItineraryCellView.h
//  CycleStreets
//
//  Created by Neil Edwards on 09/03/2011.
//  Copyright 2011 CycleStreets Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SuperCellView.h"
#import "Segment.h"

@interface ItineraryCellView : SuperCellView {
	
	Segment							*dataProvider;
	
	IBOutlet		UILabel			*roadLabel;
	IBOutlet		UILabel			*timeLabel;
	IBOutlet		UILabel			*distanceLabel;
	IBOutlet		UILabel			*totalLabel;
	IBOutlet		UIImageView		*imageView;

}
@property (nonatomic, retain)		Segment		* dataProvider;
@property (nonatomic, retain)		IBOutlet UILabel		* roadLabel;
@property (nonatomic, retain)		IBOutlet UILabel		* timeLabel;
@property (nonatomic, retain)		IBOutlet UILabel		* distanceLabel;
@property (nonatomic, retain)		IBOutlet UILabel		* totalLabel;
@property (nonatomic, retain)		IBOutlet UIImageView		* imageView;

@end
