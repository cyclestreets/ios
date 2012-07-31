

#import "KBCustomTextField.h"
#import "GlobalUtilities.h"
#import "AppDelegate.h"
#import "kBContainerView.h"
#import "ViewUtilities.h"
/*
Dump of keys
 
 Found View: UIPeripheralHostView
 Found View: UIKeyboardAutomatic
 Found View: UIKeyboardImpl
 Found View: UIKeyboardLayoutStar
 Found View: UIKBKeyplaneView
 Found View: UIKBKeyView	name=NumberPad-1		representedString=1			displayString=1			displayType=NumberPad	interactionType=String	displayRowHint=Row1
 Found View: UIKBKeyView	name=NumberPad-2		representedString=2			displayString=2/ABC		displayType=NumberPad	interactionType=String	displayRowHint=Row1
 Found View: UIKBKeyView	name=NumberPad-3		representedString=3			displayString=3/DEF		displayType=NumberPad	interactionType=String	displayRowHint=Row1
 Found View: UIKBKeyView	name=NumberPad-4		representedString=4			displayString=4/GHI		displayType=NumberPad	interactionType=String	displayRowHint=Row2
 Found View: UIKBKeyView	name=NumberPad-5		representedString=5			displayString=5/JKL		displayType=NumberPad	interactionType=String	displayRowHint=Row2
 Found View: UIKBKeyView	name=NumberPad-6		representedString=6			displayString=6/MNO		displayType=NumberPad	interactionType=String	displayRowHint=Row2
 Found View: UIKBKeyView	name=NumberPad-7		representedString=7			displayString=7/PQRS	displayType=NumberPad	interactionType=String	displayRowHint=Row3
 Found View: UIKBKeyView	name=NumberPad-8		representedString=8			displayString=8/TUV		displayType=NumberPad	interactionType=String	displayRowHint=Row3
 Found View: UIKBKeyView	name=NumberPad-9		representedString=9			displayString=9/WXYZ	displayType=NumberPad	interactionType=String	displayRowHint=Row3
 Found View: UIKBKeyView	name=NumberPad-Empty	representedString=			displayString=			displayType=NumberPad	interactionType=None	displayRowHint=Row4
 Found View: UIKBKeyView	name=NumberPad-0		representedString=0			displayString=0			displayType=NumberPad	interactionType=String	displayRowHint=Row4
 Found View: UIKBKeyView	name=NumberPad-Delete	representedString=Delete	displayString=Delete	displayType=NumberPad	interactionType=Delete	displayRowHint=Row4
 
 
*/
@implementation KBCustomTextField
@synthesize kbDelegate=_kbDelegate;
@synthesize foundKeyboardview;

//=========================================================== 
// dealloc
//=========================================================== 
- (void)dealloc
{
    _kbDelegate = nil;
    foundKeyboardview = nil;
	[super dealloc];
}

/*
void dumpViews(UIView* view, NSString *text, NSString *indent) 
{
    Class cl = [view class];
    NSString *classDescription = [cl description];
    while ([cl superclass]) 
    {
        cl = [cl superclass];
        classDescription = [classDescription stringByAppendingFormat:@":%@", [cl description]];
    }
	
    if ([text compare:@""] == NSOrderedSame){
        //NSLog(@"%@ %@", classDescription, NSStringFromCGRect(view.frame));
	}else{
       // NSLog(@"%@ %@ %@", text, classDescription, NSStringFromCGRect(view.frame));
	}
    for (NSUInteger i = 0; i < [view.subviews count]; i++)
    {
        UIView *subView = [view.subviews objectAtIndex:i];
        NSString *newIndent = [[NSString alloc] initWithFormat:@"  %@", indent];
        NSString *msg = [[NSString alloc] initWithFormat:@"%@%d:", newIndent, i];
        dumpViews(subView, msg, newIndent);
        [msg release];
        [newIndent release];
    }
}
 */
-(void)bringTaggedSubViewsToFront{
	//dumpViews([[[UIApplication sharedApplication] windows] objectAtIndex:1], @"", @"");
	
}
//
- (BOOL)becomeFirstResponder
{
	BOOL ret = [super becomeFirstResponder];
	
	if (_kbDelegate)
	{
		[_kbDelegate keyboardShow:self];
	}
	else
	{
		[self modifyKeyView:@"NumberPad-Empty" display:@"." represent:@"." interaction:@"String"];
	}
	return ret;
}

//
- (BOOL)resignFirstResponder
{
	BOOL ret = [super resignFirstResponder];
    
	if (_kbDelegate)
	{
		[_kbDelegate keyboardHide:self];
	}
	else
	{
		[self modifyKeyView:@"NumberPad-Empty" display:nil represent:nil interaction:@"None"];
	}
     
	return ret;
}

//
- (void)logKeyView:(UIKBKeyView *)view
{
	/*
	NSLog(@"\tname=%@"
		  @"\trepresentedString=%@"
		  @"\tdisplayString=%@"
		  @"\tdisplayType=%@"
		  @"\tinteractionType=%@"
		  //@"\tvariantType=%@"
		  //@"\tvisible=%u"
		  //@"\tdisplayTypeHint=%d"
		  @"\tdisplayRowHint=%@"
		  //@"\toverrideDisplayString=%@"
		  //@"\tdisabled=%d"
		  //@"\thidden=%d\n"
		  
		  ,view.key.name
		  ,view.key.representedString
		  ,view.key.displayString
		  ,view.key.displayType
		  ,view.key.interactionType
		  //,view.key.variantType
		  //,view.key.visible
		  //,view.key.displayTypeHint
		  ,view.key.displayRowHint
		  //,view.key.overrideDisplayString
		  //,view.key.disabled
		  //,view.key.hidden
		  );
	 */
}

//
- (UIKBKeyView *)findKeyView:(NSString *)name inView:(UIView *)view
{
	for (UIKBKeyView *subview in view.subviews)
	{
		NSString *className = NSStringFromClass([subview class]);

//#define _LOG_KEY_VIEW
		//BetterLog(@"Found View: %@ SuperView: %@ with Tag:%i  \n", className,[subview.superview class], subview.tag);
		if ([className isEqualToString:@"UIKBKeyView"]){
            
#ifdef _LOG_KEY_VIEW
			[self logKeyView:subview];
#endif
			if (name == nil){
                return subview;
            }
                
            if([subview respondsToSelector:@selector(key)]){
                if ([subview.key.name isEqualToString:name]){
                    return subview;
                }
				
			}
		}
		else if (UIKBKeyView *subview2 = [self findKeyView:name inView:subview])
		{
			return subview2;
		}
	}
	return nil;
}

//
- (UIKBKeyView *)findKeyView:(NSString *)name
{
	if(foundKeyboardview==nil)
		self.foundKeyboardview=[ViewUtilities findKeyboardWindowInApplication];
	return [self findKeyView:name inView:foundKeyboardview];
}

//
- (UIKBKeyView *)modifyKeyView:(NSString *)name display:(NSString *)display represent:(NSString *)represent interaction:(NSString *)type
{
	UIKBKeyView *view = [self findKeyView:name];
	if (view)
	{	
        if([view respondsToSelector:@selector(key)]){
            view.key.representedString = represent;
            view.key.displayString = display;
            view.key.interactionType = type;
            [view setNeedsDisplay];
        }
	}
	return view;
}

//
- (UIKBKeyView *)addCustomButton:(NSString *)name title:(NSString *)title target:(id)target action:(SEL)action
{
	UIKBKeyView *view = [self findKeyView:name];
	if (view && view.tag==0)
	{
        KBContainerView *newView = [[KBContainerView alloc] initWithFrame:view.frame];
        
        
        CGSize templateSize		= [self doneButtonSize];
        
		UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(1, 1, templateSize.width, templateSize.height)];
		button.titleLabel.font = [UIFont boldSystemFontOfSize:17];
		[button setTitle:title forState:UIControlStateNormal];
		[button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
		[button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
		[button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
        [button setBackgroundImage:[UIImage imageNamed: @"UIKeyboard_Done_OS5_up.png"] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed: @"UIKeyboard_Done_OS5_down.png"] forState:UIControlStateHighlighted];
		[button setUserInteractionEnabled:YES];
		button.showsTouchWhenHighlighted = NO;
        [newView addSubview:button];
		[button release];
        
		[view.superview addSubview:newView];
		view.tag = (NSInteger)newView;
		[newView release];
		
	}
	return view;
}


-(void)addDotDeleteToEmpty{
	UIKBKeyView *view = [self findKeyView:@"NumberPad-Empty"];
	if (view) {
        
		KBContainerView *newView = [[KBContainerView alloc] initWithFrame:view.frame];
		
		CGSize templateSize		= [self oneButtonSize];
		CGRect tmpLeftFrame		= CGRectMake(0, 1, (templateSize.width/2),templateSize.height-1);
		CGRect tmpRightFrame	= CGRectMake((templateSize.width/2), 1, (templateSize.width/2),templateSize.height-1);

		
		UIButton *button2 = [[UIButton alloc] initWithFrame:tmpLeftFrame];
		button2.titleLabel.font = [UIFont boldSystemFontOfSize:17];
		[button2 setTitle:@"" forState:UIControlStateNormal];
		[button2 setImage:[UIImage imageNamed:@"DeviceLockKeypadDelete.png"] forState:UIControlStateNormal];
		
		[button2 setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
		[button2 setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
		
		[button2 setBackgroundImage:[ [UIImage imageNamed:@"keyLightBG.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:0 ] forState:UIControlStateNormal];
		[button2 setBackgroundImage:[ [UIImage imageNamed:@"keyDarkBG.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:0 ] forState:UIControlStateHighlighted];
		
		[button2 addTarget:self action:@selector(deletePressed:) forControlEvents:UIControlEventTouchUpInside];
		button2.showsTouchWhenHighlighted = NO;
		[button2 setUserInteractionEnabled:YES];
		[newView addSubview:button2];
        [button2 release];
		
		
		UIButton *button = [[UIButton alloc] initWithFrame:tmpRightFrame];
		button.titleLabel.font = [UIFont boldSystemFontOfSize:17];
		[button setTitle:@"." forState:UIControlStateNormal];
		[button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
		[button setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
		
		[button setBackgroundImage:[ [UIImage imageNamed:@"keyLightBG.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:0 ] forState:UIControlStateNormal];
		[button setBackgroundImage:[ [UIImage imageNamed:@"keyDarkBG.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:0 ] forState:UIControlStateHighlighted];
		
		[button addTarget:self action:@selector(dotPressed:) forControlEvents:UIControlEventTouchUpInside];
		button.showsTouchWhenHighlighted = NO;
		[newView addSubview:button];
		[button release];
		
		
		[view.superview addSubview:newView];
		view.tag = (NSInteger)newView;
		[newView release];
	}
		
}
-(void)removeDotDeleteFromEmpty{
	UIKBKeyView *view = [self findKeyView:@"NumberPad-Empty"];
	if (view)
	{
		int viewtag=view.tag;
		UIView *containerView=(UIView*)[view.superview viewWithTag:viewtag];
		[containerView removeFromSuperview];
		view.tag = 0;
	}
}
-(void)dotPressed:(id)sender{
	
	NSRange range;
	range.location=self.text.length;
	range.length=1;
	
	if([_kbDelegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)]){
		if ([_kbDelegate textField:self shouldChangeCharactersInRange:range replacementString:@"."] == YES) {
			self.text = [NSString stringWithFormat:@"%@.",self.text];
			
		}
	}
}
-(void)deletePressed:(id)sender{
	
	if([self.text length]>0){
	  self.text = [self.text substringToIndex:([self.text length]-1)] ;
	}
}
//
- (UIKBKeyView *)delCustomButton:(NSString *)name
{
	UIKBKeyView *view = [self findKeyView:name];
	if (view)
	{
		int viewtag=view.tag;
		UIView *containerView=(UIView*)[view.superview viewWithTag:viewtag];
		[containerView removeFromSuperview];
		view.tag = 0;
	}
	return view;
}
-(void)makeNarrow:(NSString *)name {
	UIKBKeyView *view = [self findKeyView:name];
	if (view)
	{
		
		/*
		for (NSObject *subObject in view.subviews)
		{
			NSString *className = NSStringFromClass([subObject class]);
			BetterLog(@"Narrow Found View: %@\n", className);
		}	
		*/
		
		CGRect tmpFrame = view.frame;
		tmpFrame.size=CGSizeMake(tmpFrame.size.width/2,tmpFrame.size.height);
		view.frame=tmpFrame;
	}
	//return view;
}

-(CGRect)oneButtonFrame{
	UIKBKeyView *view = [self findKeyView:@"NumberPad-1"];
	if (view)
	{
		CGRect tmpRect = view.frame;
		return tmpRect;
	} else {
		return CGRectZero;
	}


}
-(CGSize)oneButtonSize{
	CGSize tmpSize = [self oneButtonFrame].size;
	return tmpSize;
}


-(CGRect)doneButtonFrame{
	UIKBKeyView *view = [self findKeyView:@"NumberPad-Delete"];
	if (view)
	{
		CGRect tmpRect = view.frame;
		return tmpRect;
	} else {
		return CGRectZero;
	}
}
-(CGSize)doneButtonSize{
	CGSize tmpSize = [self doneButtonFrame].size;
	return tmpSize;
}

@end
