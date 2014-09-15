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
-(void)selectedIndexDidChange:(NSInteger)index;

@end

@interface BUSegmentedControl : UIView {
	NSMutableArray *dataProvider;
	NSMutableArray *items;
	LayoutBox *container;
	
	NSInteger width;
	NSInteger height;
	
	BOOL			invertHighlightTextcolor;
	BOOL			invertNormalTextcolor;
	
	@private
	NSInteger selectedIndex;
	
	NSInteger itemWidth;
	
	id <BUSegmentedControlDelegate> __unsafe_unretained delegate;
}
@property(nonatomic,unsafe_unretained) id <BUSegmentedControlDelegate> delegate;
@property (nonatomic, strong) NSMutableArray		* dataProvider;
@property (nonatomic, strong) NSMutableArray		* items;
@property (nonatomic, strong) LayoutBox		* container;
@property (nonatomic, assign) NSInteger		 width;
@property (nonatomic, assign) NSInteger		 height;
@property (nonatomic, assign) BOOL		 invertHighlightTextcolor;
@property (nonatomic, assign) BOOL		 invertNormalTextcolor;
@property (nonatomic, assign) NSInteger		 selectedIndex;
@property (nonatomic, assign) NSInteger		 itemWidth;

-(void)setSelectedSegmentIndex:(NSInteger)index;
-(IBAction)itemWasSelected:(id)sender;
-(void)removeSegmentAt:(NSInteger)index;
-(void)addSegmentAt:(NSInteger)index;
-(void)selectItemAtIndex:(NSInteger)index;
-(void)buildInterface;

@end
