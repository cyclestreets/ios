/*

Copyright (C) 2010  CycleStreets Ltd

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

*/

//  LoginView.m
//  BaseLib
//
//  Created by Alan Paxton on 26/05/2010.
//

#import "LoginView.h"
#import "Common.h"
#import "CycleStreets.h"
#import "UserAccount.h"
#import "Files.h"
#import "LayoutBox.h"
#import "AppConstants.h"
#import "StringManager.h"

static NSString *const STRINGID=@"account";


@interface LoginView(Private)

-(void)didReceiveRegisterResponse:(NSDictionary*)dict;
-(void)didReceiveLoginResponse:(NSDictionary*)dict;
- (void)keyboardWillHide:(NSNotification*)notification;
-(void)keyboardWillShow:(NSNotification*)notification;

@end


@implementation LoginView
@synthesize activeView;
@synthesize scrollView;
@synthesize contentView;
@synthesize loginUsernameField;
@synthesize loginPasswordField;
@synthesize loginButton;
@synthesize loginView;
@synthesize registerUsernameField;
@synthesize registerVisibleNameField;
@synthesize registerEmailField;
@synthesize registerPsswordField;
@synthesize registerButton;
@synthesize registerView;
@synthesize loggedInasField;
@synthesize logoutButton;
@synthesize saveLoginButton;
@synthesize loggedInView;
@synthesize activeFieldIndex;
@synthesize activeFieldFrame;
@synthesize activeFieldArray;
@synthesize activeField;
@synthesize keyboardIsShown;
@synthesize viewOffset;
@synthesize activeFormSubmitButton;
@synthesize activeActivityView;
@synthesize activeFormMessageLabel;
@synthesize viewMode;
@synthesize registerFieldArray;
@synthesize loginFieldArray;


//=========================================================== 
// dealloc
//=========================================================== 
- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    [activeView release], activeView = nil;
    [scrollView release], scrollView = nil;
    [contentView release], contentView = nil;
    [loginUsernameField release], loginUsernameField = nil;
    [loginPasswordField release], loginPasswordField = nil;
    [loginButton release], loginButton = nil;
    [loginView release], loginView = nil;
    [registerUsernameField release], registerUsernameField = nil;
    [registerVisibleNameField release], registerVisibleNameField = nil;
    [registerEmailField release], registerEmailField = nil;
    [registerPsswordField release], registerPsswordField = nil;
    [registerButton release], registerButton = nil;
    [registerView release], registerView = nil;
    [loggedInasField release], loggedInasField = nil;
    [logoutButton release], logoutButton = nil;
    [saveLoginButton release], saveLoginButton = nil;
    [loggedInView release], loggedInView = nil;
    [activeFieldArray release], activeFieldArray = nil;
    [activeField release], activeField = nil;
    [activeFormSubmitButton release], activeFormSubmitButton = nil;
    [activeActivityView release], activeActivityView = nil;
    [activeFormMessageLabel release], activeFormMessageLabel = nil;
    [registerFieldArray release], registerFieldArray = nil;
    [loginFieldArray release], loginFieldArray = nil;
	
    [super dealloc];
}


//
/***********************************************
 * @description			NOTIFICATION METHODS
 ***********************************************/
//


-(void)listNotificationInterests{
	
	BetterLog(@"");
	
	[self initialise];
	
	[notifications addObject:LOGINRESPONSE];
	[notifications addObject:REGISTERRESPONSE];
	
	[super.notifications addObject:UIKeyboardWillShowNotification];
	[super.notifications addObject:UIKeyboardWillHideNotification];
	
	[super listNotificationInterests];
	
}

-(void)didReceiveNotification:(NSNotification*)notification{
	
	[super didReceiveNotification:notification];
	
	NSDictionary	*dict=[notification userInfo];
	
	if([notification.name isEqualToString:LOGINRESPONSE]){
		
		[self didReceiveLoginResponse:dict];
		
	}else if ([notification.name isEqualToString:REGISTERRESPONSE]) {
		[self didReceiveRegisterResponse:dict];
	}
	
	if([notification.name isEqualToString:UIKeyboardWillShowNotification]){
		[self keyboardWillShow:notification];	
	}else if ([notification.name isEqualToString:UIKeyboardWillHideNotification]) {
		[self keyboardWillHide:notification];
	}
	
}





//
/***********************************************
 * @description			VIEW METHODS
 ***********************************************/
//


- (void)viewDidLoad {
	
	viewMode=kUserAccountLoggedIn;
	
	[self createPersistentUI];
	
    [super viewDidLoad];
	
}

-(void)viewWillAppear:(BOOL)animated{
	
	[super viewWillAppear:animated];
	
	BetterLog(@"");
	
	viewMode=[UserAccount sharedInstance].accountMode;
	
	[self createNonPersistentUI];
}


-(void)createPersistentUI{
	
	// set up scroll view with layoutbox for sub items
	contentView=[[LayoutBox alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 10)];
	contentView.backgroundColor=[UIColor clearColor];
	contentView.layoutMode=BUVerticalLayoutMode;
	[scrollView addSubview:contentView];
	
	
	// add ui and targets to form buttons
	UIButton *button=nil;
	button=(UIButton*)[loginView viewWithTag:kSubmitButtonTag];
	[GlobalUtilities styleIBButton:button type:@"grey" text:@"Login"];
	[button addTarget:self action:@selector(loginButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
	button=(UIButton*)[registerView viewWithTag:kSubmitButtonTag];
	[GlobalUtilities styleIBButton:button type:@"grey" text:@"Register"];
	[button addTarget:self action:@selector(registerButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
	
	// logged in UI
	[GlobalUtilities styleIBButton:logoutButton type:@"grey" text:@"Reset device"];
	[logoutButton addTarget:self action:@selector(logoutButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
	[saveLoginButton addTarget:self action:@selector(saveLoginControlChanged:) forControlEvents:UIControlEventValueChanged];
	
	
	loginFieldArray=[NSArray arrayWithObjects:loginUsernameField,loginPasswordField,nil];
	registerFieldArray=[NSArray arrayWithObjects:registerUsernameField,registerPsswordField,registerUsernameField,registerEmailField,nil];
	
}


-(void)createNonPersistentUI{
	
	[contentView removeAllSubViews];
	
	switch(viewMode){
		
		case kUserAccountLoggedIn:
			
			[contentView addSubview:loggedInView];
			
		
		break;
			
		case kUserAccountNotLoggedIn:
			
			[contentView addSubview:registerView];
			[contentView addSubview:loginView];
			
			loggedInasField.text=[UserAccount sharedInstance].user.username;
			BOOL sl=[UserAccount sharedInstance].user.autoLogin;
			saveLoginButton.on=sl;
			
			
		break;
		
		
	}
	
	[scrollView setContentSize:CGSizeMake(SCREENWIDTH, contentView.height)];
	[scrollView scrollRectToVisible:CGRectMake(0, 0, SCREENWIDTH, 1) animated:YES];
	
}

//
/***********************************************
 * @description			UTILITY METHODS
 ***********************************************/
//


-(void)showMessageUIForView:(UIView*)iview withMessage:(NSString*)message{
	
	activeFormSubmitButton=(UIButton*) [iview viewWithTag:kSubmitButtonTag];
	activeActivityView=(UIActivityIndicatorView*) [iview viewWithTag:kActivityTag];
	activeFormMessageLabel=(UILabel*) [iview viewWithTag:kMessageFieldTag];
	
	[activeActivityView stopAnimating];
	activeFormMessageLabel.text=[[StringManager sharedInstance] stringForSection:STRINGID andType:message];
	activeFormSubmitButton.enabled=YES;
	
}



-(void)showRequestUIForView:(UIView*)iview{
	
	[self closeKeyboard];
	
	activeFormSubmitButton=(UIButton*) [iview viewWithTag:kSubmitButtonTag];
	activeActivityView=(UIActivityIndicatorView*) [iview viewWithTag:kActivityTag];
	activeFormMessageLabel=(UILabel*) [iview viewWithTag:kMessageFieldTag];
	
	[activeActivityView startAnimating];
	activeFormMessageLabel.text=@"";
	activeFormSubmitButton.enabled=NO;
}

	
	

//
/***********************************************
 * @description			REQUEST METHODS
 ***********************************************/
//


-(void)didReceiveLoginResponse:(NSDictionary*)dict{
	
	NSString	*state=[dict objectForKey:@"state"];
	
	if([state isEqualToString:SUCCESS]){
		
		viewMode=[UserAccount sharedInstance].accountMode;
		[self createNonPersistentUI];
		
	}else if ([state isEqualToString:ERROR]) {
		[self showMessageUIForView:loginView withMessage:[dict objectForKey:MESSAGE]];
	}
	
}



-(void)didReceiveRegisterResponse:(NSDictionary*)dict{
	
	NSString	*state=[dict objectForKey:@"state"];
	
	if([state isEqualToString:SUCCESS]){
		
		viewMode=[UserAccount sharedInstance].accountMode;
		[self createNonPersistentUI];
		
	}else if ([state isEqualToString:ERROR]) {
		[self showMessageUIForView:registerView withMessage:[dict objectForKey:MESSAGE]];
	}
}




//
/***********************************************
 * @description			TEXTFIELD METHODS
 ***********************************************/
//

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
	
	BetterLog(@"");
	int newfieldIndex=activeFieldIndex+1;
	
	if(newfieldIndex==[activeFieldArray count]){
		[activeField resignFirstResponder];
		return NO;
	}
	
	activeFieldIndex=newfieldIndex;
	if(activeFieldIndex<[activeFieldArray count]){
		activeField=[activeFieldArray objectAtIndex:activeFieldIndex];
	}
	[activeField becomeFirstResponder];
	
	return YES;
	
}



- (void)textFieldDidBeginEditing:(UITextField*)textField{
	BetterLog(@"");
	activeField=textField;
	activeFieldFrame=activeField.frame;
}


#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
-(void)keyboardWillShow:(NSNotification*)notification{
	
	BetterLog(@"");
	
    if (keyboardIsShown) {
        return;
    }
	
    NSDictionary* userInfo = [notification userInfo];
	NSValue* boundsValue;
	if([[[UIDevice currentDevice] systemVersion] floatValue]>3.2){
		boundsValue = [userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey];
	}else{
		boundsValue = [userInfo objectForKey:UIKeyboardBoundsUserInfoKey];
	}
    CGSize keyboardSize = [boundsValue CGRectValue].size;
	
	// store current offset for hide
	viewOffset=scrollView.contentOffset;
    
	// resize scroll view to available viewable height
    CGRect viewFrame = scrollView.frame; 
	int taboffset=0;
	if(self.navigationController.tabBarController.hidesBottomBarWhenPushed==NO)
		taboffset=TABBARHEIGHT;
	viewFrame.size.height -= (keyboardSize.height-taboffset );
	
	//
	[UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.3];
    [scrollView setFrame:viewFrame];
    [UIView commitAnimations];
	
	// get and map nested field rect to main view coordinate 
	CGRect textFieldRect = activeFieldFrame;
	textFieldRect=[activeField convertRect:textFieldRect toView:self.scrollView ];
	
	CGFloat ypos=textFieldRect.origin.y;
	if(ypos>0 && ypos>(viewFrame.size.height/2)){
		textFieldRect.origin.y += 10;
		[scrollView scrollRectToVisible:textFieldRect animated:YES];
	}else {
		[scrollView scrollRectToVisible:textFieldRect animated:YES];
	}
	
	
    keyboardIsShown = YES;
}


- (void)keyboardWillHide:(NSNotification*)notification{
	
	if(!keyboardIsShown)
		return;
	
    NSDictionary* userInfo = [notification userInfo];
	
    NSValue* boundsValue = [userInfo objectForKey:UIKeyboardBoundsUserInfoKey];
    CGSize keyboardSize = [boundsValue CGRectValue].size;
    CGRect viewFrame = scrollView.frame;
	
    viewFrame.size.height += (keyboardSize.height);
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:0.3];
	[scrollView setFrame:viewFrame];
	[UIView commitAnimations];
	
	CGRect oldFrame=CGRectMake(viewOffset.x, viewOffset.y, viewFrame.size.width , viewFrame.size.height );
	[scrollView scrollRectToVisible:oldFrame animated:YES];
	
    keyboardIsShown = NO;
}


-(void)closeKeyboard{
	[activeField resignFirstResponder];
}

-(IBAction)closeKeyboardFromUI:(id)sender{
	[self closeKeyboard];
}



//
/***********************************************
 * @description			BUTTON METHODS
 ***********************************************/
//	

- (IBAction)loginButtonSelected:(id)sender {
	DLog(@"didLoginButton");
	
	// validate fields
	NSString  *efieldString=loginUsernameField.text;
	BOOL eresult=[efieldString length]>kUsernameExtent;
	
	NSString  *pfieldString=loginPasswordField.text;
	BOOL presult=[pfieldString length]>kpasswordExtent;
	
	if(presult==YES && eresult==YES){
		
		[self showRequestUIForView:loginView];
		
		[[UserAccount sharedInstance] loginUserWithUserName:efieldString andPassword:pfieldString];
		
	}else {
		if(eresult==NO){
			[self showMessageUIForView:loginView withMessage:[[StringManager sharedInstance] stringForSection:STRINGID andType:@"error_syntax_username"]];
			return;
		}
		if(presult==NO){
			[self showMessageUIForView:loginView withMessage:[[StringManager sharedInstance] stringForSection:STRINGID andType:@"error_syntax_password"]];
			return;
		}
	}
	
	
	
}

- (IBAction)registerButtonSelected:(id)sender {
	DLog(@">>>");
	
	// more complicated form field validation logic required
	BOOL presult=NO;
	BOOL eresult=NO;
	
	if(presult==YES && eresult==YES){
		
		[self showRequestUIForView:registerView];
		
		[[UserAccount sharedInstance] registerUserWithUserName:registerUsernameField.text 
												   andPassword:registerPsswordField.text 
												   visibleName:registerVisibleNameField.text 
														 email:registerEmailField.text];
		
	}else {
		
		// show appropriate error message ui
		
	}
	
	
	
	
}


-(IBAction)logoutButtonSelected:(id)sender{
	
	[[UserAccount sharedInstance] logoutUser];
	viewMode=[UserAccount sharedInstance].accountMode;
	[self createNonPersistentUI];
	
}



-(void)saveLoginControlChanged:(id)sender{
	
	UISwitch *loginswitch=(UISwitch*)sender;
	[[UserAccount sharedInstance] updateAutoLoginPreference:loginswitch.on];
	
}


//
/***********************************************
 * @description			GENERIC METHODS
 ***********************************************/
//
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)clearFields {
	self.loginUsernameField.text = @"";
	self.loginPasswordField.text = @"";
	self.registerEmailField.text = @"";
	self.registerVisibleNameField.text = @"";
}

- (void) viewDidUnload {
    self.loginUsernameField = nil;
    self.loginPasswordField = nil;
    self.loginButton = nil;
    self.registerUsernameField = nil;
    self.registerVisibleNameField = nil;
    self.registerEmailField = nil;
    self.registerPsswordField = nil;
    self.registerButton = nil;
    self.loggedInasField = nil;
    self.logoutButton = nil;
    self.saveLoginButton = nil;
	[super viewDidUnload];
}



@end
