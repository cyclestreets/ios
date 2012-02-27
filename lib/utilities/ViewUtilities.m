//
//  ViewUtilities.m
//  CycleStreets
//
//  Created by Neil Edwards on 03/12/2009.
//  Copyright 2009 CycleStreets.. All rights reserved.
//

#import "ViewUtilities.h"
#import "GlobalUtilities.h"
#import <QuartzCore/QuartzCore.h>

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



+(UIAlertView*)createTextEntryAlertView:(NSString*)title fieldText:(NSString*)fieldText delegate:(id)delegate{
    
    UIAlertView *prompt = [[UIAlertView alloc] initWithTitle:title 
                                                     message:@"\n\n"
                                                    delegate:delegate 
                                           cancelButtonTitle:@"Cancel" 
                                           otherButtonTitles:@"OK", nil];
    prompt.tag=kTextEntryAlertTag;
    UITextField *alertField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 50, 260.0, 25.0)]; 
    alertField.borderStyle=UITextBorderStyleRoundedRect;
    [alertField setBackgroundColor:[UIColor whiteColor]];
	[alertField setClearButtonMode:UITextFieldViewModeWhileEditing];
	if(fieldText!=nil){
		alertField.text=fieldText;
	}else{
		[alertField setPlaceholder:@"Route name"];
	}
    
    alertField.tag=kTextEntryAlertFieldTag;
    [prompt addSubview:alertField];
    
    float ver = [[[UIDevice currentDevice] systemVersion] floatValue];
    if(ver<4.0){
        CGAffineTransform moveUp = CGAffineTransformMakeTranslation(0.0, 100.0);
        [prompt setTransform: moveUp];
    }
    
    [prompt show];
    [prompt release];
    
    [alertField becomeFirstResponder];
    [alertField release];
    
    return prompt;
    
}



+(void)drawUIViewEdgeShadow:(UIView*)view atPosition:(NSString*)position{
	
	BOOL create=YES;
	CAGradientLayer *shadow;
	
	if([view.layer.sublayers count]>0){
		id layerzero=[view.layer.sublayers objectAtIndex:0];
		if([layerzero isKindOfClass:[CAGradientLayer class]]){
			shadow=[view.layer.sublayers objectAtIndex:0];
			create=NO;
		}
	}
	
	if(create==YES){
		if([position isEqualToString:BOTTOM]){
			shadow = [ViewUtilities shadowAsInverse:NO :view];
		}else{
			shadow = [ViewUtilities shadowAsInverse:YES :view];
		}
		[view.layer insertSublayer:shadow atIndex:0];
	}	
	
	CGRect shadowFrame = shadow.frame;
	shadowFrame.size.width = view.frame.size.width;
	if([position isEqualToString:BOTTOM]){
		shadowFrame.origin.y = view.frame.size.height;
	}else {
		shadowFrame.origin.y = -10;
	}
	shadow.frame = shadowFrame;
	
	
}

+(void)drawUIViewInsetShadow:(UIView*)view{
	
	BOOL create=YES;
	CAGradientLayer *topshadow;
	CAGradientLayer *bottomshadow;
	
	if([view.layer.sublayers count]>0){
		id layerzero=[view.layer.sublayers objectAtIndex:0];
		if([layerzero isKindOfClass:[CAGradientLayer class]]){
			topshadow=[view.layer.sublayers objectAtIndex:0];
			create=NO;
		}
	}
	
	if(create==YES){
		topshadow = [ViewUtilities shadowAsInverse:NO :view];
		[view.layer insertSublayer:topshadow atIndex:0];
		bottomshadow = [ViewUtilities shadowAsInverse:YES :view];
		[view.layer insertSublayer:bottomshadow atIndex:1];
	}	
	
	CGRect topShadowFrame = topshadow.frame;
	topShadowFrame.size.width = view.frame.size.width;
	topShadowFrame.origin.y = 0;
	topshadow.frame = topShadowFrame;
	
	CGRect bottomshadowFrame = bottomshadow.frame;
	bottomshadowFrame.size.width = view.frame.size.width;
	bottomshadowFrame.origin.y = view.frame.size.height-10;
	bottomshadow.frame = bottomshadowFrame;
	
}

+(void)drawInsertedViewShadow:(UIView*)view{
	
	CGRect viewframe=view.frame;
	CGFloat viewheight=viewframe.size.height;
	CGFloat viewwidth=viewframe.size.width;
	CGFloat	gradiantheight=3.0f;
	//viewheight-=4.0f; // abitrary  magic number: keep an eye on this
	CALayer	*gradiantlayer=[[CALayer alloc]init];
	gradiantlayer.frame=CGRectMake(0, 0, viewwidth, viewheight);
	if ([gradiantlayer respondsToSelector:@selector(setShadowColor:)]) {
		gradiantlayer.shadowColor = [UIColor blackColor].CGColor;
		gradiantlayer.shadowOpacity = 0.6f;
		gradiantlayer.shadowOffset = CGSizeMake(gradiantheight,gradiantheight);
		gradiantlayer.shadowRadius = 4.0f;
	}
	gradiantlayer.masksToBounds = YES;
	UIBezierPath *path = [UIBezierPath bezierPath];
	
	if ([path respondsToSelector:@selector(moveToPoint:)]  && [path respondsToSelector:@selector(addLineToPoint:)] ) {
		[path moveToPoint:CGPointMake(-10,-10)];
		[path addLineToPoint:CGPointMake(viewwidth+10, -10)];
		[path addLineToPoint:CGPointMake(viewwidth+10, 0)];
		[path addLineToPoint:CGPointMake(0, 0)];	
		[path addLineToPoint:CGPointMake(0, viewheight)];
		[path addLineToPoint:CGPointMake(-10, viewheight)];
	}
	[path closePath];
	
	if ([gradiantlayer respondsToSelector:@selector(setShadowPath:)]) {
		gradiantlayer.shadowPath = path.CGPath;
	}
	[view.layer insertSublayer:gradiantlayer atIndex:0 ];
	
}


+ (CAGradientLayer *)shadowAsInverse:(BOOL)inverse :(UIView*)view
{
	CAGradientLayer *newShadow = [[CAGradientLayer alloc] init];
	CGRect newShadowFrame =CGRectMake(0, 0, view.frame.size.width, inverse ? 10 : 10);
	newShadow.frame = newShadowFrame;
	UIColor *darkColor =UIColorFromRGBAndAlpha(0x000000,.3);
	UIColor *lightColor =UIColorFromRGBAndAlpha(0x000000,0);
	newShadow.colors =[NSArray arrayWithObjects:(inverse ? (id)[lightColor CGColor] : (id)[darkColor CGColor]),(id)(inverse ? (id)[darkColor CGColor] : (id)[lightColor CGColor]),nil];
	return newShadow;
}

@end
