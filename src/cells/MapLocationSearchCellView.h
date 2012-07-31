//
//  MapLocationSearchCellView.h
//  CycleStreets
//
//  Created by Gaby Jones on 11/06/2012.
//  Copyright (c) 2012 CycleStreets Ltd. All rights reserved.
//

#import "BUTableCellView.h"
#import "NamedPlace.h"

@interface MapLocationSearchCellView : BUTableCellView{
	
	NamedPlace					*dataProvider;
	
	IBOutlet		UILabel			*titleLabel;
	IBOutlet		UILabel			*nearLabel;
	IBOutlet		UILabel			*distanceLabel;
	
	
}
@property (nonatomic, strong) NamedPlace		* dataProvider;
@property (nonatomic, strong) IBOutlet UILabel		* titleLabel;
@property (nonatomic, strong) IBOutlet UILabel		* nearLabel;
@property (nonatomic, strong) IBOutlet UILabel		* distanceLabel;
@end
