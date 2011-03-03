//
//  HBox.m
//  CattleShips
//
//  Created by Neil Edwards on 18/11/2009.
//  Copyright 2009 buffer. All rights reserved.
//

#import "VBox.h"
#import "ViewUtilities.h"


@interface VBox(Private)

-(void)align;
-(void)layout;


@end

@implementation VBox
@synthesize items;
@synthesize verticalGap;
@synthesize paddingTop;
@synthesize paddingLeft;
@synthesize paddingRight;
@synthesize paddingBottom;
@synthesize alignby;
@synthesize height;
@synthesize width;
@synthesize fixedWidth;
@synthesize fixedHeight;

/***********************************************************/
// dealloc
/***********************************************************/
- (void)dealloc
{
    [items release], items = nil;
    [alignby release], alignby = nil;
	
    [super dealloc];
}




-(void)initialize{
	
	fixedWidth=NO;
	
	paddingTop=0;
	paddingLeft=0;
	paddingBottom=0;
	paddingRight=0;
	verticalGap=0;
	
	if(items==nil){
		items=[[NSMutableArray alloc]init];
	}
	self.backgroundColor=[UIColor clearColor];
	alignby=LEFT;
}



- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
		[self initialize];
    }
    return self;
}


-(void)addSubview:(UIView *)view{
	
	if(items==nil){
		items=[[NSMutableArray alloc]init];
	}
	
	[super addSubview:view];
	[items addObject:view];
	[self layout];
	
	
}


-(void)insertSubview:(UIView *)view atIndex:(NSInteger)index{
	
	if(items==nil){
		items=[[NSMutableArray alloc]init];
	}
	
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

-(void)removeSubView:(UIView *)view atIndex:(int)index{
	
	if(index<[items count] && [view isDescendantOfView:self]){
		[items removeObjectAtIndex:index];
		[self removeSubView:view atIndex:index];
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
	
	[self layout];
	
}


-(void)layout{
	
	CGFloat ypos=0+paddingTop;
	CGFloat tempwidth=0;
	
	
	
	for(int i=0;i<[items count];i++){
		UIView *view=[items objectAtIndex:i];
		CGFloat w;
		
		CGRect cframe=view.frame;
		cframe.origin.y=ypos;
		w=cframe.size.height;
		ypos+=(w+verticalGap);
		cframe.origin.x=paddingLeft;
		view.frame=cframe;
		
		tempwidth=MAX(tempwidth,cframe.size.width);
	}
	
	
	CGRect thisframe=self.frame;
	
	if(fixedHeight==YES){
		height=thisframe.size.height;
	}else {
		height=MAX(ypos-verticalGap+paddingBottom,0);
	}
	thisframe.size.height=height;

	if(fixedWidth==YES){
		width=thisframe.size.width;
	}else {
		width=tempwidth+paddingLeft+paddingRight;
	}
	thisframe.size.width=width;
	
	self.frame=thisframe;
	
	[self align];
	
}


-(void)align{
	
	
	if ([alignby isEqualToString:CENTER]) {
		
		for(int i=0;i<[items count];i++){
			UIView *view=[items objectAtIndex:i];
			CGRect viewFrame=view.frame;
			viewFrame.origin.x=round((width-viewFrame.size.width)/2)+paddingLeft;
			view.frame=viewFrame;
		}
		
	}else if ([alignby isEqualToString:LEFT]) {
		
		for(int i=0;i<[items count];i++){
			UIView *view=[items objectAtIndex:i];
			CGRect viewFrame=view.frame;
			viewFrame.origin.x=paddingLeft;
			view.frame=viewFrame;
		}
		
	}else if ([alignby isEqualToString:RIGHT]) {
		
		for(int i=0;i<[items count];i++){
			UIView *view=[items objectAtIndex:i];
			CGRect viewFrame=view.frame;
			viewFrame.origin.x=round(width-viewFrame.size.width);
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


@end
