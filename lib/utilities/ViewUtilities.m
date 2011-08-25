//
//  ViewUtilities.m
//  RacingUK
//
//  Created by Neil Edwards on 03/12/2009.
//  Copyright 2009 Chroma. All rights reserved.
//

#import "ViewUtilities.h"
#import "GlobalUtilities.h"

@implementation ViewUtilities


+(void)alignView:(UIView*)child withView:(UIView*)view :(LayoutBoxAlignMode)horizontal :(LayoutBoxAlignMode)vertical{
	
	CGRect childFrame=child.frame;
	CGRect parentFrame=view.frame;
	int xpos=childFrame.origin.x;
	int ypos=childFrame.origin.y;
	
	if (horizontal!=BUNoneLayoutMode) {
		
		if(horizontal==BUCenterAlignMode){
			xpos=round((parentFrame.size.width-childFrame.size.width)/2);
		}else if (horizontal==BURightAlignMode) {
			xpos=round(parentFrame.size.width-childFrame.size.width);
		}else if (horizontal==BULeftAlignMode) {
			xpos=0;
		}
		
	}
	
	
	if (vertical!=BUNoneLayoutMode) {
		
		if(vertical==BUCenterAlignMode){
			ypos=round((parentFrame.size.height-childFrame.size.height)/2);
		}else if (vertical==BUBottomAlignMode) {
			ypos=round(parentFrame.size.height-childFrame.size.height);
		}else if (vertical==BUTopAlignMode) {
			ypos=0;
		}
		
	}
	
	
	childFrame.origin.x=xpos;
	childFrame.origin.y=ypos;
	child.frame=childFrame;
	
}

+(void)alignView:(UIView*)child withView:(UIView*)view :(LayoutBoxAlignMode)horizontal :(LayoutBoxAlignMode)vertical :(int)inset{
	
	CGRect childFrame=child.frame;
	CGRect parentFrame=view.frame;
	int xpos=childFrame.origin.x;
	int ypos=childFrame.origin.y;
	
	if (horizontal!=BUNoneLayoutMode) {
		
		if(horizontal==BUCenterAlignMode){
			xpos=round((parentFrame.size.width-childFrame.size.width)/2);
		}else if (horizontal==BURightAlignMode) {
			xpos=round(parentFrame.size.width-childFrame.size.width-inset);
		}else if (horizontal==BULeftAlignMode) {
			xpos=inset;
		}
		
	}
	
	
	if (vertical!=BUNoneLayoutMode) {
		
		if(vertical==BUCenterAlignMode){
			ypos=round((parentFrame.size.height-childFrame.size.height)/2);
		}else if (vertical==BUBottomAlignMode) {
			ypos=round(parentFrame.size.height-childFrame.size.height-inset);
		}else if (vertical==BUTopAlignMode) {
			ypos=inset;
		}
		
	}
	
	
	childFrame.origin.x=xpos;
	childFrame.origin.y=ypos;
	child.frame=childFrame;
	
}


+(void)distributeItems:(NSArray*)items inDirection:(LayoutBoxLayoutMode)direction :(int)dimension :(int)inset{
	
	int itemdimension=0;
	
	if (direction==BUHorizontalLayoutMode) {
		UIView *item;
		for(int i=0;i<[items count];i++){
			item=[items objectAtIndex:i];
			itemdimension+=item.frame.size.width;				
		}
		int deltah;
		deltah=floor(((dimension-(inset*2))-itemdimension)/([items count]-1));
		
		if(deltah<0){
			//BetterLog(@"[ERROR] item widths exceed parent dimensions");
		}else{
			int posh=[items count]>1 ? inset : inset+((dimension-itemdimension)/2);
			for(int k=0;k<[items count];k++){
				UIView *item=[items objectAtIndex:k];
				CGRect itemFrame=item.frame;
				itemFrame.origin.x=posh;
				item.frame=itemFrame;
				posh+=(deltah+itemFrame.size.width);
				
			}
			
		}
			
		
	}else if (direction==BUVerticalLayoutMode) {
		
		for(int i=0;i<[items count];i++){
			UIView *item=[items objectAtIndex:i];
			itemdimension+=item.frame.size.height;				
		}
		int deltav;
		deltav=floor(((dimension-(inset*2))-itemdimension)/([items count]-1));
		
		if(deltav<0){
			//BetterLog(@"[ERROR] item heights exceed parent dimensions");
		}else{
			int posh=[items count]>1 ? inset : inset+((dimension-itemdimension)/2);
			for(int k=0;k<[items count];k++){
				UIView *item=[items objectAtIndex:k];
				CGRect itemFrame=item.frame;
				itemFrame.origin.y=posh;
				item.frame=itemFrame;
				posh+=(deltav+itemFrame.size.height);
				
			}
			
		}
		
	}
	
	
	
	
}




+(void)removeAllSubViewsForView:(UIView*)view{
	
	NSArray	*subviews=view.subviews;
	
	for (UIView *subview in subviews){
		[subview removeFromSuperview];
	}
	
}

@end
