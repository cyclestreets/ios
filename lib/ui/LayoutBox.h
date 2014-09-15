//
//  LayoutBox.h
//  NagMe
//
//  Created by Neil Edwards on 24/11/2010.
//  Copyright 2010 buffer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GlobalUtilities.h"
#import "ViewUtilities.h"


@protocol LayoutBoxDelegate <NSObject>

@optional
-(void)layoutBoxDidCompleteAnimation:(NSString*)type;


@end



@interface LayoutBox : UIView {
	
	NSMutableArray					*items; // items
	
	NSMutableArray					*framearray; // items
	
	// prelim support for animated insert/remove
	NSMutableArray					*deferredFrameArray;
	BOOL							layoutWillBeAnimated;
	UIView							*deferredView;
	CGRect							deferredViewFrame;
	UIScrollView					*parentScrollView;
	//
	
	LayoutBoxLayoutMode				layoutMode; // layout mode
	LayoutBoxAlignMode				alignMode; // align mode
	
	int								itemPadding; // padding between items
	//
	int								paddingTop;  // border padding
	int								paddingLeft;
	int								paddingRight;
	int								paddingBottom;
	
	// internal dimensions
	int								height;
	int								width;
	
	// override default view sizing
	BOOL							fixedHeight;
	BOOL							fixedWidth;
	
	// view backgroundColor gradient support
	UIColor							*startColor;
	UIColor							*endColor;
	
	// view border support
	UIColor							*strokeColor;
	BorderParams					borderparams;
	
	int								cornerRadius;
	
	
	// inset shadow support
	BOOL							showInsetShadow;
	
	BOOL							distribute;	
	BOOL							initialised;	
	BOOL							ignoreHidden;  // TBD, will ignore views with hidden=YES
	
	
	id<LayoutBoxDelegate>			__unsafe_unretained delegate;
	
}
@property (nonatomic, strong)	NSMutableArray		*items;
@property (nonatomic, strong)	NSMutableArray		*framearray;
@property (nonatomic, strong)	NSMutableArray		*deferredFrameArray;
@property (nonatomic)	BOOL		layoutWillBeAnimated;
@property (nonatomic, strong)	UIView		*deferredView;
@property (nonatomic)	CGRect		deferredViewFrame;
@property (nonatomic, strong)	UIScrollView		*parentScrollView;
@property (nonatomic)	LayoutBoxLayoutMode		layoutMode;
@property (nonatomic)	LayoutBoxAlignMode		alignMode;
@property (nonatomic)	int		itemPadding;
@property (nonatomic)	int		paddingTop;
@property (nonatomic)	int		paddingLeft;
@property (nonatomic)	int		paddingRight;
@property (nonatomic)	int		paddingBottom;
@property (nonatomic)	int		height;
@property (nonatomic)	int		width;
@property (nonatomic)	BOOL		fixedHeight;
@property (nonatomic)	BOOL		fixedWidth;
@property (nonatomic, strong)	UIColor		*startColor;
@property (nonatomic, strong)	UIColor		*endColor;
@property (nonatomic, strong)	UIColor		*strokeColor;
@property (nonatomic)	BorderParams		borderparams;
@property (nonatomic)	int		cornerRadius;
@property (nonatomic)	BOOL		showInsetShadow;
@property (nonatomic)	BOOL		distribute;
@property (nonatomic)	BOOL		initialised;
@property (nonatomic)	BOOL		ignoreHidden;
@property (nonatomic, unsafe_unretained)		id<LayoutBoxDelegate>		 delegate;

@property (nonatomic,readonly) int                          viewHeight;
@property (nonatomic,readonly) int                          viewWidth;


// methods

// standard  UIview overrides
-(void)addSubview:(UIView *)view;  
-(void)addSubViewsFromArray:(NSMutableArray*)arr;
-(void)insertSubview:(UIView *)view atIndex:(NSInteger)index;  // insert view at index if exists
-(void)removeSubView:(UIView *)view;
-(void)removeSubviewAtIndex:(NSInteger)index;
-(void)removeAllSubViews;
-(UIView*)viewAtIndex:(NSInteger)index;


// prelim insert/remove with animation support
-(void)insertSubview:(UIView *)view atIndex:(NSInteger)index animated:(BOOL)animated;
-(void)removeViewatIndex:(NSInteger)index animated:(BOOL)animated;


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
