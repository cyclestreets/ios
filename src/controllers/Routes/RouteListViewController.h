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
@property (nonatomic, retain) NSMutableArray		* keys;
@property (nonatomic, retain) NSMutableArray		* dataProvider;
@property (nonatomic, retain) NSMutableDictionary		* tableDataProvider;
@property (nonatomic, retain) NSMutableArray		* rowHeightsArray;
@property (nonatomic, retain) NSMutableDictionary		* rowHeightDictionary;
@property (nonatomic, retain) NSMutableArray		* tableSectionArray;
@property (nonatomic, retain) NSString		* dataType;
@property (nonatomic, assign) BOOL		 tableEditMode;
@property (nonatomic, retain) NSMutableDictionary		* selectedCellDictionary;
@property (nonatomic, assign) int		 selectedCount;
@property (nonatomic, retain) UIButton		* deleteButton;
@property (nonatomic, retain) UITableView		* tableView;
@property (nonatomic, retain) UIView		* toolView;
@property (nonatomic, retain) NSIndexPath		* tappedIndexPath;
@property (nonatomic, retain) NSIndexPath		* toolRowIndexPath;
@property (nonatomic, retain) NSIndexPath		* indexPathToDelete;

-(void)setTableEditingState:(BOOL)state;
@end
