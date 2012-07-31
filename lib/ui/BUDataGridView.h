//
//  BUDataGridView.h
//  RacingUK
//
//  Created by Neil Edwards on 14/11/2011.
//  Copyright (c) 2011 Chroma. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LayoutBox.h"

@interface BUDataGridView : LayoutBox{
	
	
	NSMutableArray			*dataProvider;
	BOOL					alternateColors;
	CGFloat					framewidth;
	
	//headers
	NSString				*headerColor;
	NSString				*headerTextColor;
	CGFloat					headerHeight;
	NSMutableArray			*columnWidths;
	NSMutableArray			*headers; // headers for data nodes (matches headerLabels by array index)
	NSMutableArray			*headerLabels; // labels for column headings
	NSMutableArray			*lineFormatters;
	
	// items
	NSString				*itemColor;
	NSString				*itemTextColor;
	CGFloat					itemHeight;
	
	// ui
	
	
}
// contains 
@property(nonatomic,strong)	NSMutableArray			*dataProvider;
@property(nonatomic,assign)	BOOL					alternateColors;
@property(nonatomic,strong)	NSString				*headerColor;
@property(nonatomic,strong)	NSString				*headerTextColor;
@property(nonatomic,strong)	NSMutableArray			*headers;
@property(nonatomic,assign)	CGFloat					headerHeight;
@property(nonatomic,strong)	NSMutableArray			*columnWidths;
@property(nonatomic,strong)	NSString				*itemColor;
@property(nonatomic,strong)	NSString				*itemTextColor;
@property(nonatomic,assign)	CGFloat					itemHeight;
@property(nonatomic,strong)	NSMutableArray			*headerLabels;
@property(nonatomic,assign)CGFloat					framewidth;
@property(nonatomic,strong)NSMutableArray			*lineFormatters;

-(void)createUI;
-(void)setDataProviders:(NSDictionary*)dict;

@end