//
//  HBox.m
//  CattleShips
//
//  Created by Neil Edwards on 18/11/2009.
//  Copyright 2009 buffer. All rights reserved.
//

#import "HBox.h"
#import "UIColor-Expanded.h"
#import <QuartzCore/QuartzCore.h>
#import "ViewUtilities.h"


@interface HBox(Private)


-(void)align;
-(void)layout;

@end


@implementation HBox
@synthesize items;
@synthesize horizontalGap;
@synthesize paddingTop;
@synthesize paddingLeft;
@synthesize paddingRight;
@synthesize paddingBottom;
@synthesize alignby;
@synthesize horizontalAlign;
@synthesize verticalAlign;
@synthesize height;
@synthesize width;
@synthesize fixedHeight;
@synthesize fixedWidth;
@synthesize startColor;
@synthesize endColor;

/***********************************************************/
// dealloc
/***********************************************************/
- (void)dealloc
{
    [items release], items = nil;
    [alignby release], alignby = nil;
    [horizontalAlign release], horizontalAlign = nil;
    [verticalAlign release], verticalAlign = nil;
    [startColor release], startColor = nil;
    [endColor release], endColor = nil;
	
    [super dealloc];
}





-(void)initialize{
	
	fixedHeight=NO;
	fixedHeight=NO;
	
	horizontalAlign=LEFT;
	verticalAlign=TOP;
	
	paddingTop=0;
	paddingLeft=0;
	paddingBottom=0;
	paddingRight=0;
	horizontalGap=0;
	
	if(items==nil){
		items=[[NSMutableArray alloc]init];
	}
	
	if(startColor==nil){
		self.backgroundColor=[UIColor clearColor];
	}
	
	alignby=TOP;
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
		[self initialize];
    }
    return self;
}


-(void)addSubview:(UIView *)view{
	
	[super addSubview:view];
	[items addObject:view];
	[self layout];
		
}


-(void)insertSubview:(UIView *)view atIndex:(NSInteger)index{
	
	[super insertSubview:view atIndex:index];
	[items insertObject:view atIndex:index];
	[self layout];
	
}


-(void)removeSubView:(UIView *)view{
	
	int index=-1;
	// no getchild for obj c
	for(int i=0;i<[items count];i++){
		if(view==[items objectAtIndex:i]){
			index=i;
			break;
		}
	}
	
	if(index!=-1){
		if([view isDescendantOfView:self]){
			[view removeFromSuperview];
			[items removeObjectAtIndex:index];
			[self layout];
		}
	}
	
	
}

-(void)removeSubViewatIndex:(int)index{
	
	if(index<[items count]){
		
		[self removeSubViewatIndex:index];
		[items removeObjectAtIndex:index];
		
		[self layout];
	}
	
}


-(void)removeLastSubview{
	
	int index=[items count]-1;
	if(index>-1){
		UIView *view=[items objectAtIndex:index];
		[view removeFromSuperview];
		[items removeObjectAtIndex:index];
		[self layout];
	}
	
}


-(void)removeAllSubViews{
	
	for(int i=0;i<[items count];i++){
		UIView *view=[items objectAtIndex:i];
		[view removeFromSuperview];
	}
	[items removeAllObjects];
	
}


-(void)layout{
	
	CGFloat xpos=0+paddingLeft;
	CGFloat tempheight=paddingTop;
	
	for(int i=0;i<[items count];i++){
		UIView *view=[items objectAtIndex:i];
		CGFloat h;
		
		CGRect cframe=view.frame;
		cframe.origin.x=xpos;
		h=cframe.size.width;
		xpos+=(h+horizontalGap);
		cframe.origin.y=paddingTop;
		view.frame=cframe;
		tempheight=MAX(tempheight,(cframe.size.height+paddingTop+paddingBottom));
		
	}
	
	CGRect thisframe=self.frame;
	
	if(fixedWidth==YES){
		width=thisframe.size.width;
	}else {
		width=xpos-horizontalGap+paddingRight;
	}
	thisframe.size.width=width;
	
	
	if(fixedHeight==YES){
		height=thisframe.size.height;
	}else {
		height=tempheight+paddingTop+paddingBottom;
	}
	thisframe.size.height=height;
	
	self.frame=thisframe;
	super.frame=thisframe;
	
	[self align];
	
}


-(void)align{
	
	
	if ([alignby isEqualToString:CENTER]) {
		
		for(int i=0;i<[items count];i++){
			UIView *view=[items objectAtIndex:i];
			CGRect viewFrame=view.frame;
			viewFrame.origin.y=round((height-viewFrame.size.height)/2);
			view.frame=viewFrame;
		}
		
	}else if ([alignby isEqualToString:TOP]) {
		
		for(int i=0;i<[items count];i++){
			UIView *view=[items objectAtIndex:i];
			CGRect viewFrame=view.frame;
			viewFrame.origin.y=paddingTop;
			view.frame=viewFrame;
		}
		
	}else if ([alignby isEqualToString:BOTTOM]) {
		
		for(int i=0;i<[items count];i++){
			UIView *view=[items objectAtIndex:i];
			CGRect viewFrame=view.frame;
			viewFrame.origin.y=round(height-viewFrame.size.height);
			view.frame=viewFrame;
		}
	}
	
	
}



-(void)refresh{
	[self layout];
}




-(BOOL)hasSubView:(UIView*)view{
	return [view isDescendantOfView:self];
}


-(void)loadFromIB{
	
	if(items==nil){
		items=[[NSMutableArray alloc]init];
	}
	
	for(int i=0;i<[self.subviews count];i++){
		[items addObject:[self.subviews objectAtIndex:i]];
	}
	[self layout];
	
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
