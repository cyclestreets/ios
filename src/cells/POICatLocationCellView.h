//
//  POICatLocationCellView.h
//  CycleStreets
//
//  Created by Neil Edwards on 21/10/2011.
//  Copyright (c) 2011 CycleStreets Ltd. All rights reserved.
//

#import "BUTableCellView.h"
#import "POILocationVO.h"


@interface POICatLocationCellView : BUTableCellView{
	
	POILocationVO			*dataProvider;
	
}
@property (nonatomic, retain)	POILocationVO		*dataProvider;
@end
