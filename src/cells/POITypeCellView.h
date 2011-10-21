//
//  POITypeCellView.h
//  CycleStreets
//
//  Created by Neil Edwards on 20/10/2011.
//  Copyright (c) 2011 CycleStreets Ltd. All rights reserved.
//

#import "BUTableCellView.h"
#import "POICategoryVO.h"

@interface POITypeCellView : BUTableCellView{
	
	IBOutlet	UIImageView				*imageView;
	IBOutlet	UILabel					*label;
	IBOutlet	UILabel					*totallabel;
	
	POICategoryVO						*dataProvider;
}
@property (nonatomic, retain)	IBOutlet UIImageView		*imageView;
@property (nonatomic, retain)	IBOutlet UILabel		*label;
@property (nonatomic, retain)	IBOutlet UILabel		*totallabel;
@property (nonatomic, retain)	POICategoryVO		*dataProvider;
@end
