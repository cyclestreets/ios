//
//  RKPagedDateHeader.h
//
//
//  Created by Neil Edwards on 03/12/2009.
//  Copyright 2009 Buffer. All rights reserved.
//
// horizontal scrolling paged date header

#import <UIKit/UIKit.h>
#import "LayoutBox.h"


@protocol BUPagedViewHeaderDelegate<NSObject>

@required

-(void)pageControlDidIncrement:(id)selectedItem index:(int)index;

@end


@interface BUPagedViewHeader : UIView <UIScrollViewDelegate>{
	
	// ui
	UIButton								*leftArrow;
	UIButton								*rightArrow;
	UIScrollView							*itemScroller;
	LayoutBox								*internalContainer;
	LayoutBox									*itemLabelContainer;
	
	// data
	NSMutableArray							*dataProvider;
	int	
	selectedIndex;
	
	//style
	UIColor									*gradiantColor;
	float									fontSize;
	UIColor									*textColor;
	
	// layout
	int										inset;
	int										itemWidth;
	
	// config
	BOOL									startAtEnd;
	BOOL									shouldWrapIndicies;
	
	// delegate
	id<BUPagedViewHeaderDelegate>			__unsafe_unretained delegate;
	
	// ui formatting
	NSString								*formattingStyle;
	NSString								*formatString;
}
@property (nonatomic, strong)		IBOutlet UIButton				* leftArrow;
@property (nonatomic, strong)		IBOutlet UIButton				* rightArrow;
@property (nonatomic, strong)		IBOutlet UIScrollView				* itemScroller;
@property (nonatomic, strong)		LayoutBox				* internalContainer;
@property (nonatomic, strong)		LayoutBox				* itemLabelContainer;
@property (nonatomic, strong)		NSMutableArray				* dataProvider;
@property (nonatomic, assign)		int				 selectedIndex;
@property (nonatomic, strong)		UIColor				* gradiantColor;
@property (nonatomic, assign)		float				 fontSize;
@property (nonatomic, strong)		UIColor				* textColor;
@property (nonatomic, assign)		int				 inset;
@property (nonatomic, assign)		int				 itemWidth;
@property (nonatomic, assign)		BOOL				 startAtEnd;
@property (nonatomic, assign)		BOOL				 shouldWrapIndicies;
@property (nonatomic, unsafe_unretained)		id<BUPagedViewHeaderDelegate>				 delegate;
@property (nonatomic, strong)		NSString				* formattingStyle;
@property (nonatomic, strong)		NSString				* formatString;

@property (unsafe_unretained, nonatomic,readonly) id selectedItem;

-(void)drawBackground;
-(void)drawUI;
-(void)updateScrollingItems;
-(void)incrementPage:(int)increment animated:(BOOL)animated;
-(void)navigateToPageIndex:(int)index animated:(BOOL)animated;
-(IBAction)pageUpButtonSelected:(id)sender;
-(IBAction)pageDownButtonSelected:(id)sender;
-(IBAction)resetPage;
-(NSString*)formattedLabel:(int)index;
-(id)selectedItem;
@end
