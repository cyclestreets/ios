//
//  RKPagedDateHeader.m
//
//
//  Created by Neil Edwards on 03/12/2009.
//  Copyright 2009 Buffer. All rights reserved.
//

#import "BUPagedViewHeader.h"
#import "GlossyGradientView.h"
#import "ViewUtilities.h"
#import "GlobalUtilities.h"
#import "StyleManager.h"
#import "AppConstants.h"

@implementation BUPagedViewHeader
@synthesize leftArrow;
@synthesize rightArrow;
@synthesize itemScroller;
@synthesize internalContainer;
@synthesize itemLabelContainer;
@synthesize dataProvider;
@synthesize selectedIndex;
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
		selectedIndex=0;
		startAtEnd=NO;
		self.textColor=[UIColor whiteColor];
		
		formattingStyle=NONE;
		self.internalContainer=[[LayoutBox alloc]initWithFrame:self.frame];
		internalContainer.paddingLeft=0;
		internalContainer.itemPadding=10;
		internalContainer.alignMode=BUCenterAlignMode;
		[self addSubview:internalContainer];
		
    }
    return self;
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


-(void)layoutSubviews{
	
	// get frame width
	
	
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
	
	// add scrol view
	self.itemScroller=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, itemWidth, 20)];
	itemScroller.pagingEnabled=YES;
	itemScroller.scrollEnabled=NO; // stops user touch scrolling
	itemScroller.showsHorizontalScrollIndicator=NO;
	
	[internalContainer addSubview:itemScroller];
	
	
	
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
	
	if(startAtEnd==YES){
		[self navigateToPageIndex:[dataProvider count]-1 animated:NO];
	}
	itemScroller.delegate = self;
	
}

-(void)updateScrollingItems{
	
	if(itemLabelContainer==nil){
		self.itemLabelContainer=[[LayoutBox alloc]init];
		itemLabelContainer.itemPadding=0;
		[itemScroller addSubview:itemLabelContainer];
	}
	
	[itemLabelContainer removeAllSubViews];
	
	// crrate items and add to itemContainer
	for(int i=0;i<[dataProvider count];i++){
		
		UILabel *itemLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, itemWidth, 20)];
		itemLabel.backgroundColor=[UIColor clearColor];
		itemLabel.font=[UIFont boldSystemFontOfSize:fontSize];
		itemLabel.textColor=textColor;
		itemLabel.textAlignment=UITextAlignmentCenter;
		itemLabel.text=[self formattedLabel:i];
		[itemLabelContainer addSubview:itemLabel];
		
	}
	
	[itemScroller setContentSize:CGSizeMake(itemLabelContainer.width, itemLabelContainer.height)];
	
	
}


-(NSString*)formattedLabel:(int)index{
	
	NSString *formattedString;
	
	if([formattingStyle isEqualToString:DATE]){
		
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		[formatter setDateFormat:formatString];
		formattedString=[formatter  stringFromDate:[dataProvider objectAtIndex:index]];
	}else {
		formattedString=[dataProvider objectAtIndex:index];
	}
	
	
	
	return formattedString;
	
}



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
	
	
	CGRect frame = itemScroller.frame;
    frame.origin.x = frame.size.width * selectedIndex;
    frame.origin.y = 0;
    [itemScroller scrollRectToVisible:frame animated:animated];
	
}

//
/***********************************************
 * @description			Delegate method
 ***********************************************/
//
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)sender{
	
	BetterLog(@"");
	
	if([delegate respondsToSelector:@selector(pageControlDidIncrement: index:)]){
		NSDate *d=[dataProvider objectAtIndex:selectedIndex];
		[delegate pageControlDidIncrement:d index:selectedIndex];
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



-(IBAction)pageDownButtonSelected:(id)sender{
	[self incrementPage:-1 animated:YES];
}

-(IBAction)pageUpButtonSelected:(id)sender{
	[self incrementPage:1 animated:YES];
}






@end
