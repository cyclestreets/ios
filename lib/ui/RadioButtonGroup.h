//
//  RadioButtonGroup.h
//
//
//  Created by Neil Edwards on 24/11/2010.
//  Copyright 2010 buffer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LayoutBox.h"

@protocol RadioButtonGroupDelegate <NSObject,LayoutBoxDelegate>

@optional
-(void)RadioButtonGroupValueDidChange:(int)index;


@end

@interface RadioButtonGroup : LayoutBox {
	UIButton			*selectedItem;
	
	// g/s
	int					selectedIndex;
	
}

@property (nonatomic, strong)			UIButton			*selectedItem;
@property (nonatomic)			int			selectedIndex;
@property (nonatomic, unsafe_unretained)			id<RadioButtonGroupDelegate>			delegate;

-(void)initialiseButtons;
@end
