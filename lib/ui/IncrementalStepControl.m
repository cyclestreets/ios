//
//  IncrementalStepControl.m
//
//
//  Created by Neil Edwards on 30/11/2010.
//  Copyright 2010 buffer. All rights reserved.
//

#import "IncrementalStepControl.h"
#import "StyleManager.h"
#import "ButtonUtilities.h"

@interface IncrementalStepControl(Private)

-(void)drawUI;
-(void)initialise;
-(void)addReadoutLabel;

@end



@implementation IncrementalStepControl
@synthesize indexWrap;
@synthesize indexMax;
@synthesize currentIndex;
@synthesize indexMin;
@synthesize buttonMode;
@synthesize minusButton;
@synthesize plusButton;
@synthesize buttonType;
@synthesize readoutLabel;
@synthesize readoutFont;
@synthesize readoutColor;
@synthesize useReadoutLabel;


@dynamic	delegate;


//=========================================================== 
// dealloc
//=========================================================== 
- (void)dealloc
{
    delegate = nil;
	
}


-(id)initWithCoder:(NSCoder *)decoder{
	
	self = [super initWithCoder:decoder];
    if (self) {
		[self initialise];
    }
    return self;
	
}


- (id)initWithFrame:(CGRect)frame {
	
    self = [super initWithFrame:frame];
    if (self) {
		[self initialise];
    }
    return self;
}


-(void)initialise{
	
	self.fixedWidth=YES;
	itemPadding=5;
	indexWrap=NO;
	indexMin=0;
	currentIndex=0;
	buttonMode=ICLeftRightMode;
	buttonType=@"grey";
	readoutFont=[UIFont boldSystemFontOfSize:12];
	readoutColor=[UIColor darkGrayColor];
	
}


-(void)drawUI{
	
	
	switch(buttonMode){
		
		case ICLeftRightMode:
			minusButton=[ButtonUtilities UIIconButton:@"Icon_LeftArrow" height:30 type:buttonType];
			plusButton=[ButtonUtilities UIIconButton:@"Icon_RightArrow" height:30 type:buttonType];
		break;
			
		case ICUPDownMode:
			minusButton=[ButtonUtilities UIIconButton:@"Icon_DownArrow" height:30 type:buttonType];
			plusButton=[ButtonUtilities UIIconButton:@"Icon_UpArrow" height:30 type:buttonType];
		break;
		
	}
	
	minusButton.tag=-1;
	plusButton.tag=1;
	
	[minusButton addTarget:self action:@selector(buttonWasSelected:) forControlEvents:UIControlEventTouchUpInside];
	[plusButton addTarget:self action:@selector(buttonWasSelected:) forControlEvents:UIControlEventTouchUpInside];
	
	[self addSubview:minusButton];
	
	if(useReadoutLabel==YES)
		[self addReadoutLabel];
	
	[self addSubview:plusButton];
	
	
}


-(void)addReadoutLabel{
	
	self.readoutLabel=[[ExpandedUILabel alloc]initWithFrame:CGRectMake(0, 0, 0, 30)];
	readoutLabel.multiline=NO;
	readoutLabel.font=readoutFont;
	readoutLabel.textColor=readoutColor;
	readoutLabel.text=@"0 of 0";
	[self addSubview:readoutLabel];
	
}


-(void)updateUI{
	
	if(indexMax<1){
		self.userInteractionEnabled=NO;
		minusButton.enabled=NO;
		plusButton.enabled=NO;
	}else {
		self.userInteractionEnabled=YES;
		minusButton.enabled=YES;
		plusButton.enabled=YES;
	}

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
		
		
		minusButton.enabled=YES;
		plusButton.enabled=YES;
		
		if(newindex<indexMin){
			newindex=0;
			minusButton.enabled=NO;
		}

		if(newindex>indexMax){
			newindex=indexMax;
			plusButton.enabled=NO;
		}
		
		currentIndex=newindex;
		
	}

	
	if([self.delegate respondsToSelector:@selector(stepperSelectedIndexDidChange:)]){
		[self.delegate stepperSelectedIndexDidChange:currentIndex];
	}
	
	if(useReadoutLabel==YES){
		[self updateReadoutLabel];
	}
	
}


-(void)updateReadoutLabel{
	
	readoutLabel.text=[NSString stringWithFormat:@"%i of %i",currentIndex+1,indexMax+1];
	[self refresh];
}


@end
