//
//  BUIconGridViewController.h
//  RacingUK
//
//  Created by Neil Edwards on 09/12/2011.
//  Copyright (c) 2011 Chroma. All rights reserved.
//

#import "BUViewController.h"
#import "LayoutBox.h"
#import "BUIconButton.h"


@interface BUIconGridViewController : BUViewController{
	
	
	NSMutableArray				*dataProvider;
	
	NSMutableArray				*itemArray; // array of BUIconButtons
	
	BUIconButton				*selectedItem;
	NSDictionary				*selectedViewData;
	int							selectedItemIndex;
	
	int							rowCount;  // number of items per row
	int							columnCount; // item per columnCount
	int							itemsPerPage; // number of items per page
	int							pageCount; // number of pages
	
	BOOL						viewDoesPaging; // view does pages ie pageCount>1
	UIPageControl				*pageControl;
	int							activePage; // current page
	
	BOOL						fillEmptySlots;
	
	
	// UIStyling
	UIColor						*startColor;
	UIColor						*endColor;
	NSString					*buttonBackgroundImage;
	NSString					*buttonIconTextColor;
	UIFont						*buttonIconLabelFont;
	
}
@property (nonatomic, strong) NSMutableArray		* dataProvider;
@property (nonatomic, strong) NSMutableArray		* itemArray;
@property (nonatomic, strong) BUIconButton		* selectedItem;
@property (nonatomic, strong) NSDictionary		* selectedViewData;
@property (nonatomic) int		 selectedItemIndex;
@property (nonatomic) int		 rowCount;
@property (nonatomic) int		 columnCount;
@property (nonatomic) int		 itemsPerPage;
@property (nonatomic) int		 pageCount;
@property (nonatomic) BOOL		 viewDoesPaging;
@property (nonatomic, strong) UIPageControl		* pageControl;
@property (nonatomic) int		 activePage;
@property (nonatomic) BOOL		 fillEmptySlots;
@property (nonatomic, strong) UIColor		* startColor;
@property (nonatomic, strong) UIColor		* endColor;
@property (nonatomic, strong) NSString		* buttonBackgroundImage;
@property (nonatomic, strong) NSString		* buttonIconTextColor;
@property (nonatomic, strong) UIFont		* buttonIconLabelFont;


-(void)selectItemByIndex:(int)index;
-(void)selectItemByID:(NSString*)idstring;

-(void)loadSubViewControllerForSelectedItem;

@end
