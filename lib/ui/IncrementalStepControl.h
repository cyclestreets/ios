//
//  IncrementalStepControl.h
//  NagMe
//
//  Created by Neil Edwards on 30/11/2010.
//  Copyright 2010 buffer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LayoutBox.h"

enum  {
	ICLeftRightMode,
	ICUPDownMode
};
typedef int IncrementalControlButtonMode;


@protocol IncrementalStepControlDelegate <NSObject> 

@optional
-(void)selectedIndexDidChange:(int)index;

@end

@interface IncrementalStepControl : LayoutBox {
	
	BOOL									indexWrap;
	int										indexMax;
	int										currentIndex;
	id<IncrementalStepControlDelegate>		delegate;
	int										indexMin;
	
	IncrementalControlButtonMode			buttonMode;
	
	UIButton								*minusButton;
	UIButton								*plusButton;
	
	NSString								*buttonType; // bg color for button

}
@property (nonatomic)			BOOL indexWrap;
@property (nonatomic)			int indexMax;
@property (nonatomic)			int currentIndex;
@property (nonatomic,assign)			id<IncrementalStepControlDelegate> delegate;
@property (nonatomic)			int indexMin;
@property (nonatomic)			IncrementalControlButtonMode buttonMode;
@property (nonatomic, retain)			UIButton *minusButton;
@property (nonatomic, retain)			UIButton *plusButton;
@property (nonatomic, retain)			NSString *buttonType;

@end
