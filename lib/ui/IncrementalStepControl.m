//
//  IncrementalStepControl.m
//  NagMe
//
//  Created by Neil Edwards on 30/11/2010.
//  Copyright 2010 buffer. All rights reserved.
//

#import "IncrementalStepControl.h"
#import "StyleManager.h"
#import "ButtonUtilities.h"


@interface IncrementalStepControl(Private)

-(void)drawUI;

@end



@implementation IncrementalStepControl
@synthesize indexWrap;
@synthesize indexMax;
@synthesize currentIndex;
@synthesize delegate;
@synthesize indexMin;
@synthesize buttonMode;
@synthesize minusButton;
@synthesize plusButton;
@synthesize buttonType;


//=========================================================== 
// dealloc
//=========================================================== 
- (void)dealloc
{
    delegate = nil;
    [minusButton release], minusButton = nil;
    [plusButton release], plusButton = nil;
    [buttonType release], buttonType = nil;
	
    [super dealloc];
}





- (id)initWithFrame:(CGRect)frame {
	
	indexWrap=NO;
	indexMin=0;
	currentIndex=0;
	buttonMode=ICLeftRightMode;
	buttonType=@"grey";
    
    self = [super initWithFrame:frame];
    if (self) {
		[self drawUI];
    }
    return self;
}


-(void)drawUI{
	
	
	switch(buttonMode){
		
		case ICLeftRightMode:
			minusButton=[ButtonUtilities UIImageButtonWithWidth:@"Icon_LeftArrow" height:30 type:buttonType text:@""];
			plusButton=[ButtonUtilities UIImageButtonWithWidth:@"Icon_RightArrow" height:30 type:buttonType text:@""];
		break;
			
		case ICUPDownMode:
			minusButton=[ButtonUtilities UIImageButtonWithWidth:@"Icon_DownArrow" height:30 type:buttonType text:@""];
			plusButton=[ButtonUtilities UIImageButtonWithWidth:@"Icon_UpArrow" height:30 type:buttonType text:@""];
		break;
		
	}
	
	minusButton.tag=-1;
	plusButton.tag=1;
	
	[minusButton addTarget:self action:@selector(buttonWasSelected:) forControlEvents:UIControlEventTouchUpInside];
	[plusButton addTarget:self action:@selector(buttonWasSelected:) forControlEvents:UIControlEventTouchUpInside];
	
	[self addSubview:minusButton];
	[self addSubview:plusButton];
	
	
}



-(IBAction)buttonWasSelected:(id)sender{
	
	UIButton  *button=(UIButton*)sender;
	
	int newindex=currentIndex+button.tag;
	
	if(indexWrap==YES){
		
		if(newindex<indexMin){
			newindex=indexMax;
		}
		if(newindex>indexMax){
			newindex=indexMin;
		}
		
		currentIndex=newindex;
		
	}else {
		
		// can disable buttons at extents
		if(newindex<indexMin){
			newindex=indexMax;
		}
		if(newindex>indexMax){
			newindex=indexMin;
		}
		
		currentIndex=newindex;
		
	}

	
	if([delegate respondsToSelector:@selector(selectedIndexDidChange:)]){
		[delegate selectedIndexDidChange:currentIndex];
	}
	
	
}



@end
