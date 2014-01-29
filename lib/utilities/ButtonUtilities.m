//
//  ButtonUtilities.m
//  NagMe
//
//  Created by Neil Edwards on 19/08/2011.
//  Copyright 2011 buffer. All rights reserved.
//

#import "ButtonUtilities.h"
#import "UIButton+Glossy.h"
#import "StyleManager.h"
#import "GenericConstants.h"
#import "GlobalUtilities.h"
#import "UIView+Additions.h"
#import "ImageManipulator.h"

@implementation ButtonUtilities





+ (UIButton*)shinyButtonWithWidth:(NSUInteger)width height:(NSUInteger)height color:(UIColor*)color
{
	UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
	button.frame = CGRectMake(0, 0, width, height);
	
	// Configure background image(s)
	[UIButton setBackgroundToGlossyButton:button forColor:color withBorder:YES forState:UIControlStateNormal];
	[UIButton setBackgroundToGlossyButton:button forColor:[UIColor grayColor] withBorder:YES forState:UIControlStateHighlighted];
	
	// Configure title(s)
	[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[button setTitleShadowColor:[UIColor colorWithRed:.25 green:.25 blue:.25 alpha:1] forState:UIControlStateNormal];
	button.titleLabel.font=[UIFont boldSystemFontOfSize:12];
	button.titleLabel.shadowOffset=CGSizeMake(0, -1);
	// Add to TL view, and return
	return button;
}

+ (UIButton*)shinyButtonWithWidth:(NSUInteger)width height:(NSUInteger)height color:(UIColor*)color text:(NSString*)text
{
	UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
	UIFont *font=[UIFont boldSystemFontOfSize:12];
	
	CGFloat twidth=[GlobalUtilities calculateWidthOfText:text :font];
	button.frame = CGRectMake(0, 0, MAX(twidth,width), height);
	
	// Configure background image(s)
	[UIButton setBackgroundToGlossyButton:button forColor:color withBorder:YES forState:UIControlStateNormal];
	[UIButton setBackgroundToGlossyButton:button forColor:[UIColor grayColor] withBorder:YES forState:UIControlStateHighlighted];
	
	// Configure title(s)
	[button setTitle:text forState:UIControlStateNormal];
	button.titleLabel.font=font;
	[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[button setTitleShadowColor:[UIColor colorWithRed:.25 green:.25 blue:.25 alpha:1] forState:UIControlStateNormal];
	button.titleLabel.textAlignment=UITextAlignmentCenter;
	button.titleLabel.shadowOffset=CGSizeMake(0, -1);
	
	
	return button;
}


// handles text/background and background only type buttons
+(void)styleIBButton:(UIButton*)button type:(NSString*)type text:(NSString*)text{
	
	int capWidth=9;
	BOOL hasLabel=YES;
	if([text length]==0){
		capWidth=0;
		hasLabel=NO;
	}
	
	CGRect bframe=button.frame;
	if(hasLabel==YES){
		CGFloat twidth=[GlobalUtilities calculateWidthOfText:text :button.titleLabel.font];
		if(twidth>bframe.size.width){
			twidth+=10;
		}else{
			twidth=bframe.size.width;
		}
		bframe.size.width=twidth;
	}else {
		if([button.titleLabel.text length]==0){
			UIImage *image=[[StyleManager sharedInstance] imageForType:[NSString stringWithFormat:@"UIButton_%@_lo",type]];
			bframe.size=image.size;
		}else{
			CGFloat twidth=[GlobalUtilities calculateWidthOfText:button.titleLabel.text :button.titleLabel.font];
			bframe.size.width=MAX(twidth,bframe.size.width);
			capWidth=9;
		}
	}
	button.frame = bframe;
	
	// Configure background image(s)
	[button setBackgroundImage:[[[StyleManager sharedInstance] imageForType:[NSString stringWithFormat:@"UIButton_%@_lo",type]] stretchableImageWithLeftCapWidth:capWidth topCapHeight:0 ] forState:UIControlStateNormal];
	[button setBackgroundImage:[[[StyleManager sharedInstance] imageForType:[NSString stringWithFormat:@"UIButton_%@_hi",type]] stretchableImageWithLeftCapWidth:capWidth topCapHeight:0 ] forState:UIControlStateHighlighted];
	[button setBackgroundImage:[[[StyleManager sharedInstance] imageForType:[NSString stringWithFormat:@"UIButton_%@_disabled",type]] stretchableImageWithLeftCapWidth:capWidth topCapHeight:0 ] forState:UIControlStateDisabled];
	[button setBackgroundImage:[[[StyleManager sharedInstance] imageForType:[NSString stringWithFormat:@"UIButton_%@_selected",type]] stretchableImageWithLeftCapWidth:capWidth topCapHeight:0 ] forState:UIControlStateSelected];
	
	
	// Configure title(s)
	if(hasLabel){
		[button setTitle:text forState:UIControlStateNormal];
		button.titleLabel.userInteractionEnabled=NO;
		[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[button setTitleShadowColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
		button.titleLabel.textAlignment=UITextAlignmentCenter;
		button.titleLabel.shadowOffset=CGSizeMake(0, -1);
	}
}

+(void)styleFixedWidthIBButton:(UIButton*)button type:(NSString*)type text:(NSString*)text{
	
	// Configure background image(s)
	[button setBackgroundImage:[[[StyleManager sharedInstance] imageForType:[NSString stringWithFormat:@"UIButton_%@_lo",type]] stretchableImageWithLeftCapWidth:9 topCapHeight:0 ] forState:UIControlStateNormal];
	[button setBackgroundImage:[[[StyleManager sharedInstance] imageForType:[NSString stringWithFormat:@"UIButton_%@_hi",type]] stretchableImageWithLeftCapWidth:9 topCapHeight:0 ] forState:UIControlStateHighlighted];
	[button setBackgroundImage:[[[StyleManager sharedInstance] imageForType:[NSString stringWithFormat:@"UIButton_%@_disabled",type]] stretchableImageWithLeftCapWidth:9 topCapHeight:0 ] forState:UIControlStateDisabled];
	
	
	// Configure title(s)
	[button setTitle:text forState:UIControlStateNormal];
	button.titleLabel.userInteractionEnabled=NO;
	[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[button setTitleShadowColor:[UIColor grayColor] forState:UIControlStateNormal];
	button.titleLabel.textAlignment=UITextAlignmentCenter;
	button.titleLabel.shadowOffset=CGSizeMake(0, -1);
	
}

+ (void)styleIBButton:(UIButton*)button  withWidth:(NSUInteger)width type:(NSString*)type text:(NSString*)text
{
	
	CGFloat twidth=[GlobalUtilities calculateWidthOfText:text :button.titleLabel.font]+20;
	CGSize bsize=CGSizeMake(MAX(twidth,width), button.height);
	CGRect bframe=button.frame;
	bframe.size=bsize;
	button.frame=bframe;
	
	// Configure background image(s)
	[button setBackgroundImage:[[[StyleManager sharedInstance] imageForType:[NSString stringWithFormat:@"UIButton_%@_lo",type]] stretchableImageWithLeftCapWidth:9 topCapHeight:0 ] forState:UIControlStateNormal];
	[button setBackgroundImage:[[[StyleManager sharedInstance] imageForType:[NSString stringWithFormat:@"UIButton_%@_hi",type]] stretchableImageWithLeftCapWidth:9 topCapHeight:0 ] forState:UIControlStateHighlighted];
	[button setBackgroundImage:[[[StyleManager sharedInstance] imageForType:[NSString stringWithFormat:@"UIButton_%@_disabled",type]] stretchableImageWithLeftCapWidth:9 topCapHeight:0 ] forState:UIControlStateDisabled];
	
	
	// Configure title(s)
	[button setTitle:text forState:UIControlStateNormal];
	
}

+ (void)styleIBButtonWithExistingWidth:(UIButton*)button type:(NSString*)type text:(NSString*)text
{
	
	CGFloat twidth=[GlobalUtilities calculateWidthOfText:text :button.titleLabel.font]+20;
	CGSize bsize=CGSizeMake(MAX(twidth,button.width), button.height);
	CGRect bframe=button.frame;
	bframe.size=bsize;
	button.frame=bframe;
	
	// Configure background image(s)
	[button setBackgroundImage:[[[StyleManager sharedInstance] imageForType:[NSString stringWithFormat:@"UIButton_%@_lo",type]] stretchableImageWithLeftCapWidth:9 topCapHeight:0 ] forState:UIControlStateNormal];
	[button setBackgroundImage:[[[StyleManager sharedInstance] imageForType:[NSString stringWithFormat:@"UIButton_%@_hi",type]] stretchableImageWithLeftCapWidth:9 topCapHeight:0 ] forState:UIControlStateHighlighted];
	[button setBackgroundImage:[[[StyleManager sharedInstance] imageForType:[NSString stringWithFormat:@"UIButton_%@_disabled",type]] stretchableImageWithLeftCapWidth:9 topCapHeight:0 ] forState:UIControlStateDisabled];
	
	
	// Configure title(s)
	[button setTitle:text forState:UIControlStateNormal];
	
}

+ (UIButton*)UIButtonWithWidth:(NSUInteger)width height:(NSUInteger)height type:(NSString*)type text:(NSString*)text
{
	UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
	UIFont *font=[UIFont boldSystemFontOfSize:12];
	
	CGFloat twidth=[GlobalUtilities calculateWidthOfText:text :font]+20;
	button.frame = CGRectMake(0, 0, MAX(twidth,width), height);
	
	// Configure background image(s)
	[button setBackgroundImage:[[[StyleManager sharedInstance] imageForType:[NSString stringWithFormat:@"UIButton_%@_lo",type]] stretchableImageWithLeftCapWidth:9 topCapHeight:0 ] forState:UIControlStateNormal];
	[button setBackgroundImage:[[[StyleManager sharedInstance] imageForType:[NSString stringWithFormat:@"UIButton_%@_hi",type]] stretchableImageWithLeftCapWidth:9 topCapHeight:0 ] forState:UIControlStateHighlighted];
	[button setBackgroundImage:[[[StyleManager sharedInstance] imageForType:[NSString stringWithFormat:@"UIButton_%@_disabled",type]] stretchableImageWithLeftCapWidth:9 topCapHeight:0 ] forState:UIControlStateDisabled];
	
	
	// Configure title(s)
	[button setTitle:text forState:UIControlStateNormal];
	button.titleLabel.userInteractionEnabled=NO;
	button.titleLabel.font=font;
	[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[button setTitleColor:UIColorFromRGB(0xcccccc) forState:UIControlStateDisabled];
	[button setTitleShadowColor:[UIColor colorWithWhite:0.498 alpha:1.000] forState:UIControlStateNormal];
	button.titleLabel.textAlignment=UITextAlignmentCenter;
	button.titleLabel.shadowOffset=CGSizeMake(0, -0.5);
	
	
	return button;
}

// Note: These are autoreleased, do not over release!
+ (UIButton*)UIButtonWithFixedWidth:(NSUInteger)width height:(NSUInteger)height type:(NSString*)type text:(NSString*)text minFont:(int)minFont
{
	UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
	UIFont *font=[UIFont boldSystemFontOfSize:minFont];
	
	button.frame = CGRectMake(0, 0, width, height);
	
	// Configure background image(s)
	[button setBackgroundImage:[[[StyleManager sharedInstance] imageForType:[NSString stringWithFormat:@"UIButton_%@_lo",type]] stretchableImageWithLeftCapWidth:9 topCapHeight:0 ] forState:UIControlStateNormal];
	[button setBackgroundImage:[[[StyleManager sharedInstance] imageForType:[NSString stringWithFormat:@"UIButton_%@_hi",type]] stretchableImageWithLeftCapWidth:9 topCapHeight:0 ] forState:UIControlStateHighlighted];
	
	
	
	// Configure title(s)
	button.titleLabel.adjustsFontSizeToFitWidth=YES;
	[button.titleLabel setMinimumFontSize:minFont];
	[button setTitle:text forState:UIControlStateNormal];
	button.titleLabel.font=font;
	[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[button setTitleShadowColor:[UIColor colorWithRed:.25 green:.25 blue:.25 alpha:1] forState:UIControlStateNormal];
	button.titleLabel.textAlignment=UITextAlignmentCenter;
	button.titleLabel.shadowOffset=CGSizeMake(0, -1);
	
	
	return button;
}


+ (UIButton*)UIImageButtonWithWidth:(NSString*)image height:(NSUInteger)height type:(NSString*)type text:(NSString*)text
{
	UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
	button.titleEdgeInsets=UIEdgeInsetsMake(0, 10, 0, 5);
	UIFont *font=[UIFont boldSystemFontOfSize:12];
	CGFloat twidth=[GlobalUtilities calculateWidthOfText:text :font];
	//
	UIImage *iconimage=[[StyleManager sharedInstance] imageForType:image];
	[button setImage:iconimage forState:UIControlStateNormal];
	[button setImage:iconimage forState:UIControlStateHighlighted];
	twidth+=iconimage.size.width+20;
	//
	button.frame = CGRectMake(0, 0, MAX(twidth,10), height);
	//
	// Configure background image(s)
	[button setBackgroundImage:[[[StyleManager sharedInstance] imageForType:[NSString stringWithFormat:@"UIButton_%@_lo",type]] stretchableImageWithLeftCapWidth:9 topCapHeight:0 ] forState:UIControlStateNormal];
	[button setBackgroundImage:[[[StyleManager sharedInstance] imageForType:[NSString stringWithFormat:@"UIButton_%@_hi",type]] stretchableImageWithLeftCapWidth:9 topCapHeight:0 ] forState:UIControlStateHighlighted];
	
	
	// Configure title(s)
	[button setTitle:text forState:UIControlStateNormal];
	button.titleLabel.userInteractionEnabled=NO;
	button.titleLabel.font=font;
	[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[button setTitleShadowColor:[UIColor colorWithRed:.25 green:.25 blue:.25 alpha:1] forState:UIControlStateNormal];
	button.titleLabel.textAlignment=UITextAlignmentCenter;
	button.titleLabel.shadowOffset=CGSizeMake(0, -1);
	
	return button;
}


+(void)updateTitleForUIButton:(UIButton*)button withTitle:(NSString*)title{
	
	CGRect bframe=button.frame;
	
	CGFloat twidth=[GlobalUtilities calculateWidthOfText:title :button.titleLabel.font];
	
	UIImage *iconimage=button.imageView.image;
	twidth+=iconimage.size.width+20;
	bframe.size.width=MAX(twidth,10);
	
	button.frame = bframe;
	[button setTitle:title forState:UIControlStateNormal];
	
	
}

+ (UIButton*)UIIconButton:(NSString*)type  iconImage:(NSString*)iconimagename height:(NSUInteger)height width:(NSUInteger)width
{
	UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
	button.frame = CGRectMake(0, 0, width,height);
	
	if(iconimagename!=nil){
		UIImage *iconimage=[[StyleManager sharedInstance] imageForType:iconimagename];
		[button setImage:iconimage forState:UIControlStateNormal];
	}
	 
	int inset=(height-width)/2;
	button.contentEdgeInsets=UIEdgeInsetsMake(0, inset, 0, inset);
	
	//
	// Configure background image(s)
	[button setBackgroundImage:[[[StyleManager sharedInstance] imageForType:[NSString stringWithFormat:@"UIButton_%@_lo",type]] stretchableImageWithLeftCapWidth:9 topCapHeight:0 ] forState:UIControlStateNormal];
	[button setBackgroundImage:[[[StyleManager sharedInstance] imageForType:[NSString stringWithFormat:@"UIButton_%@_hi",type]] stretchableImageWithLeftCapWidth:9 topCapHeight:0 ] forState:UIControlStateHighlighted];
	[button setBackgroundImage:[[[StyleManager sharedInstance] imageForType:[NSString stringWithFormat:@"UIButton_%@_disabled",type]] stretchableImageWithLeftCapWidth:9 topCapHeight:0 ] forState:UIControlStateDisabled];
	
	
	return button;
}

+ (UIButton*)UIIconButton:(NSString*)type  iconImage:(NSString*)iconimagename height:(NSUInteger)height width:(NSUInteger)width midLeftCap:(BOOL)midLeft midTopCap:(BOOL)midTop
{
	UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
	button.frame = CGRectMake(0, 0, width,height);
	button.showsTouchWhenHighlighted=YES;
	
	if(iconimagename!=nil){
		UIImage *iconimage=[[StyleManager sharedInstance] imageForType:iconimagename];
		iconimage=[ImageManipulator newRoundCornerImage:iconimage :20 :20];
		[button setImage:iconimage forState:UIControlStateNormal];
	}
	
	
	int leftCap=9;
	int topCap=0;
	UIImage *bimage=[[StyleManager sharedInstance] imageForType:[NSString stringWithFormat:@"UIButton_%@_lo",type]];
	if(midLeft==YES){
		leftCap=(bimage.size.width-2)/2;
	}
	if(midTop==YES){
		topCap=(bimage.size.height-2)/2;
	}
	
	[button setBackgroundImage:[[[StyleManager sharedInstance] imageForType:[NSString stringWithFormat:@"UIButton_%@_lo",type]] stretchableImageWithLeftCapWidth:leftCap topCapHeight:topCap ] forState:UIControlStateNormal];
	[button setBackgroundImage:[[[StyleManager sharedInstance] imageForType:[NSString stringWithFormat:@"UIButton_%@_hi",type]] stretchableImageWithLeftCapWidth:leftCap topCapHeight:topCap ] forState:UIControlStateHighlighted];
	[button setBackgroundImage:[[[StyleManager sharedInstance] imageForType:[NSString stringWithFormat:@"UIButton_%@_disabled",type]] stretchableImageWithLeftCapWidth:leftCap topCapHeight:topCap ] forState:UIControlStateDisabled];
	
	
	return button;
}

+ (UIButton*)UIToggleButtonWithWidth:(NSUInteger)width height:(NSUInteger)height states:(NSDictionary*)stateDict
{
	UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
	button.backgroundColor=[UIColor clearColor];
	UIFont *font=[UIFont boldSystemFontOfSize:12];
	
	CGFloat twidth=[GlobalUtilities calculateWidthOfText:[[stateDict objectForKey:@"normal"] objectForKey:@"text"] :font];
	twidth+=10;
	button.frame = CGRectMake(0, 0, MAX(twidth,width), height);
	
	// Configure background image(s)
	[button setBackgroundImage:[[[StyleManager sharedInstance] imageForType:[NSString stringWithFormat:@"UIButton_%@_lo",[[stateDict objectForKey:@"normal"] objectForKey:@"type"]]] stretchableImageWithLeftCapWidth:9 topCapHeight:0 ] forState:UIControlStateNormal];
	[button setBackgroundImage:[[[StyleManager sharedInstance] imageForType:[NSString stringWithFormat:@"UIButton_%@_hi",[[stateDict objectForKey:@"highlight"] objectForKey:@"type"]]] stretchableImageWithLeftCapWidth:9 topCapHeight:0 ] forState:UIControlStateHighlighted];
	[button setBackgroundImage:[[[StyleManager sharedInstance] imageForType:[NSString stringWithFormat:@"UIButton_%@_selected",[[stateDict objectForKey:@"selected"] objectForKey:@"type"]]] stretchableImageWithLeftCapWidth:9 topCapHeight:0 ] forState:UIControlStateSelected];
	[button setBackgroundImage:[[[StyleManager sharedInstance] imageForType:[NSString stringWithFormat:@"UIButton_%@_disabled",@"grey"]] stretchableImageWithLeftCapWidth:9 topCapHeight:0 ] forState:UIControlStateDisabled];
	
	
	// Configure title(s)
	[button setTitle:[[stateDict objectForKey:@"normal"] objectForKey:@"text"] forState:UIControlStateNormal];
	[button setTitle:[[stateDict objectForKey:@"highlight"] objectForKey:@"text"] forState:UIControlStateHighlighted];
	[button setTitle:[[stateDict objectForKey:@"selected"] objectForKey:@"text"] forState:UIControlStateSelected];
	[button setTitle:[[stateDict objectForKey:@"normal"] objectForKey:@"text"] forState:UIControlStateDisabled];
	
	button.titleLabel.userInteractionEnabled=NO;
	button.titleLabel.font=font;
	NSString *defColor=[[stateDict objectForKey:@"normal"] objectForKey:@"textColor"];
	if(defColor==nil){
		[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	}else{
		[button setTitleColor:[[StyleManager sharedInstance] colorForType: [[stateDict objectForKey:@"normal"] objectForKey:@"textColor"]] forState:UIControlStateNormal];
		[button setTitleColor:[[StyleManager sharedInstance] colorForType:[[stateDict objectForKey:@"highlight"] objectForKey:@"textColor"] ]forState:UIControlStateHighlighted];
		[button setTitleColor:[[StyleManager sharedInstance] colorForType:[[stateDict objectForKey:@"selected"] objectForKey:@"textColor"] ]forState:UIControlStateSelected];
		[button setTitleColor:[[StyleManager sharedInstance] colorForType:[[stateDict objectForKey:@"normal"] objectForKey:@"textColor"] ]forState:UIControlStateDisabled];
	}
	button.titleLabel.textAlignment=UITextAlignmentCenter;
	//button.titleLabel.shadowOffset=CGSizeMake(0, 1);
	
	
	return button;
}


+ (UIButton*)UIIconButton:(NSString*)image height:(NSUInteger)height type:(NSString*)type
{
	UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
	
	UIImage *iconimage=[[StyleManager sharedInstance] imageForType:image];
	[button setImage:iconimage forState:UIControlStateNormal];
	
	
	int buttonheight=MAX(height,iconimage.size.height);
	int inset=(height-iconimage.size.width)/2;
	int buttonwidth=iconimage.size.width+(inset*2);
	
	button.frame = CGRectMake(0, 0, buttonwidth,buttonheight );
	button.contentEdgeInsets=UIEdgeInsetsMake(0, inset, 0, inset);
	
	//
	if(type!=nil){
		[button setBackgroundImage:[[[StyleManager sharedInstance] imageForType:[NSString stringWithFormat:@"UIButton_%@_lo",type]] stretchableImageWithLeftCapWidth:9 topCapHeight:0 ] forState:UIControlStateNormal];
		[button setBackgroundImage:[[[StyleManager sharedInstance] imageForType:[NSString stringWithFormat:@"UIButton_%@_hi",type]] stretchableImageWithLeftCapWidth:9 topCapHeight:0 ] forState:UIControlStateHighlighted];
		[button setBackgroundImage:[[[StyleManager sharedInstance] imageForType:[NSString stringWithFormat:@"UIButton_%@_disabled",type]] stretchableImageWithLeftCapWidth:9 topCapHeight:0 ] forState:UIControlStateDisabled];
	}
	
	
	return button;
}





+ (void)UIToggleIBButton:(UIButton*)button states:(NSDictionary*)stateDict
{
	
	CGFloat twidth=[GlobalUtilities calculateWidthOfText:[[stateDict objectForKey:@"normal"] objectForKey:@"text"] :button.titleLabel.font];
	CGRect bframe=button.frame;
	bframe.size=CGSizeMake(MAX(twidth,bframe.size.width), bframe.size.height);
	button.frame=bframe;
	
	//button.titleEdgeInsets=UIEdgeInsetsMake(0, 5, 0, 5);
	
	// Configure background image(s)
	[button setBackgroundImage:[[[StyleManager sharedInstance] imageForType:[NSString stringWithFormat:@"UIButton_%@_lo",[[stateDict objectForKey:@"normal"] objectForKey:@"type"]]] stretchableImageWithLeftCapWidth:9 topCapHeight:0 ] forState:UIControlStateNormal];
	[button setBackgroundImage:[[[StyleManager sharedInstance] imageForType:[NSString stringWithFormat:@"UIButton_%@_hi",[[stateDict objectForKey:@"highlight"] objectForKey:@"type"]]] stretchableImageWithLeftCapWidth:9 topCapHeight:0 ] forState:UIControlStateHighlighted];
	[button setBackgroundImage:[[[StyleManager sharedInstance] imageForType:[NSString stringWithFormat:@"UIButton_%@_selected",[[stateDict objectForKey:@"selected"] objectForKey:@"type"]]] stretchableImageWithLeftCapWidth:9 topCapHeight:0 ] forState:UIControlStateSelected];
	[button setBackgroundImage:[[[StyleManager sharedInstance] imageForType:[NSString stringWithFormat:@"UIButton_%@_disabled",@"grey"]] stretchableImageWithLeftCapWidth:9 topCapHeight:0 ] forState:UIControlStateDisabled];
	
	
	// Configure title(s)
	[button setTitle:[[stateDict objectForKey:@"normal"] objectForKey:@"text"] forState:UIControlStateNormal];
	[button setTitle:[[stateDict objectForKey:@"highlight"] objectForKey:@"text"] forState:UIControlStateHighlighted];
	[button setTitle:[[stateDict objectForKey:@"selected"] objectForKey:@"text"] forState:UIControlStateSelected];
	[button setTitle:[[stateDict objectForKey:@"normal"] objectForKey:@"text"] forState:UIControlStateDisabled];
	
	button.titleLabel.userInteractionEnabled=NO;
	[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	button.titleLabel.textAlignment=UITextAlignmentCenter;
	button.titleLabel.shadowOffset=CGSizeMake(0, 1);
	
	
}

+ (void)styleIBIconButton:(UIButton*)button iconimage:(NSString*)image type:(NSString*)type text:(NSString*)text align:(LayoutBoxAlignMode)alignment
{
	
	CGFloat twidth=[GlobalUtilities calculateWidthOfText:text :button.titleLabel.font];
	//
	UIImage *iconimage=[[StyleManager sharedInstance] imageForType:image];
	[button setImage:iconimage forState:UIControlStateNormal];
	
	if(alignment==BURightAlignMode){
		[button setTitleEdgeInsets:UIEdgeInsetsMake(0, -(iconimage.size.width+15), 0, 5)];
		[button setImageEdgeInsets:UIEdgeInsetsMake(0, twidth+15, 0, 5)];
	}else{
		button.titleEdgeInsets=UIEdgeInsetsMake(0, 10, 0, 5);
	}
	
	twidth+=iconimage.size.width+5;
	//
	CGRect bframe=button.frame;
	bframe.size=CGSizeMake(MAX(twidth,bframe.size.width), bframe.size.height);
	button.frame=bframe;
	//
	// Configure background image(s)
	[button setBackgroundImage:[[[StyleManager sharedInstance] imageForType:[NSString stringWithFormat:@"UIButton_%@_lo",type]] stretchableImageWithLeftCapWidth:9 topCapHeight:0 ] forState:UIControlStateNormal];
	[button setBackgroundImage:[[[StyleManager sharedInstance] imageForType:[NSString stringWithFormat:@"UIButton_%@_hi",type]] stretchableImageWithLeftCapWidth:9 topCapHeight:0 ] forState:UIControlStateHighlighted];
	
	
	// Configure title(s)
	[button setTitle:text forState:UIControlStateNormal];
	button.titleLabel.userInteractionEnabled=NO;
	[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[button setTitleShadowColor:[UIColor colorWithRed:.25 green:.25 blue:.25 alpha:1] forState:UIControlStateNormal];
	button.titleLabel.textAlignment=UITextAlignmentLeft;
	button.titleLabel.shadowOffset=CGSizeMake(0, -1);
}

+ (void)styleIBIconButtonFixedStyle:(UIButton*)button iconimage:(NSString*)image type:(NSString*)type text:(NSString*)text align:(LayoutBoxAlignMode)alignment
{
	
	
	CGFloat twidth=[GlobalUtilities calculateWidthOfText:text :button.titleLabel.font];
	//
	UIImage *iconimage=[[StyleManager sharedInstance] imageForType:image];
	[button setImage:iconimage forState:UIControlStateNormal];
	// Configure title(s)
	[button setTitle:text forState:UIControlStateNormal];
	
	twidth+=iconimage.size.width+15;
	//
	CGRect bframe=button.frame;
	bframe.size=CGSizeMake(twidth, bframe.size.height);
	button.frame=bframe;
	
	
	if(alignment==BURightAlignMode){
		[button setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 10)];
		[button setImageEdgeInsets:UIEdgeInsetsMake(2, twidth+5, 0, 5)];
	}else{
		button.titleEdgeInsets=UIEdgeInsetsMake(0, 10, 0, 5);
	}
	
	
}

+ (void)styleIBIconButton:(UIButton*)button iconimage:(NSString*)image type:(NSString*)type
{
	
	UIImage *iconimage=[[StyleManager sharedInstance] imageForType:image];
	[button setImage:iconimage forState:UIControlStateNormal];
	
	CGRect bframe=button.frame;
	int height=bframe.size.height;
	int buttonheight=MAX(height,iconimage.size.height);
	int inset=(height-iconimage.size.width)/2;
	int buttonwidth=iconimage.size.width+(inset*2);
	
	bframe.size=CGSizeMake(buttonwidth, buttonheight);
	button.frame = bframe;
	button.contentEdgeInsets=UIEdgeInsetsMake(0, inset, 0, inset);
	
	//
	// Configure background image(s)
	[button setBackgroundImage:[[[StyleManager sharedInstance] imageForType:[NSString stringWithFormat:@"UIButton_%@_lo",type]] stretchableImageWithLeftCapWidth:9 topCapHeight:0 ] forState:UIControlStateNormal];
	[button setBackgroundImage:[[[StyleManager sharedInstance] imageForType:[NSString stringWithFormat:@"UIButton_%@_hi",type]] stretchableImageWithLeftCapWidth:9 topCapHeight:0 ] forState:UIControlStateHighlighted];
	[button setBackgroundImage:[[[StyleManager sharedInstance] imageForType:[NSString stringWithFormat:@"UIButton_%@_disabled",type]] stretchableImageWithLeftCapWidth:9 topCapHeight:0 ] forState:UIControlStateDisabled];
	
	
}


+ (UIButton*)UITextButtonWithWidth:(NSUInteger)width height:(NSUInteger)height textColor:(NSString*)color text:(NSString*)text
{
	UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
	UIFont *font=[UIFont systemFontOfSize:12];
	
	CGFloat twidth=[GlobalUtilities calculateWidthOfText:text :font]+10;
	button.frame = CGRectMake(0, 0, MAX(twidth,width), height);
	
	// Configure title(s)
	[button setTitle:text forState:UIControlStateNormal];
	button.titleLabel.userInteractionEnabled=NO;
	button.titleLabel.font=font;
	[button setTitleColor:[[StyleManager sharedInstance] colorForType:color] forState:UIControlStateNormal];
	[button setTitleColor:UIColorFromRGB(0xcccccc) forState:UIControlStateDisabled];
	button.titleLabel.textAlignment=UITextAlignmentCenter;
	
	
	return button;
}

+ (UIButton*)UISimpleImageButton:(NSString*)type {
	
	UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
	
	UIImage *baseimage=[[StyleManager sharedInstance] imageForType:[NSString stringWithFormat:@"UIButton_%@_lo",type]];
	CGRect bframe=button.frame;
	bframe.size=CGSizeMake(baseimage.size.width,baseimage.size.height);
	button.frame=bframe;
	
	
	// Configure background image(s)
	[button setBackgroundImage:[[[StyleManager sharedInstance] imageForType:[NSString stringWithFormat:@"UIButton_%@_lo",type]] stretchableImageWithLeftCapWidth:9 topCapHeight:0 ] forState:UIControlStateNormal];
	[button setBackgroundImage:[[[StyleManager sharedInstance] imageForType:[NSString stringWithFormat:@"UIButton_%@_hi",type]] stretchableImageWithLeftCapWidth:9 topCapHeight:0 ] forState:UIControlStateHighlighted];
	[button setBackgroundImage:[[[StyleManager sharedInstance] imageForType:[NSString stringWithFormat:@"UIButton_%@_selected",type]] stretchableImageWithLeftCapWidth:9 topCapHeight:0 ] forState:UIControlStateSelected];
	[button setBackgroundImage:[[[StyleManager sharedInstance] imageForType:[NSString stringWithFormat:@"UIButton_%@_disabled",type]] stretchableImageWithLeftCapWidth:9 topCapHeight:0 ] forState:UIControlStateDisabled];
	
	return button;
	
}

+(void)styleIBButton:(UIButton*)button type:(NSString*)type text:(NSString*)text useFont:(BOOL)useFont{
	
	int capWidth=9;
	BOOL hasLabel=YES;
	if([text length]==0){
		capWidth=0;
		hasLabel=NO;
	}
	
	CGRect bframe=button.frame;
	if(hasLabel==YES){
		CGFloat twidth=[GlobalUtilities calculateWidthOfText:text :button.titleLabel.font];
		bframe.size.width=MAX(twidth,bframe.size.width);
	}else {
		UIImage *image=[[StyleManager sharedInstance] imageForType:[NSString stringWithFormat:@"UIButton_%@_lo",type]];
		bframe.size=image.size;
	}
	button.frame = bframe;
	
	// Configure background image(s)
	[button setBackgroundImage:[[[StyleManager sharedInstance] imageForType:[NSString stringWithFormat:@"UIButton_%@_lo",type]] stretchableImageWithLeftCapWidth:capWidth topCapHeight:0 ] forState:UIControlStateNormal];
	[button setBackgroundImage:[[[StyleManager sharedInstance] imageForType:[NSString stringWithFormat:@"UIButton_%@_hi",type]] stretchableImageWithLeftCapWidth:capWidth topCapHeight:0 ] forState:UIControlStateHighlighted];
	[button setBackgroundImage:[[[StyleManager sharedInstance] imageForType:[NSString stringWithFormat:@"UIButton_%@_disabled",type]] stretchableImageWithLeftCapWidth:capWidth topCapHeight:0 ] forState:UIControlStateDisabled];
	[button setBackgroundImage:[[[StyleManager sharedInstance] imageForType:[NSString stringWithFormat:@"UIButton_%@_selected",type]] stretchableImageWithLeftCapWidth:capWidth topCapHeight:0 ] forState:UIControlStateSelected];
	
	
	// Configure title(s)
	if(hasLabel){
		[button setTitle:text forState:UIControlStateNormal];
		button.titleLabel.userInteractionEnabled=NO;
		if(useFont==NO){
			[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
			[button setTitleShadowColor:[UIColor colorWithRed:.25 green:.25 blue:.25 alpha:1] forState:UIControlStateNormal];
			button.titleLabel.shadowOffset=CGSizeMake(0, -1);
		}
		button.titleLabel.textAlignment=UITextAlignmentCenter;
	}
}



//
/***********************************************
 * @description			V2.0  prelim
 ***********************************************/
//

+ (void)UIDefinableStyleButton:(UIButton*)button states:(NSDictionary*)stateDict buttonStyle:(UIButtonStyle)buttonStyle{
	
	NSString *keytext=[[stateDict objectForKey:@"normal"] objectForKey:@"text"];
	
	CGFloat twidth=[GlobalUtilities calculateWidthOfText:keytext :button.titleLabel.font]+20;
	CGRect bframe=button.frame;
	bframe.size=CGSizeMake(MAX(twidth,bframe.size.width), bframe.size.height);
	button.frame=bframe;
	
	
	// Configure background image(s)
	[button setBackgroundImage:[[[StyleManager sharedInstance] imageForType:[NSString stringWithFormat:@"UIButton_%@_lo",[[stateDict objectForKey:@"normal"] objectForKey:@"type"]]] stretchableImageWithLeftCapWidth:9 topCapHeight:0 ] forState:UIControlStateNormal];
	[button setBackgroundImage:[[[StyleManager sharedInstance] imageForType:[NSString stringWithFormat:@"UIButton_%@_hi",[[stateDict objectForKey:@"highlight"] objectForKey:@"type"]]] stretchableImageWithLeftCapWidth:9 topCapHeight:0 ] forState:UIControlStateHighlighted];
	[button setBackgroundImage:[[[StyleManager sharedInstance] imageForType:[NSString stringWithFormat:@"UIButton_%@_selected",[[stateDict objectForKey:@"selected"] objectForKey:@"type"]]] stretchableImageWithLeftCapWidth:9 topCapHeight:0 ] forState:UIControlStateSelected];
	[button setBackgroundImage:[[[StyleManager sharedInstance] imageForType:[NSString stringWithFormat:@"UIButton_%@_disabled",@"grey"]] stretchableImageWithLeftCapWidth:9 topCapHeight:0 ] forState:UIControlStateDisabled];
	
	button.adjustsImageWhenHighlighted=NO;
	
	// Configure title(s)
	[button setTitle:[[stateDict objectForKey:@"normal"] objectForKey:@"text"] forState:UIControlStateNormal];
	[button setTitle:[[stateDict objectForKey:@"highlight"] objectForKey:@"text"] forState:UIControlStateHighlighted];
	[button setTitle:[[stateDict objectForKey:@"selected"] objectForKey:@"text"] forState:UIControlStateSelected];
	[button setTitle:[[stateDict objectForKey:@"normal"] objectForKey:@"text"] forState:UIControlStateDisabled];
	
	button.titleLabel.userInteractionEnabled=NO;
	button.titleLabel.textAlignment=UITextAlignmentCenter;
	
	[self updateUIButton:button withStyle:buttonStyle];
	 
	 
}
	 
	

//
/***********************************************
 * @description			CONSTRUCTION METHODS
 ***********************************************/
//
+(void)updateUIButton:(UIButton*)button withStyle:(UIButtonStyle)style{
	
	switch (style) {
			
		case UIButtonStyleDark:
		{
			[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
			[button setTitleShadowColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
			button.titleLabel.shadowOffset=CGSizeMake(0, -1);
		}
		break;
			
		case UIButtonStyleLight:
		{
			[button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
			[button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
			[button setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
			button.titleLabel.shadowOffset=CGSizeMake(0, 1);
		}
		break;
			
		default:
		break;
	}
	
}






+(void)setButtonImage:(UIButton*)button  forType:(NSString*)type{
	
	[button setBackgroundImage:[[[StyleManager sharedInstance] imageForType:[NSString stringWithFormat:@"UIButton_%@_lo",type]] stretchableImageWithLeftCapWidth:9 topCapHeight:0 ] forState:UIControlStateNormal];
	[button setBackgroundImage:[[[StyleManager sharedInstance] imageForType:[NSString stringWithFormat:@"UIButton_%@_hi",type]] stretchableImageWithLeftCapWidth:9 topCapHeight:0 ] forState:UIControlStateHighlighted];
	[button setBackgroundImage:[[[StyleManager sharedInstance] imageForType:[NSString stringWithFormat:@"UIButton_%@_selected",type]] stretchableImageWithLeftCapWidth:9 topCapHeight:0 ] forState:UIControlStateSelected];
	[button setBackgroundImage:[[[StyleManager sharedInstance] imageForType:[NSString stringWithFormat:@"UIButton_%@_disabled",type]] stretchableImageWithLeftCapWidth:9 topCapHeight:0 ] forState:UIControlStateDisabled];
	
}


@end
