//
//  RouteListViewController.h
//  CycleStreets
//
//  Created by neil on 12/03/2011.
//  Copyright 2011 CycleStreets Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SuperViewController.h"

@interface RouteListViewController : SuperViewController {
	
	BOOL									isSectioned;
	NSMutableArray							*keys; // sectioned type keys
	NSMutableArray							*dataProvider; // root data provider, this is used direct for non sectioned views
	NSMutableDictionary						*tableDataProvider; // sectioned variant of root dataProvider

	
	BOOL									tableEditMode;
	NSMutableDictionary						*selectedCellDictionary;
	int										selectedCount;
	UIButton								*deleteButton;
	UITableView								*tableView;
}
@property (nonatomic, assign)	BOOL	isSectioned;
@property (nonatomic, retain)	NSMutableArray	*keys;
@property (nonatomic, retain)	NSMutableArray	*dataProvider;
@property (nonatomic, retain)	NSMutableDictionary	*tableDataProvider;
@property (nonatomic, assign)	BOOL	tableEditMode;
@property (nonatomic, retain)	NSMutableDictionary	*selectedCellDictionary;
@property (nonatomic, assign)	int	selectedCount;
@property (nonatomic, retain)	IBOutlet UIButton	*deleteButton;
@property (nonatomic, retain)	IBOutlet UITableView	*tableView;

-(void)setTableEditingState:(BOOL)state;
@end
