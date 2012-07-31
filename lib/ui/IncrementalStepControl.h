//
//  IncrementalStepControl.h
//
//
//  Created by Neil Edwards on 30/11/2010.
//  Copyright 2010 buffer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LayoutBox.h"
#import "ExpandedUILabel.h"

enum  {
	ICLeftRightMode,
	ICUPDownMode
};
typedef int IncrementalControlButtonMode;


@protocol IncrementalStepControlDelegate <NSObject,LayoutBoxDelegate> 

@optional
-(void)stepperSelectedIndexDidChange:(int)index;

@end

@interface IncrementalStepControl : LayoutBox{
	
	BOOL									indexWrap;
	int										indexMax;
	int										currentIndex;
	int										indexMin;
	
	IncrementalControlButtonMode			buttonMode;
	
	UIButton								*minusButton;
	UIButton								*plusButton;
	
	NSString								*buttonType; // bg color for button
	
	//optional internal readout label ie < x of x >
	ExpandedUILabel							*readoutLabel;
	UIFont									*readoutFont;
	UIColor									*readoutColor;
	BOOL									useReadoutLabel;
	

}
@property (nonatomic, assign)	BOOL			indexWrap;
@property (nonatomic, assign)	int			indexMax;
@property (nonatomic, assign)	int			currentIndex;
@property (nonatomic, assign)	int			indexMin;
@property (nonatomic, assign)	IncrementalControlButtonMode			buttonMode;
@property (nonatomic, strong)	UIButton			*minusButton;
@property (nonatomic, strong)	UIButton			*plusButton;
@property (nonatomic, strong)	NSString			*buttonType;
@property (nonatomic, strong)	ExpandedUILabel			*readoutLabel;
@property (nonatomic, strong)	UIFont			*readoutFont;
@property (nonatomic, strong)	UIColor			*readoutColor;
@property (nonatomic, assign)	BOOL			useReadoutLabel;
@property (nonatomic, unsafe_unretained)			id<IncrementalStepControlDelegate>			delegate;

-(void)drawUI;
-(void)updateUI;

-(void)updateReadoutLabel;
@end
