//
//  BUFolderView.m
//  Buffer
//
//  Created by Neil Edwards on 15/03/2011.
//  Copyright 2011 Buffer. All rights reserved.
//

#import "BUFolderView.h"
#import "AppConstants.h"
#import "GlobalUtilities.h"
#import <QuartzCore/QuartzCore.h>

@interface BUFolderView(Private)

-(void)reveal;
-(void)hide;


@end


@implementation BUFolderView
@synthesize targetPoint;
@synthesize imageURL;
@synthesize textContent;
@synthesize imageView;
@synthesize textView;
@synthesize headerView;
@synthesize footerView;
@synthesize contentView;
@synthesize lowerViews;
@synthesize parentContainer;
@synthesize parentScrollView;
@synthesize collapsed;
@synthesize contentType;
@synthesize contentHeight;

/***********************************************************/
// dealloc
/***********************************************************/
- (void)dealloc
{
    imageURL = nil;
    textContent = nil;
    imageView = nil;
    textView = nil;
    headerView = nil;
    footerView = nil;
    contentView = nil;
    lowerViews = nil;
    parentContainer = nil;
    parentScrollView = nil;
	
}





- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds=YES;
		self.backgroundColor=[UIColor clearColor];
		collapsed=YES;
    }
    return self;
}


-(void)initialise{
	
	
	
	switch(contentType){
		
		case BUFolderContentTypeImage:
		{	
			imageView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:imageURL]];
			imageView.alpha=0;
            
            UIView *cv=[[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH, imageView.frame.size.height)];
			self.contentView=cv;
            
			[contentView addSubview:imageView];
			contentHeight=contentView.frame.size.height;
		}
		break;
			
		case BUFolderContentTypeTextView:
        {
			UITextView *tv=[[UITextView alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 150)];
			self.textView=tv;
			textView.editable=NO;
			textView.font=[UIFont systemFontOfSize:12];
			textView.textColor=UIColorFromRGB(0x333333);
			textView.contentInset=UIEdgeInsetsMake(30, 0, 20, 0);
			textView.scrollIndicatorInsets=UIEdgeInsetsMake(20, 0, 10, 0);
			textView.text=textContent;
			textView.contentOffset=CGPointMake(0, -20);
			textView.alpha=0;
            UIView *cv=[[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 150)];
			self.contentView=cv;
			contentView.backgroundColor=[UIColor whiteColor];
			contentHeight=150;
			[contentView addSubview:textView];
        }	
		break;
		
	}
	
	
	BUFolderViewHeader *fh=[[BUFolderViewHeader alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, contentHeight)];
	self.headerView=fh;
	headerView.targetPoint=targetPoint;
	headerView.backgroundColor=[UIColor clearColor];	
	contentView.layer.mask=headerView.layer;
	
	/// top gradient
	CGFloat	gradiantheight=6.0f;
	CGFloat viewheight=30;
	UIView	*gcontentView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 30)];
	UIView	*gradiantlayer=[[UIView alloc]initWithFrame:CGRectMake(0, -(gradiantheight*2), SCREENWIDTH, contentHeight)];
	if ([gradiantlayer.layer respondsToSelector:@selector(setShadowColor:)]) {
		gradiantlayer.layer.shadowColor = [UIColor blackColor].CGColor;
		gradiantlayer.layer.shadowOpacity = 0.5f;
		gradiantlayer.layer.shadowOffset = CGSizeMake(5, gradiantheight);
		gradiantlayer.layer.shadowRadius = 5.0f;
		
	}
	gradiantlayer.layer.masksToBounds = NO;
	UIBezierPath *path = [UIBezierPath bezierPath];
	if ([path respondsToSelector:@selector(moveToPoint:)] && [path respondsToSelector:@selector(addLineToPoint:)]) {
		[path moveToPoint:CGPointMake(-20,0)];
		[path addLineToPoint:CGPointMake(SCREENWIDTH+20, 0)];
		[path addLineToPoint:CGPointMake(SCREENWIDTH+20, viewheight)];
		[path addLineToPoint:CGPointMake(targetPoint+15, viewheight)];
		[path addLineToPoint:CGPointMake(targetPoint, viewheight/2)];
		[path addLineToPoint:CGPointMake(targetPoint-15, viewheight)];
        CGFloat leftedge=0; // YES, this is odd, just you try setting this value to plain 0 and see what happens!
		//CGFloat leftedge=targetPoint-targetPoint; // YES, this is odd, just you try setting this value to plain 0 and see what happens!
		[path addLineToPoint:CGPointMake(leftedge, viewheight)];
		[path addLineToPoint:CGPointMake(leftedge-1, contentHeight+20)]; // Again, if this line is vertical the line will not draw!
		[path addLineToPoint:CGPointMake(-20, contentHeight+20)];	
		gradiantlayer.layer.shadowPath = path.CGPath;
	}	
	[gcontentView.layer insertSublayer:gradiantlayer.layer atIndex:0];
	
	[contentView addSubview:gcontentView];
	[self addSubview:contentView];
	
	self.frame=CGRectMake(0, 0, SCREENWIDTH, 1);
	self.hidden=YES;
	
}


-(void)toggleVisibility{
	
	if(collapsed==YES){
		[self reveal];
	}else {
		[self hide];
	}

	
	
}


-(void)reveal{
	
	if(collapsed==NO)
		return;
	
	CGRect selfframe=self.frame;
	
	[UIView beginAnimations:@"CVVBUTTONANIM" context:nil];
	[UIView setAnimationDuration:0.3];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationDidStop: finished: context:)];
	
	if(collapsed==YES){
		self.hidden=NO;
		selfframe.size.height=contentHeight;
		self.frame=selfframe;
		switch(contentType){
			case BUFolderContentTypeImage:
				imageView.alpha=1;
				break;
			case BUFolderContentTypeTextView:
				textView.alpha=1;
				break;
		}	
		for(UIView *iview in lowerViews){
			CGRect iframe=iview.frame;
			iframe.origin.y+=contentHeight;
			iview.frame=iframe;
		}
	}
	
	[UIView commitAnimations];
	
	
}


-(void)hide{
	
	if(collapsed==YES)
		return;
	
	CGRect selfframe=self.frame;
	
	[UIView beginAnimations:@"CVVBUTTONANIM" context:nil];
	[UIView setAnimationDuration:0.3];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationDidStop: finished: context:)];
	
	if(collapsed==NO){
		selfframe.size.height=1;
		self.frame=selfframe;
		switch(contentType){
			case BUFolderContentTypeImage:
				imageView.alpha=0;
				break;
			case BUFolderContentTypeTextView:
				textView.alpha=0;
				break;
		}
		for(UIView *iview in lowerViews){
			CGRect iframe=iview.frame;
			iframe.origin.y-=contentHeight;
			iview.frame=iframe;
		}
		
	}
	
	[UIView commitAnimations];
	
}


-(void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context{
	
	if(collapsed==NO){
		
		self.hidden=YES;
		[parentContainer refresh];
		
		if(parentScrollView!=nil){
			[ UIView beginAnimations: nil context:nil ]; 
			[ UIView setAnimationCurve: UIViewAnimationCurveEaseOut];
			[ UIView setAnimationDuration: 0.3f ];
			[parentScrollView setContentSize:CGSizeMake(parentContainer.width, parentContainer.height)];
			[ UIView commitAnimations ];
		}
		collapsed=YES;
	}else {
		collapsed=NO;
		[parentContainer refresh];
		if(parentScrollView!=nil)
			[parentScrollView setContentSize:CGSizeMake(parentContainer.width, parentContainer.height)];
	}
	
}







@end
