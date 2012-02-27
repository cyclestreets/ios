//
//  LayoutBox.m
// CycleStreets
//
//  Created by Neil Edwards on 24/11/2010.
//  Copyright 2010 buffer. All rights reserved.
//

#import "LayoutBox.h"
#import "ViewUtilities.h"
#import "UIColor-Expanded.h"

@interface LayoutBox(Private)

-(void)update;
-(void)align;
-(void)layout;
-(void)distributeItems;
-(UIView*)viewAtIndex:(int)index;

@end


@implementation LayoutBox
@synthesize items;
@synthesize framearray;
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
@synthesize ignoreHidden;

/***********************************************************/
// dealloc
/***********************************************************/
- (void)dealloc
{
    [items release], items = nil;
    [framearray release], framearray = nil;
    [startColor release], startColor = nil;
    [endColor release], endColor = nil;
	
    [super dealloc];
}






-(void)initialize{
	
	fixedHeight=NO;
	fixedWidth=NO;
	ignoreHidden=NO;
	
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
	
	if(framearray==nil){
		framearray=[[NSMutableArray alloc]init];
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

-(void)addSubViewsFromArray:(NSMutableArray*)arr{
	if(initialised){
		for(int i=0;i<[arr count];i++){
			UIView *view=[arr objectAtIndex:i];
			[super addSubview:view];
			[items addObject:view];
		}
		[self update];
	}
}


-(void)insertSubview:(UIView *)view atIndex:(NSInteger)index{
	
	if(initialised){
	
		if(index<=[items count]){
			[super insertSubview:view atIndex:index];
			[items insertObject:view atIndex:index];
			[self update];
		}
		
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
	BOOL skipView=NO;
	
	switch(layoutMode){
		
		case BUHorizontalLayoutMode:
			
			for(int i=0;i<[items count];i++){
				UIView *view=[items objectAtIndex:i];
				
				if(ignoreHidden==YES)
					skipView=view.hidden;
				
				if(skipView==NO){
					CGRect cframe=view.frame;
					cframe.origin.x=xpos;
					CGFloat w=cframe.size.width;
					xpos+=(w+itemPadding);
					cframe.origin.y=paddingTop;
					view.frame=cframe;
					tempheight=MAX(tempheight,(cframe.size.height+paddingTop+paddingBottom));
				}
				
			}
		break;
			
		case BUVerticalLayoutMode:
			
			for(int i=0;i<[items count];i++){
				UIView *view=[items objectAtIndex:i];
				CGFloat h;
				
				if(ignoreHidden==YES)
					skipView=view.hidden;
				
				
					CGRect cframe=view.frame;
					cframe.origin.y=ypos;
					if(skipView==NO){
						h=cframe.size.height;
						ypos+=(h+itemPadding);
						tempwidth=MAX(tempwidth,cframe.size.width);
					}
					cframe.origin.x=paddingLeft;
					view.frame=cframe;
					
					
				
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
	
	BOOL skipView=NO;
	
	switch(layoutMode){
		
		case BUHorizontalLayoutMode:
			
			switch(alignMode){
				
				case BUCenterAlignMode:
					
					
					for(int i=0;i<[items count];i++){
						UIView *view=[items objectAtIndex:i];
						
						if(ignoreHidden==YES)
							skipView=view.hidden;
						
						if(skipView==NO){
						
							CGRect viewFrame=view.frame;
							viewFrame.origin.y=round((height-viewFrame.size.height)/2);
							view.frame=viewFrame;
						}
					}
					
					
					
					
				break;
				
				case BUTopAlignMode:
					for(int i=0;i<[items count];i++){
						UIView *view=[items objectAtIndex:i];
						
						if(ignoreHidden==YES)
							skipView=view.hidden;
						
						if(skipView==NO){
							CGRect viewFrame=view.frame;
							viewFrame.origin.y=paddingTop;
							view.frame=viewFrame;
						}
					}
					
				break;
					
				case BUBottomAlignMode:
					for(int i=0;i<[items count];i++){
						UIView *view=[items objectAtIndex:i];
						
						if(ignoreHidden==YES)
							skipView=view.hidden;
						
						if(skipView==NO){
							CGRect viewFrame=view.frame;
							viewFrame.origin.y=round(height-viewFrame.size.height);
							view.frame=viewFrame;
						}
					}
				break;
				
				case BURightAlignMode:
					if(fixedWidth==YES){
						int xpos=self.width-paddingRight;
						int startindex=[items count]-1;
						for(int i=startindex;i>-1;i--){
							UIView *view=[items objectAtIndex:i];
							
							if(ignoreHidden==YES)
								skipView=view.hidden;
							
							if(skipView==NO){
								CGRect viewFrame=view.frame;
								viewFrame.origin.x=round(xpos-view.frame.size.width);
								view.frame=viewFrame;
								xpos-=(view.frame.size.width+itemPadding);
							}
						}
					}
				break;
			}
				
			
			
		break;
		
		case BUVerticalLayoutMode:
			
			switch(alignMode){
				
				case BUCenterAlignMode:
					
					for(int i=0;i<[items count];i++){
						UIView *view=[items objectAtIndex:i];
						
						if(ignoreHidden==YES)
							skipView=view.hidden;
						
						if(skipView==NO){
							CGRect viewFrame=view.frame;
							viewFrame.origin.x=round((width-viewFrame.size.width)/2)+paddingLeft;
							view.frame=viewFrame;
						}
					}
				
				break;
				
				case BULeftAlignMode:
										
					for(int i=0;i<[items count];i++){
						UIView *view=[items objectAtIndex:i];
						
						if(ignoreHidden==YES)
							skipView=view.hidden;
						
						if(skipView==NO){
							CGRect viewFrame=view.frame;
							viewFrame.origin.x=paddingLeft;
							view.frame=viewFrame;
						}
					}
					
				
				break;
					
				case BURightAlignMode:
					
					for(int i=0;i<[items count];i++){
						UIView *view=[items objectAtIndex:i];
						
						if(ignoreHidden==YES)
							skipView=view.hidden;
						
						if(skipView==NO){
							CGRect viewFrame=view.frame;
							viewFrame.origin.x=round(width-viewFrame.size.width);
							view.frame=viewFrame;
						}
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


-(void)writeFrames{
	
	for(int i=0;i<[items count];i++){
		UIView *view=[items objectAtIndex:i];
		CGRect cframe=view.frame;
		NSLog(@"view.frame=%fx%f at %f,%f",cframe.size.width,cframe.size.height, cframe.origin.x,cframe.origin.y);
	}
	
}


#pragma mark gradiant bg support

- (void)drawRect:(CGRect)rect {
	
	if(startColor!=nil){
		
		CGContextRef currentContext = UIGraphicsGetCurrentContext();
		
		CGGradientRef glossGradient;
		CGColorSpaceRef rgbColorspace;
		size_t num_locations = 2;
		CGFloat locations[2] = { 0.0, 1.0 };
		
		// alpha will default to 1.0
		CGFloat components[8] = { startColor.red,startColor.green,startColor.blue, startColor.alpha,  // Start color, ie white
			endColor.red,endColor.green,endColor.blue, endColor.alpha }; // End color
		
		rgbColorspace = CGColorSpaceCreateDeviceRGB();
		glossGradient = CGGradientCreateWithColorComponents(rgbColorspace, components, locations, num_locations);
		
		CGRect currentBounds = self.bounds;
		CGPoint topCenter = CGPointMake(CGRectGetMidX(currentBounds), 0.0f);
		CGPoint bottomCenter = CGPointMake(CGRectGetMidX(currentBounds), CGRectGetMaxY(currentBounds));
		CGContextDrawLinearGradient(currentContext, glossGradient, topCenter, bottomCenter, 0);
		
		CGGradientRelease(glossGradient);
		CGColorSpaceRelease(rgbColorspace); 
		
	}
}


@end
