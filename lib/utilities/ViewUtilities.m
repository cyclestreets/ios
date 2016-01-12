//
//  ViewUtilities.m
//
//
//  Created by Neil Edwards on 03/12/2009.
//  Copyright 2009 Buffer. All rights reserved.
//

#import "ViewUtilities.h"
#import "GlobalUtilities.h"
#import <QuartzCore/QuartzCore.h>
#import "GenericConstants.h"
#import "AppDelegate.h"
#import "UIView+Additions.h"

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

+(void)alignView:(UIView*)child withView:(UIView*)view :(LayoutBoxAlignMode)horizontal :(LayoutBoxAlignMode)vertical :(int)inset{
	
	CGRect childFrame=child.frame;
	CGRect parentFrame=view.frame;
	int xpos=childFrame.origin.x;
	int ypos=childFrame.origin.y;
	
	if (horizontal!=BUNoneAlignMode) {
		
		if(horizontal==BUCenterAlignMode){
			xpos=round((parentFrame.size.width-childFrame.size.width)/2);
		}else if (horizontal==BURightAlignMode) {
			xpos=round(parentFrame.size.width-childFrame.size.width-inset);
		}else if (horizontal==BULeftAlignMode) {
			xpos=inset;
		}
		
	}
	
	
	if (vertical!=BUNoneAlignMode) {
		
		if(vertical==BUCenterAlignMode){
			ypos=round((parentFrame.size.height-childFrame.size.height)/2);
		}else if (vertical==BUBottomAlignMode) {
			ypos=round(parentFrame.size.height-childFrame.size.height-inset);
		}else if (vertical==BUTopAlignMode) {
			ypos=inset;
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
		int deltah=0;
		if([items count]>1)
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
		int deltav=0;
		if([items count]>1)
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



+(void)alignView:(UIView*)child inRect:(CGRect)targetRect :(LayoutBoxAlignMode)horizontal :(LayoutBoxAlignMode)vertical{
	
	CGRect childFrame=child.frame;
	CGRect parentFrame=targetRect;
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



+(void)removeAllSubViewsForView:(UIView*)view{
	
	NSArray	*subviews=view.subviews;
	
	for (UIView *subview in subviews){
		[subview removeFromSuperview];
	}
	
}


+ (void)setTransformForCurrentOrientation:(UIView*)view {
	
	UIInterfaceOrientation orientation = (UIInterfaceOrientation)[UIApplication sharedApplication].statusBarOrientation;
	NSInteger degrees = 0;
	
	BetterLog(@"orientation=%li",orientation);
	
	if (UIInterfaceOrientationIsLandscape(orientation)) {
		if (orientation == UIInterfaceOrientationLandscapeLeft) { degrees = -90; } 
		else { degrees = 90; }
	} else {
		if (orientation == UIInterfaceOrientationPortraitUpsideDown) { degrees = 180; } 
		else { degrees = 0; }
	}
	
	view.transform = CGAffineTransformMakeRotation(RADIANS(degrees));
	
}

+ (id) loadInstanceOfView:(Class)className fromNibNamed:(NSString *)name {
	id obj = nil;
	NSArray *arr = [[NSBundle mainBundle] loadNibNamed:name owner:nil options:nil];
	for (id currentObject in arr) {
		if ([currentObject isKindOfClass:className]) {
			obj = currentObject;
			break;
		}
	}
	return obj;
}

+ (id) loadInstanceOfView:(Class)className fromNibNamed:(NSString *)name forOwner:(id)owner {
	id obj = nil;
	NSArray *arr = [[NSBundle mainBundle] loadNibNamed:name owner:owner options:nil];
	for (id currentObject in arr) {
		if ([currentObject isKindOfClass:className]) {
			obj = currentObject;
			break;
		}
	}
	return obj;
}


+ (UIInterfaceOrientation)stringtoUIInterfaceOrientation:(NSString*)stringType {
    
	if([stringType isEqualToString:@"UIInterfaceOrientationPortrait"]){
		return UIInterfaceOrientationPortrait;
	}else if ([stringType isEqualToString:@"UIInterfaceOrientationPortraitUpsideDown"]){
		return UIInterfaceOrientationPortraitUpsideDown;
	}else if ([stringType isEqualToString:@"UIInterfaceOrientationLandscapeLeft"]) {
		return UIInterfaceOrientationLandscapeLeft;
	}else if ([stringType isEqualToString:@"UIInterfaceOrientationLandscapeRight"]) {
		return UIInterfaceOrientationLandscapeRight;
	}
    return UIInterfaceOrientationPortrait;
}

+(BOOL)interfaceOrientationIsSupportedInOrientationStrings:(NSArray*)orientationArray withOrientation:(UIInterfaceOrientation)interfaceOrientation{
    
    for(NSString *orientation in orientationArray){
        UIInterfaceOrientation io=[ViewUtilities stringtoUIInterfaceOrientation:orientation];
        if(io==interfaceOrientation){
            return YES;
        }
    }
    return NO;
    
}

#define kPasswordAlertTag 999111
#define kPasswordAlertFieldTag 999112
+(UIAlertView*)createPasswordPromptView:(id)delegate{
    
    UIAlertView *prompt = [[UIAlertView alloc] initWithTitle:@"Enter your password" 
                                                     message:@"\n\n"
                                                    delegate:delegate 
                                           cancelButtonTitle:@"Cancel" 
                                           otherButtonTitles:@"Enter", nil];
    prompt.tag=kPasswordAlertTag;
    UITextField *alertPasswordField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 50, 260.0, 25.0)]; 
    alertPasswordField.borderStyle=UITextBorderStyleRoundedRect;
    [alertPasswordField setBackgroundColor:[UIColor whiteColor]];
    [alertPasswordField setPlaceholder:@"Password"];
    [alertPasswordField setSecureTextEntry:YES];
    alertPasswordField.tag=kPasswordAlertFieldTag;
    [prompt addSubview:alertPasswordField];
    
    float ver = [[[UIDevice currentDevice] systemVersion] floatValue];
    if(ver<4.0){
        CGAffineTransform moveUp = CGAffineTransformMakeTranslation(0.0, 100.0);
        [prompt setTransform: moveUp];
    }
    
    [prompt show];
    
    [alertPasswordField becomeFirstResponder];
    
    return prompt;
    
}

+(void)createPDFfromUIView:(UIView*)aView saveToDocumentsWithFileName:(NSString*)aFilename
{
    // Creates a mutable data object for updating with binary data, like a byte array
    NSMutableData *pdfData = [NSMutableData data];
	
    // Points the pdf converter to the mutable data object and to the UIView to be converted
    UIGraphicsBeginPDFContextToData(pdfData, aView.bounds, nil);
    UIGraphicsBeginPDFPage();
    CGContextRef pdfContext = UIGraphicsGetCurrentContext();
	
	
    // draws rect to the view and thus this is captured by UIGraphicsBeginPDFContextToData
	
    [aView.layer renderInContext:pdfContext];
	
    // remove PDF rendering context
    UIGraphicsEndPDFContext();
	
    // Retrieves the document directories from the iOS device
    NSArray* documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
	
    NSString* documentDirectory = [documentDirectories objectAtIndex:0];
    NSString* documentDirectoryFilename = [documentDirectory stringByAppendingPathComponent:aFilename];
	
    // instructs the mutable data object to write its context to a file on disk
    [pdfData writeToFile:documentDirectoryFilename atomically:YES];
    NSLog(@"documentDirectoryFileName: %@",documentDirectoryFilename);
}


+(void)drawUIViewEdgeShadow:(UIView*)view{
	
	[ViewUtilities drawUIViewEdgeShadow:view withHeight:10];
	
}

+(void)drawUIViewEdgeShadow:(UIView*)view withHeight:(int)height{
	
	
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
		shadow = [ViewUtilities shadowAsInverse:NO :view withheight:height];
		[view.layer insertSublayer:shadow atIndex:0];
	}
	
	CGRect shadowFrame = shadow.frame;
	shadowFrame.size.width = view.frame.size.width;
	shadowFrame.origin.y = view.frame.size.height;
	shadow.frame = shadowFrame;
	
}

+(void)drawUIViewEdgeShadow:(UIView*)view atTop:(BOOL)top withHeight:(int)height{
	
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
		shadow = [ViewUtilities shadowAsInverse:top :view withheight:height];
		[view.layer insertSublayer:shadow atIndex:0];
	}
	
	CGRect shadowFrame = shadow.frame;
	shadowFrame.size.width = view.frame.size.width;
	if(top==YES){
		shadowFrame.origin.y = 0-shadow.frame.size.height;
	}else{
		shadowFrame.origin.y = view.frame.size.height;
	}
	
	shadow.frame = shadowFrame;
	
}

+(void)drawUIViewEdgeShadow:(UIView*)view atTop:(BOOL)top{
	
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
		shadow = [ViewUtilities shadowAsInverse:top :view];
		[view.layer insertSublayer:shadow atIndex:0];
	}	
	
	CGRect shadowFrame = shadow.frame;
	shadowFrame.size.width = view.frame.size.width;
	if(top==YES){
		shadowFrame.origin.y = 0-shadow.frame.size.height;
	}else{
		shadowFrame.origin.y = view.frame.size.height;
	}
	
	shadow.frame = shadowFrame;
	
	
}

+(void)drawUIViewInsetShadow:(UIView*)view{
	
	BOOL create=YES;
	CAGradientLayer *topshadow;
	
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
	}	
	
	CGRect topShadowFrame = topshadow.frame;
	topShadowFrame.size.width = view.frame.size.width;
	topShadowFrame.origin.y = 0;
	topshadow.frame = topShadowFrame;
	
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

+ (CAGradientLayer *)shadowAsInverse:(BOOL)inverse :(UIView*)view withheight:(int)height
{
	CAGradientLayer *newShadow = [[CAGradientLayer alloc] init];
	CGRect newShadowFrame =CGRectMake(0, 0, view.frame.size.width, inverse ? height : height);
	newShadow.frame = newShadowFrame;
	UIColor *darkColor =UIColorFromRGBAndAlpha(0x000000,.3);
	UIColor *lightColor =UIColorFromRGBAndAlpha(0x000000,0);
	newShadow.colors =[NSArray arrayWithObjects:(inverse ? (id)[lightColor CGColor] : (id)[darkColor CGColor]),(id)(inverse ? (id)[darkColor CGColor] : (id)[lightColor CGColor]),nil];
	return newShadow;
}



+(UIWindow*)findKeyboardWindowInApplication{
	
	
	UIView *foundKeyboard = nil;
	UIWindow *keyboardWindow=nil;
	
	//Check each window in our application
	NSArray *windows=[[UIApplication sharedApplication] windows];
	for (UIWindow *tempWindow in windows) {
		
		for (__strong UIView *possibleKeyboard in [tempWindow subviews]) {
			
			// iOS 4 sticks the UIKeyboard inside a UIPeripheralHostView.
			if ([[possibleKeyboard description] hasPrefix:@"<UIPeripheralHostView"]) {
				possibleKeyboard = [[possibleKeyboard subviews] objectAtIndex:0];
			}                                                                                
			
			if ([[possibleKeyboard description] hasPrefix:@"<UIKeyboard"]) {
				foundKeyboard = possibleKeyboard;
				break;
			}
		}
		
		if(foundKeyboard!=nil){
			keyboardWindow=tempWindow;
			break;
		}
	}
	
	return keyboardWindow;
	
}

+(UIView*)findKeyboardViewInApplication{
	
	
	UIView *foundKeyboard = nil;
	
	//Check each window in our application
	for (UIWindow *tempWindow in [[UIApplication sharedApplication] windows]) {
		
		
		for (__strong UIView *possibleKeyboard in [tempWindow subviews]) {
			
			// iOS 4 sticks the UIKeyboard inside a UIPeripheralHostView.
			if ([[possibleKeyboard description] hasPrefix:@"<UIPeripheralHostView"]) {
				possibleKeyboard = [[possibleKeyboard subviews] objectAtIndex:0];
			}                                                                                
			
			if ([[possibleKeyboard description] hasPrefix:@"<UIKeyboard"]) {
				foundKeyboard = possibleKeyboard;
				break;
			}
		}
		
		if(foundKeyboard!=nil)
			break;
	}
	
	return foundKeyboard;
	
}


+(void)drawViewBorder:(UIView*)view context:(CGContextRef)context borderParams:(BorderParams)params strokeColor:(UIColor*)strokeColor    {
	
	
	CGContextSetStrokeColorWithColor(context, strokeColor.CGColor);
	
	
	CGRect rrect=view.frame;
	CGFloat minx = 0.0;
	CGFloat maxx = rrect.size.width;
    CGFloat miny = 0.0;
	CGFloat maxy =rrect.size.height;
	
	
	
	if (params.top>0) {
		CGContextSetLineWidth(context, params.top);
		CGContextMoveToPoint(context, minx,miny);
		CGContextAddLineToPoint(context, maxx,miny);
		CGContextStrokePath(context);
	}
	
	if (params.right>0) {
		CGContextSetLineWidth(context, params.right);
		CGContextMoveToPoint(context, maxx,miny);
		CGContextAddLineToPoint(context, maxx,maxy);
		CGContextStrokePath(context);
	}
	
	if (params.bottom>0) {
		CGContextSetLineWidth(context, params.bottom);
		CGContextMoveToPoint(context, minx,maxy);
		CGContextAddLineToPoint(context, maxx,maxy);
		CGContextStrokePath(context);
	}
	
	if (params.left>0) {
		CGContextSetLineWidth(context, params.left);
		CGContextMoveToPoint(context, minx,miny);
		CGContextAddLineToPoint(context, minx,maxy);
		CGContextStrokePath(context);
	}
	
}

+(BorderParams)BorderParamsMake:(CGFloat)left :(CGFloat)right :(CGFloat)top :(CGFloat)bottom
{
	BorderParams params; params.left = left; params.right = right; params.top = top; params.bottom = bottom; return params;
}


+(NSInteger)findTabIndexOfNavigationController:(UINavigationController*)controller{
	AppDelegate *appdelegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
	NSInteger tabIndex=[appdelegate.tabBarController.viewControllers indexOfObject:controller];
	return tabIndex;
}


+(UIAlertView*)createTextEntryAlertView:(NSString*)title fieldText:(NSString*)fieldText delegate:(id)delegate{
    
    UIAlertView *prompt=nil;
	UITextField *alertField=nil;
	
	if(SYSTEM_VERSION_LESS_THAN(@"7.0")){
		
		prompt = [[UIAlertView alloc] initWithTitle:title
														 message:@"\n\n"
														delegate:delegate
											   cancelButtonTitle:@"Cancel"
											   otherButtonTitles:@"OK", nil];
		
		prompt.tag=kTextEntryAlertTag;
		alertField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 50, 260.0, 25.0)];
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

		
		
		
	}else{
		
		
		
		
		prompt = [[UIAlertView alloc] initWithTitle:title
											message:@""
										   delegate:delegate
								  cancelButtonTitle:@"Cancel"
								  otherButtonTitles:@"OK", nil];
		prompt.tag=kTextEntryAlertTag;
		prompt.alertViewStyle=UIAlertViewStylePlainTextInput;
		alertField = [prompt textFieldAtIndex:0];
		[alertField setBackgroundColor:[UIColor whiteColor]];
		[alertField setClearButtonMode:UITextFieldViewModeWhileEditing];
		alertField.tag=kTextEntryAlertFieldTag;
		
		if(fieldText!=nil){
			alertField.text=fieldText;
		}else{
			[alertField setPlaceholder:@"Route name"];
		}
		
	}
	
    
    [prompt show];
    
    [alertField becomeFirstResponder];
    
    return prompt;
    
}


//
/***********************************************
 * @description			creates new Alert with message and offset input field
 ***********************************************/
//
+(UIAlertView*)createTextEntryAlertView:(NSString*)title fieldText:(NSString*)fieldText withMessage:(NSString*)message keyboardType:(UIKeyboardType)keyboardType delegate:(id)delegate{
	
	UIAlertView *prompt=nil;
	UITextField *alertField=nil;
	
	if(SYSTEM_VERSION_LESS_THAN(@"7.0")){
	
		NSString *fullmessage=nil;
		
		int fieldoffset=15;
		fieldoffset+=[GlobalUtilities calculateHeightOfTextFromWidth:title :[UIFont boldSystemFontOfSize:13] :260 :NSLineBreakByWordWrapping];
		if(message!=nil){
			fullmessage=[NSString stringWithFormat:@"%@\n\n",message];
			fieldoffset+=15;
			fieldoffset+=[GlobalUtilities calculateHeightOfTextFromWidth:fullmessage :[UIFont systemFontOfSize:13] :260 :NSLineBreakByWordWrapping];
		}
		fieldoffset+=13;
		
		UIAlertView *prompt = [[UIAlertView alloc] initWithTitle:title 
														 message:fullmessage
														delegate:delegate 
											   cancelButtonTitle:@"Cancel" 
											   otherButtonTitles:@"OK", nil];
		prompt.tag=kTextEntryAlertTag;
		UITextField *alertField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, fieldoffset, 260.0, 25.0)];
		alertField.keyboardType=keyboardType;
		alertField.borderStyle=UITextBorderStyleRoundedRect;
		[alertField setBackgroundColor:[UIColor whiteColor]];
		[alertField setClearButtonMode:UITextFieldViewModeWhileEditing];
		if(fieldText!=nil){
			alertField.text=fieldText;
		}else{
			[alertField setPlaceholder:@"Route number"];
		}
		
		alertField.tag=kTextEntryAlertFieldTag;
		[prompt addSubview:alertField];
		
		float ver = [[[UIDevice currentDevice] systemVersion] floatValue];
		if(ver<4.0){
			CGAffineTransform moveUp = CGAffineTransformMakeTranslation(0.0, 100.0);
			[prompt setTransform: moveUp];
		}
	
	}else{
		
		
		
		
		
		
			prompt = [[UIAlertView alloc] initWithTitle:title
												message:message
											   delegate:delegate
									  cancelButtonTitle:@"Cancel"
									  otherButtonTitles:@"OK", nil];
			prompt.tag=kTextEntryAlertTag;
			prompt.alertViewStyle=UIAlertViewStylePlainTextInput;
			alertField = [prompt textFieldAtIndex:0];
			alertField.keyboardType=keyboardType;
			[alertField setBackgroundColor:[UIColor whiteColor]];
			[alertField setClearButtonMode:UITextFieldViewModeWhileEditing];
			alertField.tag=kTextEntryAlertFieldTag;
		
			if(fieldText!=nil){
				alertField.text=fieldText;
			}else{
				[alertField setPlaceholder:@"Route number"];
			}
			
		}
    
    [prompt show];
    
    [alertField becomeFirstResponder];
    
    return prompt;
    
}

@end
