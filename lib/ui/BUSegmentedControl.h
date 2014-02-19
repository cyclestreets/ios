//
//  CustomSegmentedControl.h
//
//
//  Created by Neil Edwards on 27/11/2009.
//  Copyright 2009 Buffer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LayoutBox.h"

@protocol BUSegmentedControlDelegate <NSObject> 

@required
-(void)selectedIndexDidChange:(int)index;

@end

@interface BUSegmentedControl : UIView {
	NSMutableArray *dataProvider;
	NSMutableArray *items;
	LayoutBox *container;
	
	int width;
	int height;
	
	BOOL			invertHighlightTextcolor;
	BOOL			invertNormalTextcolor;
	
	@private
	int selectedIndex;
	
	int itemWidth;
	
	id <BUSegmentedControlDelegate> __unsafe_unretained delegate;
}
@property(nonatomic,unsafe_unretained) id <BUSegmentedControlDelegate> delegate;
@property (nonatomic, strong) NSMutableArray		* dataProvider;
@property (nonatomic, strong) NSMutableArray		* items;
@property (nonatomic, strong) LayoutBox		* container;
@property (nonatomic, assign) int		 width;
@property (nonatomic, assign) int		 height;
@property (nonatomic, assign) BOOL		 invertHighlightTextcolor;
@property (nonatomic, assign) BOOL		 invertNormalTextcolor;
@property (nonatomic, assign) int		 selectedIndex;
@property (nonatomic, assign) int		 itemWidth;

-(void)setSelectedSegmentIndex:(int)index;
-(IBAction)itemWasSelected:(id)sender;
-(void)removeSegmentAt:(int)index;
-(void)addSegmentAt:(int)index;
-(void)selectItemAtIndex:(int)index;
-(void)buildInterface;

@end
