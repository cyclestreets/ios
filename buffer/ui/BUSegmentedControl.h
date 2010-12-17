//
//  RKCustomSegmentedControl.h
//  RacingUK
//
//  Created by Neil Edwards on 27/11/2009.
//  Copyright 2009 Chroma. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HBox.h"

@protocol BUSegmentedControlDelegate <NSObject> 

@required
-(void)selectedIndexDidChange:(int)index;

@end

@interface BUSegmentedControl : UIView {
	NSMutableArray *dataProvider;
	NSMutableArray *items;
	HBox *container;
	
	int width;
	int height;
	
	@private
	int selectedIndex;
	
	int itemWidth;
	
	id <BUSegmentedControlDelegate> delegate;
}
@property(nonatomic,assign) id <BUSegmentedControlDelegate> delegate;
@property (nonatomic,retain) NSMutableArray *dataProvider;
@property (nonatomic,retain) NSMutableArray *items;
@property (nonatomic,retain) HBox *container;
@property (nonatomic) int selectedIndex;
@property (nonatomic) int width;
@property (nonatomic) int height;
@property (nonatomic) int itemWidth;

-(void)setSelectedSegmentIndex:(int)index;
-(IBAction)itemWasSelected:(id)sender;
-(IBAction)itemWasReleased:(id)sender;
-(void)removeSegmentAt:(int)index;
-(void)addSegmentAt:(int)index;
-(void)selectItemAtIndex:(int)index;
-(void)buildInterface;

@end
