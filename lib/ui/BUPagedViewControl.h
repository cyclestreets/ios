//
//  BUPagedViewControl.h
//  WearingOff
//
//  Created by Neil Edwards on 12/12/2011.
//  Copyright (c) 2011 buffer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LayoutBox.h"


enum{
	PagedHeaderDataTypeFixedLength=0,
	PagedHeaderDataTypeInfinite=1
};
typedef int PagedHeaderDataType;


@protocol BUPagedViewControlDelegate<NSObject>

@required

-(void)pageControlDidIncrement:(id)selectedItem index:(int)index;

@end

@interface BUPagedViewControl : UIView{
	
	
	// ui
	UIButton							*leftArrow;
	UIButton							*rightArrow;
	LayoutBox							*internalContainer;
	UIView								*itemLabelContainer;
	NSMutableArray						*itemLabels;
	
	// data
	NSMutableArray						*dataProvider;
	int									selectedIndex;
	PagedHeaderDataType					dataType;
	
	// infinite extents	for compares				
	NSDate								*startDate;
	NSDate								*endDate;
	NSDate								*initDate;
	//
	
	
	//style
	UIColor								*gradiantColor;
	float								fontSize;
	UIColor								*textColor;
	
	// layout
	int									inset;
	int									itemWidth;
	
	// config
	BOOL								startAtEnd;
	BOOL								shouldWrapIndicies;
	
	// delegate
	id<BUPagedViewControlDelegate>			__unsafe_unretained delegate;
	
	// ui formatting
	NSString							*formattingStyle;
	NSString							*formatString;
	
	
}
@property (nonatomic, retain)	UIButton		*leftArrow;
@property (nonatomic, retain)	UIButton		*rightArrow;
@property (nonatomic, retain)	LayoutBox		*internalContainer;
@property (nonatomic, retain)	UIView		*itemLabelContainer;
@property (nonatomic, retain)	NSMutableArray		*itemLabels;
@property (nonatomic, retain)	NSMutableArray		*dataProvider;
@property (nonatomic)	int		selectedIndex;
@property (nonatomic)	PagedHeaderDataType		dataType;
@property (nonatomic, retain)	NSDate		*startDate;
@property (nonatomic, retain)	NSDate		*endDate;
@property (nonatomic, retain)	NSDate		*initDate;
@property (nonatomic, retain)	UIColor		*gradiantColor;
@property (nonatomic)	float		fontSize;
@property (nonatomic, retain)	UIColor		*textColor;
@property (nonatomic)	int		inset;
@property (nonatomic)	int		itemWidth;
@property (nonatomic)	BOOL		startAtEnd;
@property (nonatomic)	BOOL		shouldWrapIndicies;
@property (nonatomic, unsafe_unretained)		id<BUPagedViewControlDelegate>				 delegate;
@property (nonatomic, retain)	NSString		*formattingStyle;
@property (nonatomic, retain)	NSString		*formatString;

-(void)updateItems;
-(void)initFromDataType;

-(void)incrementPage:(int)increment animated:(BOOL)animated;
-(void)navigateToPageIndex:(int)index animated:(BOOL)animated;
-(IBAction)resetPage;
-(id)selectedItem;
@end
