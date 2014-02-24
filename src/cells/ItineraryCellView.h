//
//  ItineraryCellView.h
//  CycleStreets
//
//  Created by Neil Edwards on 09/03/2011.
//  Copyright 2011 CycleStreets Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BUTableCellView.h"

@class SegmentVO;

@interface ItineraryCellView : BUTableCellView {
	

}
@property (nonatomic, strong)		SegmentVO		* dataProvider;

@end
