//
//  BUPagedViewControl.m
//  WearingOff
//
//  Created by Neil Edwards on 12/12/2011.
//  Copyright (c) 2011 buffer. All rights reserved.
//

#import "BUPagedViewControl.h"
#import "GlossyGradientView.h"
#import "StyleManager.h"
#import "NSDate-Misc.h"
#import "NSDate+Helper.h"

@interface BUPagedViewControl(Private)

-(IBAction)pageUpButtonSelected:(id)sender;
-(IBAction)pageDownButtonSelected:(id)sender;
-(void)drawBackground;
-(void)drawUI;

-(void)initFromDataType;

-(void)updateItemLabelsFromIndex;

-(NSString*)formattedLabel:(id)str;

@end

@implementation BUPagedViewControl
@synthesize leftArrow;
@synthesize rightArrow;
@synthesize internalContainer;
@synthesize itemLabelContainer;
@synthesize itemLabels;
@synthesize dataProvider;
@synthesize selectedIndex;
@synthesize dataType;
@synthesize startDate;
@synthesize endDate;
@synthesize initDate;
@synthesize gradiantColor;
@synthesize fontSize;
@synthesize textColor;
@synthesize inset;
@synthesize itemWidth;
@synthesize startAtEnd;
@synthesize shouldWrapIndicies;
@synthesize delegate;
@synthesize formattingStyle;
@synthesize formatString;



- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
		
		itemWidth=170;
		inset=30;
		fontSize=12;
		shouldWrapIndicies=NO;
		selectedIndex=-1;
		startAtEnd=NO;
		self.textColor=[UIColor whiteColor];
		
		formattingStyle=NONE;
		self.internalContainer=[[LayoutBox alloc]initWithFrame:self.frame];
		internalContainer.paddingLeft=0;
		internalContainer.itemPadding=10;
		internalContainer.alignMode=BUCenterAlignMode;
		[self addSubview:internalContainer];
		
		[self drawUI];
		[self updateItems];
		
    }
    return self;
}




-(void)drawUI{
	
	[self drawBackground];
	
	// add arrow: Note images are opposite to normal allocation
	leftArrow=[UIButton buttonWithType:UIButtonTypeCustom];
	[leftArrow setImage:[[StyleManager sharedInstance] imageForType:@"UIButtonIcon_rightArrow"] forState:UIControlStateNormal];
	[leftArrow addTarget:self action:@selector(pageDownButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
	leftArrow.enabled=shouldWrapIndicies;
	leftArrow.frame=CGRectMake(0, 0, 30, 40);
	[internalContainer addSubview:leftArrow];
	
	
	self.itemLabelContainer=[[UIView alloc]initWithFrame:CGRectMake(0, 0, itemWidth, 20)];
	itemLabelContainer.clipsToBounds=YES;
	[internalContainer addSubview:itemLabelContainer];
		
	
	// add right arrow
	rightArrow=[UIButton buttonWithType:UIButtonTypeCustom];
	[rightArrow setImage:[[StyleManager sharedInstance] imageForType:@"UIButtonIcon_leftArrow"] forState:UIControlStateNormal];
	[rightArrow addTarget:self action:@selector(pageUpButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
	if([dataProvider count]>1){
		rightArrow.enabled=YES;
	}
	rightArrow.frame=CGRectMake(0, 0, 30, 40);
	[internalContainer addSubview:rightArrow];
	
	
	// align ui in frame
	[ViewUtilities alignView:internalContainer withView:self :BUCenterAlignMode :BUCenterAlignMode];
	
	
	
}


-(void)drawBackground{
	
	if (gradiantColor!=nil) {
		GlossyGradientView *bgview=[[GlossyGradientView alloc]initWithFrame:self.frame];
		bgview.glossyColor=gradiantColor;
		[bgview setNeedsDisplay];
		[self addSubview:bgview];
		[self sendSubviewToBack:bgview];
	}
	
}


-(void)updateItems{
	
	[ViewUtilities removeAllSubViewsForView:itemLabelContainer];
	
	self.itemLabels=[[NSMutableArray alloc]init];
	
	for(int i=0;i<3;i++){
		
		UILabel *itemLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, itemWidth, 20)];
		itemLabel.backgroundColor=[UIColor clearColor];
		itemLabel.font=[UIFont boldSystemFontOfSize:fontSize];
		itemLabel.textColor=textColor;
		itemLabel.textAlignment=UITextAlignmentCenter;
		itemLabel.text=@" ";
		[itemLabelContainer addSubview:itemLabel];
		[itemLabels addObject:itemLabel];
		
	}
	
	[ViewUtilities distributeItems:itemLabels inDirection:BUHorizontalLayoutMode :itemWidth*3 :0];
	
	int itemIncrement=0-itemWidth;
	for(UIView *view in itemLabels){
		CGRect vframe=view.frame;
		vframe.origin.x+=itemIncrement;
		[view setFrame:vframe];
	}
	
}


-(void)initFromDataType{
	
	switch (dataType) {
			
		case PagedHeaderDataTypeInfinite:
		{
			
			if(startDate!=nil && endDate!=nil){
				
				// create faux dataProvider
				int interval=[startDate timeIntervalSinceDate:endDate];
				NSMutableArray *arr=[[NSMutableArray alloc]init];
				int count=abs(interval/TIME_DAY)+1;
				for(int i=0;i<count;i++){
					[arr addObject:[startDate dateByAddingDays:i]];
				}
				self.dataProvider=arr;
				
				if(startAtEnd==YES){
					[self navigateToPageIndex:[dataProvider count]-1 animated:NO];
				}
				
			}
			
		}
		break;
			
		default:
		break;
	}
	
	
}


//
/***********************************************
 * @description			Item Selection
 ***********************************************/
//


-(void)incrementPage:(int)increment animated:(BOOL)animated{
	
	// do index increment
	int nextIndex=selectedIndex+increment;
	selectedIndex=nextIndex;
	
	if(shouldWrapIndicies==NO){
		
		if(selectedIndex==0){
			leftArrow.enabled=NO;
		}else{
			leftArrow.enabled=YES;
		}
		
		if(selectedIndex==([dataProvider count]-1)){
			rightArrow.enabled=NO;
		}else {
			rightArrow.enabled=YES;
		}
		
	}else {
		
		if(nextIndex<0)
			selectedIndex=[dataProvider count]-1;
		
		if (nextIndex==[dataProvider count]) 
			selectedIndex=0;
		
		rightArrow.enabled=YES;
		leftArrow.enabled=YES;
	}
	
	// new frame increments
	int itemIncrement;
	int reverseIncrement;
	if(increment==1){
		itemIncrement=0-itemWidth;
		reverseIncrement=itemWidth;
	}else{
		itemIncrement=itemWidth;
		reverseIncrement=0-itemWidth;
	}
	
	
	[UIView animateWithDuration:0.3f 
						  delay:0 
						options:UIViewAnimationCurveEaseOut 
					 animations:^{ 
						 for(UIView *view in itemLabels){
							 CGRect vframe=view.frame;
							 vframe.origin.x+=itemIncrement;
							 [view setFrame:vframe];
						 }
					 }
					 completion:^(BOOL finished){
						 for(UIView *view in itemLabels){
							 CGRect vframe=view.frame;
							 vframe.origin.x+=reverseIncrement;
							 [view setFrame:vframe];
						 }
						 [self updateItemLabelsFromIndex];
						 
					 }];
	
	
}





-(void)updateItemLabelsFromIndex{
	
	UILabel *label0=[itemLabels objectAtIndex:0];
	UILabel *label1=[itemLabels objectAtIndex:1];
	UILabel *label2=[itemLabels objectAtIndex:2];
	
	if(selectedIndex>0){
		NSDate *date=[dataProvider objectAtIndex:selectedIndex-1];
		NSString *str=[self formattedLabel:date];
		label0.text=str;
	}
	
	label1.text=[self formattedLabel:[dataProvider objectAtIndex:selectedIndex]];
	   
	if(selectedIndex<[dataProvider count]-1)
	label2.text=[self formattedLabel:[dataProvider objectAtIndex:selectedIndex+1]];
	
	 if([delegate respondsToSelector:@selector(pageControlDidIncrement:index:)]){
		 [delegate pageControlDidIncrement:[self selectedItem] index:selectedIndex];
	 }
	
}


-(id)selectedItem{
	return [dataProvider objectAtIndex:selectedIndex];
}



//
/***********************************************
 * @description			reset page control to 0
 ***********************************************/
//
-(void)resetPage{
	if(selectedIndex>0){
		int diff=0-selectedIndex;
		[self incrementPage:diff animated:YES];
	}
}

//
/***********************************************
 * @description			navigate to abitrary in bounds index
 ***********************************************/
//
-(void)navigateToPageIndex:(int)index animated:(BOOL)animated{
	
	if(index!=selectedIndex){
		if(index>=0 && index<[dataProvider count]){
			int diff=index-selectedIndex;
			[self incrementPage:diff animated:animated];
		}
	}
	
}


//
/***********************************************
 * @description			UI EVENTS
 ***********************************************/
//



-(IBAction)pageDownButtonSelected:(id)sender{
	[self incrementPage:-1 animated:YES];
}

-(IBAction)pageUpButtonSelected:(id)sender{
	[self incrementPage:1 animated:YES];
}


//
/***********************************************
 * @description			Utility
 ***********************************************/
//

-(NSString*)formattedLabel:(id)value{
	
	NSString *formattedString;
	
	if([formattingStyle isEqualToString:DATE]){
		
		NSDate *date=(NSDate*)value;
		
		formattedString=[NSDate stringFromDate:date withFormat:[NSDate usefulhumanFormatString]];
		
	}else {
		formattedString=value;
	}
	
	return formattedString;
	
}

@end
