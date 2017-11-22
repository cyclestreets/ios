//
//  CustomSegmentedControl.m
//
//
//  Created by Neil Edwards on 27/11/2009.
//  Copyright 2009 Buffer. All rights reserved.
//	custom segmented control to support image swapping for more flexible selected styles

#import "BUSegmentedControl.h"
#import "StyleManager.h"
#import "LayoutBox.h"
#import "GlobalUtilities.h"

#import "CycleStreets-Swift.h"

@implementation BUSegmentedControl
@synthesize dataProvider;
@synthesize items;
@synthesize container;
@synthesize width;
@synthesize height;
@synthesize invertHighlightTextcolor;
@synthesize invertNormalTextcolor;
@synthesize selectedIndex;
@synthesize itemWidth;
@synthesize delegate;



- (id)init {
	
	if (self = [super init]) {
		
		self.backgroundColor=[UIColor clearColor];
		itemWidth=0;
        LayoutBox *lb=[[LayoutBox alloc]init];
		self.container=lb;
		container.cornerRadius=3;
		container.itemPadding=0;
		selectedIndex=-1;
		width=0;
		invertHighlightTextcolor=NO;
		invertNormalTextcolor=NO;
		height=0;
		[self addSubview:container];    
	
	}
    return self;
}


-(CGSize)intrinsicContentSize{
	return CGSizeMake(160, 32);
}



-(void)buildInterface{
	
	UIButton *button=nil;
	
    NSMutableArray *arr=[[NSMutableArray alloc]init];
	self.items=arr;
	
	for (int i=0; i<[dataProvider count]; i++) {
		
		button=[UIButton buttonWithType:UIButtonTypeCustom];
		button.showsTouchWhenHighlighted=NO;
		[AppStyling applyStyleForButton:button key:AppStyleBUSegmentedControlButton];
		[button setTitle:[dataProvider objectAtIndex:i] forState:UIControlStateNormal];
		
		
		CGRect bframe=button.frame;
		
		if(itemWidth==0){
			bframe.size.width=[GlobalUtilities calculateWidthOfText:[dataProvider objectAtIndex:i] :[UIFont boldSystemFontOfSize:11]]+15;
		}else {
			bframe.size.width=itemWidth;
		}

		bframe.size.height=32.0f;
		button.frame=bframe;
		[button addTarget:self action:@selector(itemWasSelected:) forControlEvents:UIControlEventTouchDown];
		
		//
		width+=bframe.size.width;
		height=MAX(height,bframe.size.height);
		//
		[container addSubview:button];
		
		[items addObject:button];

		
	}
	
	// update container frames
	CGRect finalFrame=self.frame;
	finalFrame.size.width=width;
	finalFrame.size.height=height;
	container.frame=finalFrame;
	self.frame=finalFrame;
	//
	
	[self selectItemAtIndex:0];
		
}


-(void)setSelectedSegmentIndex:(NSInteger)index{
	
	if(index<[dataProvider count]){
		
		[self selectItemAtIndex:index];
		
	}
	
}

-(void)selectItemAtIndex:(NSInteger)index{
	
	if(selectedIndex!=index){
		
		if(selectedIndex!=-1){
			UIButton *outgoingbutton=[items objectAtIndex:selectedIndex];
			outgoingbutton.enabled=YES;
			[AppStyling applyStyleForButton:outgoingbutton key:AppStyleBUSegmentedControlButton];
		}
		
		selectedIndex=index;
		
		UIButton *incomingbutton=[items objectAtIndex:selectedIndex];
		incomingbutton.enabled=NO;
		[AppStyling applyStyleForButton:incomingbutton key:AppStyleBUSegmentedControlButtonDisabled];
	}
	
}


-(IBAction)itemWasSelected:(id)sender{
	
	NSInteger index=[items indexOfObject:sender];
		
	[self selectItemAtIndex:index];
	
	if([delegate respondsToSelector:@selector(selectedIndexDidChange:)]){
		[delegate selectedIndexDidChange:selectedIndex];
	}
	
}



-(void)removeSegmentAt:(NSInteger)index{
	
	if(index<[items count]){
	
		[items removeObjectAtIndex:index];
		[container removeSubviewAtIndex:index];
	
	}
	
}


-(void)addSegmentAt:(NSInteger)index{
	
	
	
	
}





- (void)drawRect:(CGRect)rect {
    // Drawing code
}





@end
