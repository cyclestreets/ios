//
//  POICategoryViewController.h
//  CycleStreets
//
//  Created by Neil Edwards on 21/10/2011.
//  Copyright (c) 2011 CycleStreets Ltd. All rights reserved.
//

#import "SuperViewController.h"
#import "POICategoryVO.h"

@interface POICategoryViewController : SuperViewController<UITableViewDelegate,UITableViewDataSource>{
	
	IBOutlet			UITableView			*tableview;
	
	NSMutableArray							*dataProvider;
	
	POICategoryVO							*requestdataProvider;
	
}
@property (nonatomic, retain)	IBOutlet UITableView		*tableview;
@property (nonatomic, retain)	NSMutableArray		*dataProvider;
@property (nonatomic, retain)	POICategoryVO		*requestdataProvider;
@end
