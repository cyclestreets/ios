//
//  UITextViewWrapperView.m
//
//
//  Created by Neil Edwards on 10/12/2010.
//  Copyright 2010 buffer. All rights reserved.
//

#import "UITextViewWrapperView.h"
#import "GlobalUtilities.h"
#import "DeviceUtilities.h"


@interface UITextViewWrapperView(Private)

-(void)initialise;


@end





@implementation UITextViewWrapperView
@synthesize textView;
@synthesize keyboardIsShown;
@synthesize viewOffSet;
@synthesize addtionalOffset;
@synthesize initalFrame;
@synthesize hasTabBar;
@synthesize dataRequiresSaving;
@synthesize delegate;
@synthesize promptLabel;
@synthesize isNewContent;

/***********************************************************/
// dealloc
/***********************************************************/
- (void)dealloc
{
    delegate = nil;
	
}


@dynamic prompt;
//=========================================================== 
//  prompt 
//=========================================================== 
- (NSString *)prompt
{
    return prompt; 
}
- (void)setPrompt:(NSString *)aPrompt
{
    if (prompt != aPrompt) {
        prompt = aPrompt;
		[self updatePromptLabel];
    }
}




-(id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
		[self initialise];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
		[self initialise];
    }
    return self;
}


-(void)initialise{
	
	
	CGRect thisframe=self.frame;
	
    EditableTextView *etv=[[EditableTextView alloc]initWithFrame:CGRectMake(0, 0, thisframe.size.width, thisframe.size.height)];

	self.textView=etv;
    textView.font=[UIFont systemFontOfSize:16];
	textView.keyboardType=UIKeyboardTypeDefault;
	textView.returnKeyType=UIReturnKeyDone;
	[self addSubview:textView];
	textView.delegate=self;
	
	addtionalOffset=0;
	hasTabBar=YES;
	isNewContent=NO;
	
	[[NSNotificationCenter defaultCenter]
	 addObserver:self
	 selector:@selector(keyboardWillShow:)
	 name:UIKeyboardWillShowNotification
	 object:nil];
	[[NSNotificationCenter defaultCenter]
	 addObserver:self
	 selector:@selector(keyboardWillHide:)
	 name:UIKeyboardWillHideNotification
	 object:nil];
	
	
	
    UILabel *label=[[UILabel alloc] initWithFrame:CGRectMake(7, 8, thisframe.size.width, textView.font.pointSize)];
    self.promptLabel=label;
	promptLabel.font=[UIFont systemFontOfSize:16];
	promptLabel.textColor=[UIColor lightGrayColor];
	promptLabel.backgroundColor=[UIColor clearColor];
	[self addSubview:promptLabel];
	promptLabel.hidden=prompt==nil;
	
}


-(void)updatePromptLabel{
	
	BOOL shouldShowPrompt=NO;
	
	if(prompt!=nil){
		if(textView.text.length==0){
			shouldShowPrompt=YES;
		}
	}
	
	promptLabel.text=prompt;
	promptLabel.hidden=!shouldShowPrompt;	
		
}


//
/***********************************************
 * @description			TEXTFIELD>VIEW RESIZING SUPPORT
 ***********************************************/
//


- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
	
	return YES;
}

- (void)textViewDidChange:(UITextView *)tv{
	
	BetterLog(@"isNewContent=%i  tvlenght=%i",isNewContent,textView.text.length);
	
	if (isNewContent==YES) {
		if(textView.text.length==0){
			dataRequiresSaving=NO;
		}
	}
	
	if([delegate respondsToSelector:@selector(textViewWrapperViewContentWasUpdated)]){
		[delegate performSelector:@selector(textViewWrapperViewContentWasUpdated)];
	}
	
	[self updatePromptLabel];
}

- (BOOL)textView:(UITextView *)tv shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
	
	if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
		return FALSE;
    }
    
	dataRequiresSaving=YES;
	
    return TRUE;
}

-(void)textViewDidEndEditing:(UITextView *)textView{
	[self updatePromptLabel];
	
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	
	UITouch *touch = [touches anyObject];
	if ([self isFirstResponder] && [touch view] != self) {
		//NSLog(@"The textView is currently being edited, and the user touched outside the text view");
		[self resignFirstResponder];
	}
}




#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
-(void)keyboardWillShow:(NSNotification*)notification{
	
    if (keyboardIsShown) {
        return;
    }
	
    NSDictionary* userInfo = [notification userInfo];
	NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
	
	NSValue* boundsValue;
    // Note this opposite way round from the Apple docs
	if([[[UIDevice currentDevice] systemVersion] floatValue]<3.2){
		boundsValue = [userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey];
	}else{
		boundsValue = [userInfo objectForKey:UIKeyboardBoundsUserInfoKey];
	}
    CGSize keyboardSize = [boundsValue CGRectValue].size;
    
    /*
    if([DeviceUtilities detectDevice]!=MODEL_IPAD_SIMULATOR){
        if(IS_DEVICE_ORIENTATION_LANDSCAPE==YES){
            keyboardSize = CGSizeMake(keyboardSize.height,keyboardSize.width);
        }
    }else{
        
    }
     */
	
	// store current offset for hide
	viewOffSet=textView.contentOffset;
    
	// resize scroll view to available viewable height
    CGRect viewFrame = textView.frame; 
	int taboffset=addtionalOffset;
	if(hasTabBar==YES)
		taboffset+=TABBARHEIGHT;
	viewFrame.size.height -= (keyboardSize.height-taboffset );
	
	//textView.disableLineDrawing=YES;
	
	//
	[UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
	[textView setFrame:viewFrame];
    [UIView commitAnimations];
	
    keyboardIsShown = YES;
}


- (void)keyboardWillHide:(NSNotification*)notification{
	
	if(!keyboardIsShown)
		return;
	
    NSDictionary* userInfo = [notification userInfo];
	NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    NSValue* boundsValue = [userInfo objectForKey:UIKeyboardBoundsUserInfoKey];
    CGSize keyboardSize = [boundsValue CGRectValue].size;
    CGRect viewFrame = textView.frame;
	
    viewFrame.size.height += (keyboardSize.height);
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
	[textView setFrame:viewFrame];
	[UIView commitAnimations];
	
	//CGRect oldFrame=CGRectMake(viewOffSet.x, viewOffSet.y, viewFrame.size.width , viewFrame.size.height );
	//[textView scrollRectToVisible:oldFrame animated:YES];
	
    keyboardIsShown = NO;
}



// internla sxfoll view delegate method
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
	BetterLog(@"");
	[textView setNeedsDisplay];
}

@end
