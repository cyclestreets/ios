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
    NSMutableArray                          *rowHeightsArray; // variable height rows
    NSMutableDictionary                     *rowHeightDictionary; // dict to support variable height rows for section tables
	NSMutableArray							*tableSectionArray; // array of pre created section headers
    
    NSString                                *dataType; // favorites or recents

	
	BOOL									tableEditMode;
	NSMutableDictionary						*selectedCellDictionary;
	int										selectedCount;
	UIButton								*deleteButton;
	UITableView								*tableView;
	
	// testing
	UIView									*toolView;
	NSIndexPath								*tappedIndexPath;
	NSIndexPath								*toolRowIndexPath;
	NSIndexPath								*indexPathToDelete;
	
	
}
@property (nonatomic, assign) BOOL		 isSectioned;
@property (nonatomic, strong) NSMutableArray		* keys;
@property (nonatomic, strong) NSMutableArray		* dataProvider;
@property (nonatomic, strong) NSMutableDictionary		* tableDataProvider;
@property (nonatomic, strong) NSMutableArray		* rowHeightsArray;
@property (nonatomic, strong) NSMutableDictionary		* rowHeightDictionary;
@property (nonatomic, strong) NSMutableArray		* tableSectionArray;
@property (nonatomic, strong) NSString		* dataType;
@property (nonatomic, assign) BOOL		 tableEditMode;
@property (nonatomic, strong) NSMutableDictionary		* selectedCellDictionary;
@property (nonatomic, assign) int		 selectedCount;
@property (nonatomic, strong) UIButton		* deleteButton;
@property (nonatomic, strong) UITableView		* tableView;
@property (nonatomic, strong) UIView		* toolView;
@property (nonatomic, strong) NSIndexPath		* tappedIndexPath;
@property (nonatomic, strong) NSIndexPath		* toolRowIndexPath;
@property (nonatomic, strong) NSIndexPath		* indexPathToDelete;

-(void)setTableEditingState:(BOOL)state;


@end
