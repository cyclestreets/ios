//
//  LayoutBox.m
//  NagMe
//
//  Created by Neil Edwards on 24/11/2010.
//  Copyright 2010 buffer. All rights reserved.
//

#import "LayoutBox.h"
#import "ViewUtilities.h"
#import "UIColor-Expanded.h"
#import <QuartzCore/QuartzCore.h>

@interface LayoutBox(Private)

-(void)update;
-(void)align;
-(void)layout;
-(void)distributeItems;

@end


@implementation LayoutBox
@synthesize items;
@synthesize framearray;
@synthesize deferredFrameArray;
@synthesize layoutWillBeAnimated;
@synthesize deferredView;
@synthesize deferredViewFrame;
@synthesize parentScrollView;
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
@synthesize strokeColor;
@synthesize borderparams;
@synthesize showInsetShadow;
@synthesize distribute;
@synthesize initialised;
@synthesize ignoreHidden;
@synthesize delegate;
@synthesize cornerRadius;




-(void)initialize{
	
	fixedHeight=NO;
	fixedWidth=NO;
	ignoreHidden=NO;
	layoutWillBeAnimated=NO;
	
	alignMode=BULeftAlignMode;
	layoutMode=BUHorizontalLayoutMode;
	
	paddingTop=0;
	paddingLeft=0;
	paddingBottom=0;
	paddingRight=0;
	itemPadding=0;
	
	distribute=NO;
	
	if(items==nil){
		self.items=[[NSMutableArray alloc]init];
	}
	
	if(framearray==nil){
		self.framearray=[[NSMutableArray alloc]init];
	}
	
	if(startColor==nil){
		self.backgroundColor=[UIColor clearColor];
	}
	
	cornerRadius=0;
	
	showInsetShadow=NO;
	
	initialised=YES;
	
	self.clipsToBounds=YES;
	
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
	
	if(view==nil)
		return;
	
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

-(void)removeSubviewAtIndex:(NSInteger)index{
	
	UIView *view=[self viewAtIndex:index];
	
	if(view!=nil){
		if([self hasSubView:view])
			[view removeFromSuperview];
		[items removeObjectAtIndex:index];
		[self update];
	}
}


-(void)removeLastSubview{
	
	NSInteger index=[items count]-1;
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




// TESTING ONLY
/***********************************************
 * @description		prelim support for animation based remove/adds	
 ***********************************************/
//


-(void)insertSubview:(UIView *)view atIndex:(NSInteger)index animated:(BOOL)animated{
	
	
	if(initialised){
		
		if(index<=[items count]){
			
			self.deferredView=view;
			
			if(view==nil)
				return;
			
			if(animated==NO){
				
				[self insertSubview:deferredView atIndex:index];
				
				self.deferredFrameArray=nil;
				
				if([delegate respondsToSelector:@selector(layoutBoxDidCompleteAnimation:)]){
					[delegate layoutBoxDidCompleteAnimation:@"insert"];
				}
				
				if(parentScrollView!=nil)
					[parentScrollView setContentSize:CGSizeMake(width, height)];
				
			}else {
				
				
				layoutWillBeAnimated=YES;
				CGRect insertedframe=view.frame;
				CGRect targetframe=[self viewAtIndex:index].frame;
				
				switch(layoutMode){
						
					case BUVerticalLayoutMode:
						insertedframe.origin.y=targetframe.origin.y;
						
						switch(alignMode){
								
							case BUCenterAlignMode:
								insertedframe.origin.x=round((width-insertedframe.size.width)/2)+paddingLeft;
								break;
								
								
						}
						
						break;
					case BUHorizontalLayoutMode:
						insertedframe.origin.x=targetframe.origin.x;
						break;
						
				}
				
				self.deferredViewFrame=CGRectMake(insertedframe.origin.x, insertedframe.origin.y, insertedframe.size.width, insertedframe.size.height);
				
				
				switch(layoutMode){
						
					case BUVerticalLayoutMode:
						insertedframe.size.height=0;
						
						break;
					case BUHorizontalLayoutMode:
						insertedframe.size.width=0;
						break;
						
				}
				[view setFrame:insertedframe];
				
				
				[super insertSubview:view atIndex:index];
				[items insertObject:view atIndex:index];
				
				self.deferredFrameArray=[[NSMutableArray alloc]initWithCapacity:[items count]];
				
				[self refresh];
				
				
				[UIView beginAnimations:@"LAYOUTBOXANIMATEDINSERT" context:nil];
				[UIView setAnimationDuration:0.3];
				[UIView setAnimationDelegate:self];
				[UIView setAnimationDidStopSelector:@selector(deferredInsertDidFinish: finished: context:)];
				
				for(int i=0;i<[items count];i++){
					UIView *targetview=[items objectAtIndex:i];
					CGRect	newframe=[[deferredFrameArray objectAtIndex:i] CGRectValue];
					if(targetview==deferredView){
						newframe=deferredViewFrame;
					}
					targetview.frame=newframe;
				}
				
				[UIView commitAnimations];
				
			}
			
			layoutWillBeAnimated=NO;
		}
		
	}
	
}

-(void)removeViewatIndex:(NSInteger)index animated:(BOOL)animated{
	
	
	if(initialised){
		
		if(index<=[items count]){
			
			self.deferredView=[self viewAtIndex:index];
			
			if(deferredView==nil)
				return;
			
			if(animated==NO){
				
				self.deferredFrameArray=nil;
				[self removeSubView:self.deferredView];
				self.deferredView=nil;
				
				if([delegate respondsToSelector:@selector(layoutBoxDidCompleteAnimation:)]){
					[delegate layoutBoxDidCompleteAnimation:@"remove"];
				}
				
				if(parentScrollView!=nil){
					[UIView beginAnimations:@"LAYOUTBOXPARENTSCROLLLAYOUT" context:nil];
					[UIView setAnimationDuration:0.3];
					[parentScrollView setContentSize:CGSizeMake(width, height)];
					[UIView commitAnimations];
				}
				
			}else {
				
				
				deferredView.clipsToBounds=YES;
				layoutWillBeAnimated=YES;
				CGRect insertedframe=deferredView.frame;
				
				switch(layoutMode){
						
					case BUVerticalLayoutMode:
						self.deferredViewFrame=CGRectMake(insertedframe.origin.x, insertedframe.origin.y, insertedframe.size.width, 0);
						break;
					case BUHorizontalLayoutMode:
						self.deferredViewFrame=CGRectMake(insertedframe.origin.x, insertedframe.origin.y, 0, insertedframe.size.height);
						break;
						
				}
				
				
				self.deferredFrameArray=[[NSMutableArray alloc]initWithCapacity:[items count]];
				
				[self refresh];
				
				
				[UIView beginAnimations:@"LAYOUTBOXANIMATEDREMOVE" context:nil];
				[UIView setAnimationDuration:0.3];
				[UIView setAnimationDelegate:self];
				[UIView setAnimationDidStopSelector:@selector(deferredRemoveDidFinish: finished: context:)];
				
				for(int i=0;i<[items count];i++){
					UIView *targetview=[items objectAtIndex:i];
					CGRect	newframe=[[deferredFrameArray objectAtIndex:i] CGRectValue];
					if(i==index){
						newframe=deferredViewFrame;
					}
					targetview.frame=newframe;
				}
				
				[UIView commitAnimations];
				
			}
			
			layoutWillBeAnimated=NO;
		}
		
	}
	
}



-(void)deferredInsertDidFinish:(NSString*)animationID finished:(NSNumber*)finished context:(void*)context{
	
	layoutWillBeAnimated=NO;
	self.deferredFrameArray=nil;
	
	if([delegate respondsToSelector:@selector(layoutBoxDidCompleteAnimation:)]){
		[delegate layoutBoxDidCompleteAnimation:@"insert"];
	}
	
	if(parentScrollView!=nil)
		[parentScrollView setContentSize:CGSizeMake(width, height)];
}

-(void)deferredRemoveDidFinish:(NSString*)animationID finished:(NSNumber*)finished context:(void*)context{
	
	BetterLog(@"");
	
	layoutWillBeAnimated=NO;
	self.deferredFrameArray=nil;
	
	[deferredView removeFromSuperview];
	[items removeObjectIdenticalTo:deferredView];
	self.deferredView=nil;
	
	if([delegate respondsToSelector:@selector(layoutBoxDidCompleteAnimation:)]){
		[delegate layoutBoxDidCompleteAnimation:@"remove"];
	}
	
	if(parentScrollView!=nil){
		[UIView beginAnimations:@"LAYOUTBOXPARENTSCROLLLAYOUT" context:nil];
		[UIView setAnimationDuration:0.3];
		[parentScrollView setContentSize:CGSizeMake(width, height)];
		[UIView commitAnimations];
	}
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
					CGFloat w;
					
					if(layoutWillBeAnimated){
						if(view==deferredView){
							w=deferredViewFrame.size.width;
						}else {
							w=cframe.size.width;
						}
					}else {
						w=cframe.size.width;
					}
					
					xpos+=(w+itemPadding);
					cframe.origin.y=paddingTop;
					if(!layoutWillBeAnimated){
						view.frame=cframe;
					}else {
						[deferredFrameArray addObject:[NSValue valueWithCGRect:cframe]];
					}
					
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
					if(layoutWillBeAnimated){
						if(view==deferredView){
							h=deferredViewFrame.size.height;
						}else {
							h=cframe.size.height;
						}
					}else {
						h=cframe.size.height;
					}
					
					ypos+=(h+itemPadding);
					tempwidth=MAX(tempwidth,cframe.size.width);
				}
				cframe.origin.x=paddingLeft;
				if(!layoutWillBeAnimated){
					view.frame=cframe;
				}else {
					[deferredFrameArray addObject:[NSValue valueWithCGRect:cframe]];
				}
				
			}
			
			break;
			
		case BUNoneLayoutMode:
			
			for(int i=0;i<[items count];i++){
				UIView *view=[items objectAtIndex:i];
				CGRect cframe=view.frame;
				
				tempwidth=MAX(tempwidth,cframe.size.width);
				tempheight=MAX(tempheight,cframe.size.height);
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
		break;
			
		case BUNoneLayoutMode:
			
			if(fixedHeight==YES){
				height=thisframe.size.height;
			}else {
				height=tempheight;
			}
			
			if(fixedWidth==YES){
				width=thisframe.size.width;
			}else {
				width=tempwidth;
			}
			
			
			break;	
			
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
		{
			// BURightAlignMode support
			int xpos=self.width-paddingRight;
			NSInteger startindex=[items count]-1;
			//
			
			for(int i=0;i<[items count];i++){
				
				UIView *view=nil;
				if(alignMode!=BURightAlignMode){
					view=[items objectAtIndex:i];
				}else{
					view=[items objectAtIndex:startindex-i];
				}
				
				if(ignoreHidden==YES)
					skipView=view.hidden;
				
				if(skipView==NO){
					
					CGRect viewFrame;
					
					if(!layoutWillBeAnimated){
						viewFrame=view.frame;
					}else {
						viewFrame=[[deferredFrameArray objectAtIndex:i] CGRectValue];
					}
					
					switch(alignMode){
							
						case BUCenterAlignMode:
							viewFrame.origin.y=round((height-viewFrame.size.height)/2);
							break;
							
						case BUTopAlignMode:
							viewFrame.origin.y=paddingTop;
							break;
						case BUBottomAlignMode:
							viewFrame.origin.y=round(height-viewFrame.size.height);
							break;
						case BURightAlignMode:
						{
							viewFrame.origin.x=round(xpos-viewFrame.size.width);
							xpos-=(viewFrame.size.width+itemPadding);
						}
							break;	
					}
					
					
					if(!layoutWillBeAnimated){
						view.frame=viewFrame;
					}else {
						[deferredFrameArray replaceObjectAtIndex:i withObject:[NSValue valueWithCGRect:viewFrame]];
					}
				}
			}
			
		}
			break;
			
		case BUVerticalLayoutMode:
		{	
			
			
			for(int i=0;i<[items count];i++){
				UIView *view=[items objectAtIndex:i];
				
				if(ignoreHidden==YES)
					skipView=view.hidden;
				
				if(skipView==NO){
					
					CGRect viewFrame;
					
					if(!layoutWillBeAnimated){
						viewFrame=view.frame;
					}else {
						viewFrame=[[deferredFrameArray objectAtIndex:i] CGRectValue];
					}
					
					
					switch(alignMode){
							
						case BUCenterAlignMode:
							viewFrame.origin.x=round((width-viewFrame.size.width)/2)+paddingLeft;
							break;
						case BULeftAlignMode:
							viewFrame.origin.x=paddingLeft;
							break;
						case BURightAlignMode:
							viewFrame.origin.x=round((width-paddingRight)-viewFrame.size.width);
							break;
							
					}
					
					
					if(!layoutWillBeAnimated){
						view.frame=viewFrame;
					}else {
						[deferredFrameArray replaceObjectAtIndex:i withObject:[NSValue valueWithCGRect:viewFrame]];
					}
				}
				
			}
			
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


-(UIView*)viewAtIndex:(NSInteger)index{
	
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
		self.items=[[NSMutableArray alloc]init];
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


-(int)viewHeight{
    
    return height;
}

-(int)viewWidth{
    
    return width;
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
	
	if(cornerRadius>0)
		self.layer.cornerRadius=cornerRadius;
	
	if(showInsetShadow)
		[ViewUtilities drawInsertedViewShadow:self];
	
	if(strokeColor!=nil){
		[ViewUtilities drawViewBorder:self context:UIGraphicsGetCurrentContext() borderParams:borderparams strokeColor:strokeColor];
	}
}


@end
