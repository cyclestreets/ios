//
//  HBox.h
//  CattleShips
//
//  Created by Neil Edwards on 18/11/2009.
//  Copyright 2009 buffer. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface VBox : UIView {
	
	NSMutableArray *items;
	int verticalGap;
	//
	int paddingTop;
	int paddingLeft;
	int paddingRight;
	int paddingBottom;
	
	NSString *alignby;
	
	CGFloat height;
	CGFloat width;
	
	BOOL fixedWidth;
	BOOL fixedHeight;
	
}
// properties
@property (nonatomic, retain) NSMutableArray *items;
@property (nonatomic) int verticalGap;
@property (nonatomic) int paddingTop;
@property (nonatomic) int paddingLeft;
@property (nonatomic) int paddingRight;
@property (nonatomic) int paddingBottom;
@property (nonatomic, retain) NSString *alignby;
@property (nonatomic) CGFloat height;
@property (nonatomic) CGFloat width;
@property (nonatomic) BOOL fixedWidth;
@property (nonatomic) BOOL fixedHeight;


// methods
-(void)addSubview:(UIView *)view;
-(void)refresh;
-(void)removeSubView:(UIView *)view;
-(void)removeSubView:(UIView *)view atIndex:(int)index;
-(void)removeLastSubview;
-(void)removeAllSubViews;
-(void)initialize;
-(BOOL)hasSubView:(UIView*)view;
-(void)loadFromIB;
@end
