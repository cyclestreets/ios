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

#import "AccountViewController.h"

#import "CycleStreets.h"
#import "UserAccount.h"
#import "Files.h"
#import "LayoutBox.h"
#import "AppConstants.h"
#import "StringManager.h"
#import "GlobalUtilities.h"
#import "ViewUtilities.h"
#import "ButtonUtilities.h"
#import "StringUtilities.h"

static NSString *const STRINGID=@"account";


@interface AccountViewController(Private)

-(void)didReceiveRegisterResponse:(NSDictionary*)dict;
-(void)didReceiveLoginResponse:(NSDictionary*)dict;
- (void)keyboardWillHide:(NSNotification*)notification;
-(void)keyboardWillShow:(NSNotification*)notification;

-(void)showResponseMessageUIForView:(UIView*)iview withMessage:(NSString*)messageid;

@end


@implementation AccountViewController
@synthesize activeView;
@synthesize scrollView;
@synthesize pageControl;
@synthesize pageControlView;
@synthesize leftLabel;
@synthesize rightLabel;
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
@synthesize retrieveEmailField;
@synthesize retrieveView;
@synthesize loggedInasField;
@synthesize logoutButton;
@synthesize saveLoginButton;
@synthesize loggedInView;
@synthesize activePage;
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
@synthesize formFieldArray;
@synthesize isModal;
@synthesize shouldAutoClose;

/***********************************************************/
// dealloc
/***********************************************************/
- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    [activeView release], activeView = nil;
    [scrollView release], scrollView = nil;
    [pageControl release], pageControl = nil;
    [pageControlView release], pageControlView = nil;
    [leftLabel release], leftLabel = nil;
    [rightLabel release], rightLabel = nil;
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
    [retrieveEmailField release], retrieveEmailField = nil;
    [retrieveView release], retrieveView = nil;
    [loggedInasField release], loggedInasField = nil;
    [logoutButton release], logoutButton = nil;
    [saveLoginButton release], saveLoginButton = nil;
    [loggedInView release], loggedInView = nil;
    [activeFieldArray release], activeFieldArray = nil;
    [activeField release], activeField = nil;
    [activeFormSubmitButton release], activeFormSubmitButton = nil;
    [activeActivityView release], activeActivityView = nil;
    [activeFormMessageLabel release], activeFormMessageLabel = nil;
    [formFieldArray release], formFieldArray = nil;
	
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
	
	[super.notifications addObject:LOGINRESPONSE];
	[super.notifications addObject:REGISTERRESPONSE];
	
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
	}else if ([notification.name isEqualToString:PASSWORDRETRIEVALRESPONSE]) {
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
	
	BetterLog(@"");
	
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
	contentView.layoutMode=BUHorizontalLayoutMode;
	contentView.paddingTop=10;
	[scrollView addSubview:contentView];
	
	activePage=0;
	scrollView.pagingEnabled=YES;
	scrollView.delegate=self;
	pageControl.hidesForSinglePage=YES;
	[pageControl addTarget:self action:@selector(pageControlValueChanged:) forControlEvents:UIControlEventValueChanged];
	
	
	// add ui and targets to form buttons
	UIButton *button=nil;
	button=(UIButton*)[loginView viewWithTag:kSubmitButtonTag];
	[ButtonUtilities styleIBButton:button type:@"grey" text:@"Sign in"];
	[button addTarget:self action:@selector(loginButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
	button=(UIButton*)[registerView viewWithTag:kSubmitButtonTag];
	[ButtonUtilities styleIBButton:button type:@"grey" text:@"Create account"];
	[button addTarget:self action:@selector(registerButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
	button=(UIButton*)[retrieveView viewWithTag:kSubmitButtonTag];
	[ButtonUtilities styleIBButton:button type:@"grey" text:@"Submit"];
	[button addTarget:self action:@selector(retrievePasswordButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
	
	// logged in UI
	[ButtonUtilities styleIBButton:logoutButton type:@"grey" text:@"Clear signin details"];
	[logoutButton addTarget:self action:@selector(logoutButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
	[saveLoginButton addTarget:self action:@selector(saveLoginControlChanged:) forControlEvents:UIControlEventValueChanged];
	
	
	
	formFieldArray=[[NSMutableArray alloc]init];
	NSMutableArray *rar=[[NSMutableArray alloc]initWithObjects:registerUsernameField,registerPsswordField,registerVisibleNameField,registerEmailField,nil];
	[formFieldArray addObject:rar];
	[rar release];	
	NSMutableArray *lar=[[NSMutableArray alloc]initWithObjects:loginUsernameField,loginPasswordField,nil];
	[formFieldArray addObject:lar];
	[lar release];
	/*
		NSMutableArray *par=[[NSMutableArray alloc]initWithObjects:retrieveEmailField,nil];
	[formFieldArray addObject:par];
	[par release];
	*/
	
	if(isModal==YES)
		[self createNavigationBarUI];
	
	
	if(isModal==YES){
		CGRect pframe=pageControlView.frame;
		pframe.origin.y=pframe.origin.y+TABBARHEIGHT;
		pageControlView.frame=pframe;
	}
	
}


-(void)createNonPersistentUI{
	
	[activeActivityView stopAnimating];
	[contentView removeAllSubViews];
	
	switch(viewMode){
		
		case kUserAccountLoggedIn:
			
			[contentView addSubview:loggedInView];
			
			loggedInasField.text=[UserAccount sharedInstance].user.username;
			BOOL sl=[UserAccount sharedInstance].user.autoLogin;
			saveLoginButton.on=sl;
			rightLabel.text=@"";
			leftLabel.text=@"";
			
			[scrollView setContentSize:CGSizeMake(contentView.width, contentView.height)];
		break;
			
		case kUserAccountNotLoggedIn:
			
			loginUsernameField.text=@"";
			loginPasswordField.text=@"";
			
			[contentView addSubview:registerView];
			[contentView addSubview:loginView];
			//[contentView addSubview:retrieveView];
			
			[scrollView setContentSize:CGSizeMake(contentView.width, contentView.height)];
		break;
		
		case kUserAccountCredentialsExist:
			
			[scrollView setContentSize:CGSizeMake(contentView.width, contentView.height)];
			
			[[UserAccount sharedInstance] loginExistingUser];
			
		break;
	}
	

	// update page support
	pageControl.numberOfPages=[contentView.items count];
	activePage=0;
	pageControl.currentPage=activePage;
	[pageControl updateCurrentPageDisplay];
	scrollView.scrollEnabled=contentView.width>SCREENWIDTH;
	[self updateFormPage];
	
	[scrollView scrollRectToVisible:CGRectMake(0, 0, SCREENWIDTH, 1) animated:YES];
	
	self.navigationController.navigationBar.tintColor=UIColorFromRGB(0x008000);
	
}


-(void)createNavigationBarUI{
	
	if(navigation==nil){
	
        self.navigation=[[CustomNavigtionBar alloc]init];
        self.navigationController.navigationBar.tintColor=UIColorFromRGB(0x008000);
        navigation.delegate=self;
        navigation.leftItemType=BUNavNoneType;
        navigation.rightItemType=UIKitButtonType;
        navigation.rightButtonTitle=@"Close";
        navigation.navigationItem=self.navigationItem;
        [navigation createNavigationUI];
	
	}
}




//
/***********************************************
 * @description			UTILITY METHODS
 ***********************************************/
//

-(void)showResponseMessageUIForView:(UIView*)iview withMessage:(NSString*)messageid{
	
	activeFormSubmitButton=(UIButton*) [iview viewWithTag:kSubmitButtonTag];
	activeActivityView=(UIActivityIndicatorView*) [iview viewWithTag:kActivityTag];
	activeFormMessageLabel=(UILabel*) [iview viewWithTag:kMessageFieldTag];
	
	[activeActivityView stopAnimating];
	activeFormMessageLabel.text=[[StringManager sharedInstance] stringForSection:@"account" andType:messageid];
	activeFormSubmitButton.enabled=YES;
	
}

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
		[self showMessageUIForView:loginView withMessage:@""];
		[self createNonPersistentUI];
		
		if(isModal==YES && shouldAutoClose==YES){
			[self doNavigationSelector:RIGHT];
			[[NSNotificationCenter defaultCenter] postNotificationName:UPLOADUSERPHOTO object:nil];
		}
		
	}else if ([state isEqualToString:ERROR]) {
		[self showResponseMessageUIForView:loginView withMessage:[dict objectForKey:MESSAGE]];
	}
	
}



-(void)didReceiveRegisterResponse:(NSDictionary*)dict{
	
	NSString	*state=[dict objectForKey:@"state"];
	
	if([state isEqualToString:SUCCESS]){
		
		viewMode=[UserAccount sharedInstance].accountMode;
		[self showMessageUIForView:registerView withMessage:@""];
		[self createNonPersistentUI];
		
	}else if ([state isEqualToString:ERROR]) {
		[self showResponseMessageUIForView:registerView withMessage:[dict objectForKey:MESSAGE]];
	}
}

-(void)didReceivePasswordResponse:(NSDictionary*)dict{
	
	NSString	*state=[dict objectForKey:@"state"];
	
	if([state isEqualToString:SUCCESS]){
		[self showMessageUIForView:retrieveView withMessage:[dict objectForKey:MESSAGE]];
	}else if ([state isEqualToString:ERROR]) {
		[self showResponseMessageUIForView:retrieveView withMessage:[dict objectForKey:MESSAGE]];
	}
}


//
/***********************************************
 * @description			PAGE EVENTS
 ***********************************************/
//

-(void)scrollViewDidEndDecelerating:(UIScrollView *)sc{
	BetterLog(@"");
	CGPoint offset=scrollView.contentOffset;
	activePage=offset.x/SCREENWIDTH;
	pageControl.currentPage=activePage;
	[self updateFormPage];
}


-(IBAction)pageControlValueChanged:(id)sender{
	BetterLog(@"");
	UIPageControl *pc=(UIPageControl*)sender;
	CGPoint offset=CGPointMake(pc.currentPage*SCREENWIDTH, 0);
	[scrollView setContentOffset:offset animated:YES];
	
}
-(void)scrollViewDidEndScrollingAnimation:(UIScrollView*)sc{
	BetterLog(@"");
	[self scrollViewDidEndDecelerating:scrollView];
}


-(void)updateFormPage{
	
	if(viewMode==kUserAccountNotLoggedIn){
		activeFieldArray=[formFieldArray objectAtIndex:activePage];
	}
	
	if(viewMode==kUserAccountLoggedIn){
		rightLabel.text=@"";
		leftLabel.text=@"";
		return;
	}
	
	if(activePage==0){
		leftLabel.text=@"";
		rightLabel.text=@"Sign in";
	}else {
		leftLabel.text=@"Create account";
		rightLabel.text=@"";
	}

}



//
/***********************************************
 * @description			TEXTFIELD METHODS
 ***********************************************/
//

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
	
	BetterLog(@"activeFieldIndex=%i",activeFieldIndex);
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
	
	activeFieldIndex=textField.tag;
	activeField=textField;
	activeFieldFrame=activeField.frame;
}


#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
-(void)keyboardWillShow:(NSNotification*)notification{
	
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
		taboffset=TABBARHEIGHT+22;
	viewFrame.size.height -= (keyboardSize.height-taboffset );
	
	//
	[UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.3];
    [scrollView setFrame:viewFrame];
    [UIView commitAnimations];
	
	// get and map nested field rect to main view coordinate 
	CGRect textFieldRect = activeFieldFrame;
	CGRect newRect=[activeField convertRect:textFieldRect toView:self.scrollView ];
	
	textFieldRect=CGRectMake(newRect.origin.x, textFieldRect.origin.y, textFieldRect.size.width, textFieldRect.size.height);
	
	
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
			[self showMessageUIForView:loginView withMessage:@"error_syntax_username"];
			return;
		}
		if(presult==NO){
			[self showMessageUIForView:loginView withMessage:@"error_syntax_password"];
			return;
		}
	}
	
	
	
}

- (IBAction)registerButtonSelected:(id)sender {
	
	BetterLog(@"");
	
	NSString  *efieldString=registerUsernameField.text;
	BOOL eresult=[efieldString length]>kUsernameExtent;
	
	NSString  *pfieldString=registerPsswordField.text;
	BOOL presult=[pfieldString length]>kpasswordExtent;
	
	NSString  *visfieldString=registerVisibleNameField.text;
	BOOL visresult=[visfieldString length]>kUsernameExtent;
	
	NSString  *emfieldString=registerEmailField.text;
	BOOL emresult=[StringUtilities validateEmail:emfieldString]; 
	
	
	if(presult==YES && eresult==YES && emresult==YES && visresult==YES){
		
		[self showRequestUIForView:registerView];
		
		[[UserAccount sharedInstance] registerUserWithUserName:registerUsernameField.text 
												   andPassword:registerPsswordField.text 
												   visibleName:registerVisibleNameField.text 
														 email:registerEmailField.text];
		
	}else {
		
		if (eresult==NO) {
			[self showMessageUIForView:registerView withMessage:@"error_syntax_username"];
		}else if(presult==NO) {
			[self showMessageUIForView:registerView withMessage:@"error_syntax_password"];
		}else if(visresult==NO) {
			[self showMessageUIForView:registerView withMessage:@"error_syntax_visiblename"];
		}else if(emresult==NO) {
			[self showMessageUIForView:registerView withMessage:@"error_syntax_email"];
		}

		
	}
	
}


- (IBAction)retrievePasswordButtonSelected:(id)sender {
	
	// more complicated form field validation logic required
	BOOL presult=NO;
	
	if(presult==YES){
		
	}else {
		
		// show appropriate error message ui
		
	}
	
}



-(IBAction)logoutButtonSelected:(id)sender{
	
	[[UserAccount sharedInstance] resetUserAccount];
	viewMode=[UserAccount sharedInstance].accountMode;
	[self createNonPersistentUI];
	
}



-(void)saveLoginControlChanged:(id)sender{
	
	UISwitch *loginswitch=(UISwitch*)sender;
	[[UserAccount sharedInstance] updateAutoLoginPreference:loginswitch.on];
	
}



-(IBAction)didCancelButton:(id)sender{
	[self.navigationController dismissModalViewControllerAnimated:YES];
}


-(IBAction)doNavigationSelector:(NSString*)type{
	
	if([type isEqualToString:RIGHT]){
		[self.navigationController dismissModalViewControllerAnimated:YES];
	}
	
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
