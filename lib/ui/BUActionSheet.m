//
//  BUActionSheet.m
//  CycleStreets
//
//  Created by Neil Edwards on 12/12/2012.
//  Copyright (c) 2012 CycleStreets Ltd. All rights reserved.
//

#import "BUActionSheet.h"
#import "LayoutBox.h"
#import "GradientView.h"
#import "ExpandedUILabel.h"
#import "ButtonUtilities.h"
#import "AppDelegate.h"
#import "UIView+Additions.h"

@interface BUActionSheet()

@property(nonatomic,strong)  LayoutBox				*viewContainer;
@property(nonatomic,strong)  NSArray				*buttonArray;
@property(nonatomic,strong)  NSString				*title;


-(void)hide:(BOOL)animated;


@end



@implementation BUActionSheet

- (id)initWithButtons:(NSArray*)buttons andTitle:(NSString*)str
{
    self = [super init];
    if (self) {
		
		self.buttonArray=buttons;
		_isVisible=NO;
		_title=str;
		
		[self generateUI];
		
    }
    return self;
}


-(void)generateUI{
	
	self.frame=CGRectMake(0, SCREENHEIGHT, SCREENWIDTH, FULLSCREENHEIGHT);
	self.backgroundColor=UIColorFromRGBAndAlpha(0x000000, 0.5);
	
	self.viewContainer=[[LayoutBox alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 10)];
	_viewContainer.backgroundColor=UIColorFromRGBAndAlpha(0x000000, 0.7);
	_viewContainer.fixedWidth=YES;
	_viewContainer.alignMode=BUCenterAlignMode;
	_viewContainer.layoutMode=BUVerticalLayoutMode;
	_viewContainer.itemPadding=20;
	[self addSubview:_viewContainer];
	
	GradientView *highlight=[[GradientView alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 10)];
	highlight.backgroundColor=[UIColor clearColor];
	[highlight setColoursWithCGColors:UIColorFromRGBAndAlpha(0xFFFFFF, 0.5).CGColor :UIColorFromRGBAndAlpha(0xFFFFFF, 0.0).CGColor];
	[_viewContainer addSubview:highlight];
	
	
	if(_title!=nil){
		
		ExpandedUILabel *title=[[ExpandedUILabel alloc]initWithFrame:CGRectMake(0, 0, UIWIDTH, 10)];
		title.fixedWidth=YES;
		title.font=[UIFont boldSystemFontOfSize:15];
		title.textColor=[UIColor whiteColor];
		title.textAlignment=UITextAlignmentCenter;
		title.text=_title;
		
		[_viewContainer addSubview:title];
		
	}
	
	
	// grid
	LayoutBox *rowContainer=[[LayoutBox alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH, TABBARHEIGHT)];
	rowContainer.alignMode=BUCenterAlignMode;
	rowContainer.layoutMode=BUVerticalLayoutMode;
	rowContainer.itemPadding=10;
	
	
	for (NSDictionary *dict in _buttonArray) {
		
		UIButton *button=[ButtonUtilities UIButtonWithFixedWidth:UIWIDTH height:40 type:dict[@"type"] text:dict[@"text"] minFont:15];
		button.tag=UNBOX_INT(dict[@"index"]);
		[button addTarget:self action:@selector(buttonSelectedAtIndex:) forControlEvents:UIControlEventTouchUpInside];
		
		[rowContainer addSubview:button];
		
	}
	
	[_viewContainer addSubview:rowContainer];
	
	UIButton *closeButton=[ButtonUtilities UIButtonWithFixedWidth:UIWIDTH height:40 type:@"red" text:@"Cancel" minFont:15];
	[closeButton addTarget:self action:@selector(closeButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
	[_viewContainer addSubview:closeButton];
	
	[ViewUtilities alignView:_viewContainer withView:self :BUNoneAlignMode :BUBottomAlignMode :20];
		
}

-(void)show:(BOOL)animated{
	
	if(_isVisible==YES)
		return;
	
	_isVisible=!_isVisible;
	
	AppDelegate *appdelegate=(AppDelegate*)[[UIApplication sharedApplication] delegate];
	UITabBar *tabBar=appdelegate.tabBarController.tabBar;
	[[[UIApplication sharedApplication] keyWindow] addSubview:self];
	
	if(animated==YES){
		
		[UIView animateWithDuration:0.3 animations:^{
			self.y=0;
			tabBar.alpha=0;
		} completion:^(BOOL finished) {
			
		}];
		
	}else{
		self.y=0;
		tabBar.alpha=0;
	}
	
	
}


-(void)hide:(BOOL)animated{
	
	AppDelegate *appdelegate=(AppDelegate*)[[UIApplication sharedApplication] delegate];
	UITabBar *tabBar=appdelegate.tabBarController.tabBar;
	
	if(animated==YES){
		
		[UIView animateWithDuration:0.3 animations:^{
			self.y=FULLSCREENHEIGHT;
			tabBar.alpha=1;
		} completion:^(BOOL finished) {
			[self removeFromSuperview];
		}];
		
	}else{
		self.y=FULLSCREENHEIGHT;
		tabBar.alpha=1;
		[self removeFromSuperview];
	}
}


-(IBAction)closeButtonSelected:(id)sender{
	
	[self hide:YES];
	
}

-(IBAction)buttonSelectedAtIndex:(id)sender{
	
	UIButton *button=(UIButton*)sender;
	int index=button.tag;
	
	if([_delegate respondsToSelector:@selector(actionSheetClickedButtonAtIndex:)]){
		[_delegate actionSheetClickedButtonAtIndex:index];
	}
	
	[self hide:YES];
	
}

@end
