//
//  RadioButtonGroup.h
//  NagMe
//
//  Created by Neil Edwards on 24/11/2010.
//  Copyright 2010 buffer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LayoutBox.h"

@protocol RadioButtonGroupDelegate <NSObject>

@optional
-(void)RadioButtonGroupValueDidChange:(int)index;


@end

@interface RadioButtonGroup : LayoutBox {
	UIButton			*selectedItem;
	id<RadioButtonGroupDelegate>		delegate;
	
	// g/s
	int					selectedIndex;
	
}

@property (nonatomic, retain)			UIButton			*selectedItem;
@property (nonatomic)			int			selectedIndex;
@property (nonatomic, assign)			id<RadioButtonGroupDelegate>			delegate;

-(void)initialiseButtons;
@end
