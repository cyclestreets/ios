//
//  RadioButtonGroup.m
//  NagMe
//
//  Created by Neil Edwards on 24/11/2010.
//  Copyright 2010 buffer. All rights reserved.
//

#import "RadioButtonGroup.h"


@implementation RadioButtonGroup
@dynamic selectedIndex;
@synthesize selectedItem;
@synthesize delegate;

/***********************************************************/
// dealloc
/***********************************************************/
- (void)dealloc
{
    [selectedItem release], selectedItem = nil;
    delegate = nil;
	
    [super dealloc];
}



- (id)init
{
    self = [super init];
    if (self) {
        selectedIndex=-1;
    }
    return self;
}



-(void)initialiseButtons{
	
	for (int i=0; i<[items count]; i++) {
		UIButton *button=(UIButton*)[items objectAtIndex:i];
		[button addTarget:self action:@selector(updateSelectedIndex:) forControlEvents:UIControlEventTouchUpInside];
	}
	
	
}

/***********************************************************/
//  selectedIndex 
/***********************************************************/
- (int)selectedIndex
{
    return selectedIndex;
}
-(void)setSelectedIndex:(int)index{
	
	if (index<[items count] && index>-1) {
		
		if(selectedItem!=nil){
			selectedItem.selected=NO;
			selectedItem.userInteractionEnabled=YES;
		}
		
		selectedIndex=index;
		selectedItem=[items objectAtIndex:selectedIndex];
		selectedItem.selected=YES;
		selectedItem.userInteractionEnabled=NO;
		
	}
	
}



-(IBAction)updateSelectedIndex:(id)sender{
	
	UIButton *button=(UIButton*)sender;
	
	[self setSelectedIndex:[self indexOfItem:button]];
	
	
}



@end
