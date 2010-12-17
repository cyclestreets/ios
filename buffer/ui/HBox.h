//
//  HBox.h
//  CattleShips
//
//  Created by Neil Edwards on 18/11/2009.
//  Copyright 2009 buffer. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface HBox : UIView {
	
	NSMutableArray *items;
	int horizontalGap;
	//
	int paddingTop;
	int paddingLeft;
	int paddingRight;
	int paddingBottom;
	
	NSString *alignby;
	
	NSString	*horizontalAlign;
	NSString	*verticalAlign;
	
	int height;
	int width;
	
	BOOL		fixedHeight;
	BOOL		fixedWidth;
	
	// gradiant support
	UIColor     *startColor;
	UIColor     *endColor;

}
// properties
@property (nonatomic, retain) NSMutableArray *items;
@property (nonatomic) int horizontalGap;
@property (nonatomic) int paddingTop;
@property (nonatomic) int paddingLeft;
@property (nonatomic) int paddingRight;
@property (nonatomic) int paddingBottom;
@property (nonatomic, retain) NSString *alignby;
@property (nonatomic, retain) NSString *horizontalAlign;
@property (nonatomic, retain) NSString *verticalAlign;
@property (nonatomic) int height;
@property (nonatomic) int width;
@property (nonatomic) BOOL fixedHeight;
@property (nonatomic) BOOL fixedWidth;
@property (nonatomic, retain) UIColor *startColor;
@property (nonatomic, retain) UIColor *endColor;


// methods
-(void)addSubview:(UIView *)view;
-(void)insertSubview:(UIView *)view atIndex:(NSInteger)index;
-(void)refresh;
-(void)removeSubView:(UIView *)view;
-(void)removeSubViewatIndex:(int)index;
-(void)removeLastSubview;
-(void)removeAllSubViews;
-(BOOL)hasSubView:(UIView*)view;
-(void)loadFromIB;
-(void)initialize;

@end
