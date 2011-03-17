//
//  LayoutBox.h
//  NagMe
//
//  Created by Neil Edwards on 24/11/2010.
//  Copyright 2010 buffer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GlobalUtilities.h"




@interface LayoutBox : UIView {
	
	NSMutableArray *items; // items
	
	NSMutableArray *framearray; // items
	
	LayoutBoxLayoutMode		layoutMode; // layout mode
	LayoutBoxAlignMode		alignMode; // align mode
	
	int itemPadding; // padding between items
	//
	int paddingTop;  // border padding
	int paddingLeft;
	int paddingRight;
	int paddingBottom;
	
	// internal dimensions
	int height;
	int width;
	
	// override default view sizing
	BOOL		fixedHeight;
	BOOL		fixedWidth;
	
	// view backgroundColor gradient support
	UIColor     *startColor;
	UIColor     *endColor;
	
	BOOL		distribute;
	
	BOOL		initialised;
	
	BOOL		ignoreHidden;  // TBD, will ignore views with hidden=YES
	
	
}
@property (nonatomic, retain)		NSMutableArray		* items;
@property (nonatomic, retain)		NSMutableArray		* framearray;
@property (nonatomic)		LayoutBoxLayoutMode		 layoutMode;
@property (nonatomic)		LayoutBoxAlignMode		 alignMode;
@property (nonatomic)		int		 itemPadding;
@property (nonatomic)		int		 paddingTop;
@property (nonatomic)		int		 paddingLeft;
@property (nonatomic)		int		 paddingRight;
@property (nonatomic)		int		 paddingBottom;
@property (nonatomic)		int		 height;
@property (nonatomic)		int		 width;
@property (nonatomic)		BOOL		 fixedHeight;
@property (nonatomic)		BOOL		 fixedWidth;
@property (nonatomic, retain)		UIColor		* startColor;
@property (nonatomic, retain)		UIColor		* endColor;
@property (nonatomic)		BOOL		 distribute;
@property (nonatomic)		BOOL		 initialised;
@property (nonatomic)		BOOL		 ignoreHidden;


// methods

// standard  UIview overrides
-(void)addSubview:(UIView *)view;  
-(void)addSubViewsFromArray:(NSMutableArray*)arr;
-(void)insertSubview:(UIView *)view atIndex:(NSInteger)index;  // insert view at index if exists
-(void)removeSubView:(UIView *)view;
-(void)removeSubviewAtIndex:(int)index;
-(void)removeAllSubViews;

// refresh layout and align 
-(void)refresh; 

// remove last item in layout array
-(void)removeLastSubview;

// find subview in array
-(BOOL)hasSubView:(UIView*)view;

// inits layout and align from items in IB
-(void)initFromNIB;

// basic init
-(void)initialize;

-(void)swapLayoutTo:(LayoutBoxLayoutMode)mode;

-(int)indexOfItem:(UIView*)view;

-(void)writeFrames;
@end
