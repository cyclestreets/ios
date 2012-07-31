//
//  POIListviewController.h
//  CycleStreets
//
//  Created by Neil Edwards on 20/10/2011.
//  Copyright (c) 2011 CycleStreets Ltd. All rights reserved.
//

#import "SuperViewController.h"
#import "POICategoryViewController.h"

@interface POIListviewController : SuperViewController<UITableViewDelegate,UITableViewDataSource>{
	
	
	IBOutlet			UITableView				*tableview;
	
	NSMutableArray								*dataProvider;
	
	POICategoryViewController					*categoryViewController;
	
	
}
@property (nonatomic, strong)	IBOutlet UITableView		*tableview;
@property (nonatomic, strong)	NSMutableArray		*dataProvider;
@property (nonatomic, strong)	POICategoryViewController		*categoryViewController;
@end
