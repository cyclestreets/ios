//
//  BUIconButton.h
//
//  Created by Neil Edwards on 17/11/2011.
//  Copyright (c) 2011 buffer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LayoutBox.h"
#import "ExpandedUILabel.h"

@interface BUIconButton : LayoutBox{
	
	int					index;
	
	UIButton			*button;
	
	NSString			*buttonIconImage;
	NSString			*buttonBackgroundImage;
	NSString			*text;
	
	ExpandedUILabel		*label;
	
	NSString			*textColor;
	UIFont				*labelFont;
	
	
	BOOL				labelFitsIcon;
	
	int					maxLabelWidth;
	
	CGSize				buttonSize;
	
}
@property (nonatomic, assign) int             index;
@property (nonatomic, strong) UIButton        * button;
@property (nonatomic, strong) NSString        * buttonIconImage;
@property (nonatomic, strong) NSString        * buttonBackgroundImage;
@property (nonatomic, strong) NSString        * text;
@property (nonatomic, strong) ExpandedUILabel * label;
@property (nonatomic, strong) NSString        * textColor;
@property (nonatomic, strong) UIFont          * labelFont;
@property (nonatomic, assign) BOOL            labelFitsIcon;
@property (nonatomic, assign) int             maxLabelWidth;
@property (nonatomic, assign) CGSize          buttonSize;


-(void)drawUI;

@end
