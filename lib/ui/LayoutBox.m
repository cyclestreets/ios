//
//  LayoutBox.m
//  NagMe
//
//  Created by Neil Edwards on 24/11/2010.
//  Copyright 2010 buffer. All rights reserved.
//

#import "LayoutBox.h"
#import "ViewUtilities.h"

@interface LayoutBox(Private)

-(void)update;
-(void)align;
-(void)layout;
-(void)distributeItems;
-(UIView*)viewAtIndex:(int)index;

@end


@implementation LayoutBox
@synthesize items;
@synthesize layoutMode;
@synthesize alignMode;
@synthesize itemPadding;
@synthesize paddingTop;
@synthesize paddingLeft;
@synthesize paddingRight;
@synthesize paddingBottom;
@synthesize height;
@synthesize width;
@synthesize fixedHeight;
@synthesize fixedWidth;
@synthesize startColor;
@synthesize endColor;
@synthesize distribute;
@synthesize initialised;

/***********************************************************/
// dealloc
/***********************************************************/
- (void)dealloc
{
    [items release], items = nil;
    [startColor release], startColor = nil;
    [endColor release], endColor = nil;
	
    [super dealloc];
}






-(void)initialize{
	
	fixedHeight=NO;
	fixedWidth=NO;
	
	alignMode=BULeftAlignMode;
	layoutMode=BUHorizontalLayoutMode;
	
	paddingTop=0;
	paddingLeft=0;
	paddingBottom=0;
	paddingRight=0;
	itemPadding=0;
	
	distribute=NO;
	
	if(items==nil){
		items=[[NSMutableArray alloc]init];
	}
	
	if(startColor==nil){
		self.backgroundColor=[UIColor clearColor];
	}
	
	initialised=YES;
		
}

// Called when creating containe by code
- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		[self initialize];
    }
    return self;
}

// Called when container is in IB
- (id)initWithCoder:(NSCoder*)decoder {
	if (self = [super initWithCoder:decoder]) {
		[self initialize];
    }
    return self;
}




//
/***********************************************
 * @description			UIVIEW OVERRIDES
 ***********************************************/
//


-(void)addSubview:(UIView *)view{
	
	[super addSubview:view];
	// Note: for IB based instantiations, addSubView will be called for any IB subViews
	// we do not want ot execute update as this will destroy the IB frame width
	// as the fixed property defaults to NO
	if(initialised){
		[items addObject:view];
		[self update];
	}
	
}


-(void)insertSubview:(UIView *)view atIndex:(NSInteger)index{
	
	[self initialize];
	
	if(index<=[items count]){
		[super insertSubview:view atIndex:index];
		[items insertObject:view atIndex:index];
		[self update];
	}
	
}



-(void)removeSubView:(UIView *)view{
	
	int index=[self indexOfItem:view];
	
	if(index!=-1){
		if([self hasSubView:view]){
			[view removeFromSuperview];
			[items removeObjectAtIndex:index];
			[self update];
		}
	}
	
	
}

-(void)removeSubviewAtIndex:(int)index{
	
	UIView *view=[self viewAtIndex:index];
	
	if(view!=nil){
		if([self hasSubView:view])
			[view removeFromSuperview];
		[items removeObjectAtIndex:index];
		[self update];
	}
}


-(void)removeLastSubview{
	
	int index=[items count]-1;
	if(index>-1){
		UIView *view=[items objectAtIndex:index];
		if([self hasSubView:view])
			[view removeFromSuperview];
		[items removeObjectAtIndex:index];
		[self update];
	}
	
}


-(void)removeAllSubViews{
	
	for(int i=0;i<[items count];i++){
		UIView *view=[items objectAtIndex:i];
		if([self hasSubView:view])
			[view removeFromSuperview];
	}
	[items removeAllObjects];
	
}

//
/***********************************************
 * @description			END UIVIEW OVERRIDES
 ***********************************************/
//


-(void)update{
	
	[self layout];
	[self align];
	
	if(distribute){
		[self distributeItems];
	}
	
}


//
/***********************************************
 * @description			LAYOUT
 ***********************************************/
//


-(void)layout{
	
	CGFloat xpos=0+paddingLeft;
	CGFloat tempheight=0+paddingTop;
	CGFloat ypos=0+paddingTop;
	CGFloat tempwidth=0+paddingLeft;
	
	switch(layoutMode){
		
		case BUHorizontalLayoutMode:
			
			for(int i=0;i<[items count];i++){
				UIView *view=[items objectAtIndex:i];
				CGFloat w;
				
				CGRect cframe=view.frame;
				cframe.origin.x=xpos;
				w=cframe.size.width;
				xpos+=(w+itemPadding);
				cframe.origin.y=paddingTop;
				view.frame=cframe;
				tempheight=MAX(tempheight,(cframe.size.height+paddingTop+paddingBottom));
				
			}
		break;
			
		case BUVerticalLayoutMode:
			
			for(int i=0;i<[items count];i++){
				UIView *view=[items objectAtIndex:i];
				CGFloat h;
				
				CGRect cframe=view.frame;
				cframe.origin.y=ypos;
				h=cframe.size.height;
				ypos+=(h+itemPadding);
				cframe.origin.x=paddingLeft;
				view.frame=cframe;
				
				tempwidth=MAX(tempwidth,cframe.size.width);
			}
			
		break;
		
		
	}
	
	CGRect thisframe=self.frame;
	
	
	switch(layoutMode){
		
		case BUHorizontalLayoutMode:
			
			if(fixedWidth==YES){
				width=thisframe.size.width;
			}else {
				width=xpos-itemPadding+paddingRight;
			}
			
			
			
			if(fixedHeight==YES){
				height=thisframe.size.height;
			}else {
				height=tempheight+paddingTop+paddingBottom;
			}
			
		
			
		break;
		
		case BUVerticalLayoutMode:
			
			if(fixedHeight==YES){
				height=thisframe.size.height;
			}else {
				height=MAX(ypos-itemPadding+paddingBottom,0);
			}
			
			if(fixedWidth==YES){
				width=thisframe.size.width;
			}else {
				width=tempwidth+paddingLeft+paddingRight;
			}
			
		
			
	}
		
	thisframe.size.width=width;
	thisframe.size.height=height;
	self.frame=thisframe;
	
}



//
/***********************************************
 * @description			ALIGNMENT
 ***********************************************/
//


-(void)align{
	
	
	switch(layoutMode){
		
		case BUHorizontalLayoutMode:
			
			switch(alignMode){
				
				case BUCenterAlignMode:
					for(int i=0;i<[items count];i++){
						UIView *view=[items objectAtIndex:i];
						CGRect viewFrame=view.frame;
						viewFrame.origin.y=round((height-viewFrame.size.height)/2);
						view.frame=viewFrame;
					}
				break;
				
				case BUTopAlignMode:
					for(int i=0;i<[items count];i++){
						UIView *view=[items objectAtIndex:i];
						CGRect viewFrame=view.frame;
						viewFrame.origin.y=paddingTop;
						view.frame=viewFrame;
					}
					
				break;
					
				case BUBottomAlignMode:
					for(int i=0;i<[items count];i++){
						UIView *view=[items objectAtIndex:i];
						CGRect viewFrame=view.frame;
						viewFrame.origin.y=round(height-viewFrame.size.height);
						view.frame=viewFrame;
					}
				break;
			}
				
			
			
		break;
		
		case BUVerticalLayoutMode:
			
			switch(alignMode){
				
				case BUCenterAlignMode:
					
					for(int i=0;i<[items count];i++){
						UIView *view=[items objectAtIndex:i];
						CGRect viewFrame=view.frame;
						viewFrame.origin.x=round((width-viewFrame.size.width)/2)+paddingLeft;
						view.frame=viewFrame;
					}
				
				break;
				
				case BULeftAlignMode:
					
					for(int i=0;i<[items count];i++){
						UIView *view=[items objectAtIndex:i];
						CGRect viewFrame=view.frame;
						viewFrame.origin.x=paddingLeft;
						view.frame=viewFrame;
					}
				
				break;
					
				case BURightAlignMode:
					
					for(int i=0;i<[items count];i++){
						UIView *view=[items objectAtIndex:i];
						CGRect viewFrame=view.frame;
						viewFrame.origin.x=round(width-viewFrame.size.width);
						view.frame=viewFrame;
					}
				
				break;	
			}
			
			
		
		break;
	}
	
	
	
}


//
/***********************************************
 * @description			DISTRIBUTE
 ***********************************************/
//


-(void)distributeItems{
	
	[ViewUtilities distributeItems:items inDirection:layoutMode :self.frame.size.width :paddingLeft];
	
}


//
/***********************************************
 * @description			UTILITIES
 ***********************************************/
//

-(BOOL)hasSubView:(UIView*)view{
	return [view isDescendantOfView:self];
}


-(int)indexOfItem:(UIView*)view{
	
	int index=-1;
	
	for(int i=0;i<[items count];i++){
		if(view==[items objectAtIndex:i]){
			index=i;
			break;
		}
	}
	return index;
}


-(UIView*)viewAtIndex:(int)index{
	
	if(index<[items count]){
		return [items objectAtIndex:index];
	}
	return nil;
}


//
/***********************************************
 * @description			inits and lays out IB items. 
 This means you can add this class in IB add sub views and when this is called it will do the layout automatically.
 ***********************************************/
//
-(void)initFromNIB{
	
	if(items==nil){
		items=[[NSMutableArray alloc]init];
	}
	
	for(int i=0;i<[self.subviews count];i++){
		[items addObject:[self.subviews objectAtIndex:i]];
	}
	[self update];
	
}


-(void)refresh{
	[self update];
}


-(void)swapLayoutTo:(LayoutBoxLayoutMode)mode{
	if(mode!=layoutMode){
		layoutMode=mode;
		[self update];
	}
}



@end
