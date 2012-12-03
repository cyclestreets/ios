//
//  BUIconActionSheet.m
//  CycleStreets
//
//  Created by Neil Edwards on 01/12/2012.
//  Copyright (c) 2012 CycleStreets Ltd. All rights reserved.
//

#import "BUIconActionSheet.h"
#import "GlobalUtilities.h"
#import "LayoutBox.h"
#import "StyleManager.h"
#import "ButtonUtilities.h"
#import "UIView+Additions.h"

#define COLUMNCOUNT 3

@interface BUIconActionSheet()

@property(nonatomic,strong)  LayoutBox				*viewContainer;


@property(nonatomic,strong)  NSMutableArray         *buttonArray;


@end

@implementation BUIconActionSheet

- (id)initWithButtons:(NSMutableArray*)buttons
{
    self = [super init];
    if (self) {
		
		self.buttonArray=buttons;
		_isVisible=NO;
		
		[self generateUI]
       
    }
    return self;
}


-(void)generateUI{
	
	self.backgroundColor=UIColorFromRGBAndAlpha(0x000000, 0.5);
	
	self.viewContainer=[[LayoutBox alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 10)];
	_viewContainer.fixedWidth=YES;
	_viewContainer.alignMode=BUCenterAlignMode;
	_viewContainer.layoutMode=BUVerticalLayoutMode;
	_viewContainer.itemPadding=20;
	[self addSubview:_viewContainer];
	
	
	// grid
	LayoutBox *rowContainer=[[LayoutBox alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH, TABBARHEIGHT)];
	rowContainer.alignMode=BUCenterAlignMode;
	rowContainer.layoutMode=BUVerticalLayoutMode;
	rowContainer.itemPadding=10;
	
	BOOL newRow=YES;
	LayoutBox *colContainer=nil;
	for (NSString *key in _buttonArray) {
		
		if(newRow==YES){
			colContainer=[[LayoutBox alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH, TABBARHEIGHT)];
			colContainer.itemPadding=30;
			newRow=NO;
		}
		
		UIButton *iconButton=[ButtonUtilities UISimpleImageButton:key];
		[iconButton addTarget:self action:@selector(iconButtonSelectedAtIndex) forControlEvents:UIControlEventTouchUpInside];
		[colContainer addSubview:iconButton];
		
		if(colContainer.items.count==COLUMNCOUNT){
			[rowContainer addSubview:colContainer];
			newRow=YES;
		}
		
	}
	
	
	UIButton *closeButton=[ButtonUtilities UIButtonWithWidth:200 height:TABBARHEIGHT type:@"grey" text:@"Cancel"];
	[closeButton addTarget:self action:@selector(closeButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
	[_viewContainer addSubview:closeButton];
	
	[ViewUtilities alignView:_viewContainer withView:self :BUNoneAlignMode :BUBottomAlignMode];

}

-(void)show:(BOOL)show{
	
	if(show==_isVisible)
		return;
	
	_isVisible=!_isVisible;
	
	if(_isVisible==YES){
		
		[UIView animateWithDuration:0.4 animations:^{
			self.y=0;			
		} completion:^(BOOL finished) {
			
		}];
		
	}else{
		[UIView animateWithDuration:0.4 animations:^{
			self.y=SCREENHEIGHT;
		} completion:^(BOOL finished) {
			
		}];
	}
	
	
	
}



-(IBAction)closeButtonSelected:(id)sender{
	
	[self show:NO];
	
}

-(IBAction)iconButtonSelectedAtIndex:(id)sender{
	
	UIButton *button=(UIButton*)sender;
	int index=button.tag;
	
	if([_delegate respondsToSelector:@selector(actionSheetClickedButtonAtIndex:)]){
		[_delegate actionSheetClickedButtonAtIndex:index];
	}
	
}


@end
