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
#import "GenericConstants.h"
#import <PixateFreestyle/PixateFreestyle.h>
#import "UIViewController+BUAdditions.h"

static NSString *const STRINGID=@"account";


#define kSubmitButtonTag 499
#define	kActivityTag 500
#define	kMessageFieldTag 501
#define kpasswordExtent 4
#define	kUsernameExtent 4


@interface AccountViewController()

@property (nonatomic, strong)		IBOutlet UIView                        * activeView;
@property (nonatomic, strong)		IBOutlet UIScrollView                  * scrollView;
@property (nonatomic, strong)		IBOutlet UIPageControl                 * pageControl;
@property (nonatomic, strong)		IBOutlet UIView                        * pageControlView;
@property (nonatomic, strong)		IBOutlet UILabel                       * leftLabel;
@property (nonatomic, strong)		IBOutlet UILabel                       * rightLabel;
@property (nonatomic, strong)		LayoutBox                              * contentView;
@property (nonatomic, strong)		IBOutlet UITextField                   * loginUsernameField;
@property (nonatomic, strong)		IBOutlet UITextField                   * loginPasswordField;
@property (nonatomic, strong)		IBOutlet UIButton                      * loginButton;
@property (nonatomic, strong)		IBOutlet UIView                        * loginView;
@property (nonatomic, strong)		IBOutlet UITextField                   * registerUsernameField;
@property (nonatomic, strong)		IBOutlet UITextField                   * registerVisibleNameField;
@property (nonatomic, strong)		IBOutlet UITextField                   * registerEmailField;
@property (nonatomic, strong)		IBOutlet UITextField                   * registerPsswordField;
@property (nonatomic, strong)		IBOutlet UIButton                      * registerButton;
@property (nonatomic, strong)		IBOutlet UIView                        * registerView;
@property (nonatomic, strong)		IBOutlet UITextField                   * retrieveEmailField;
@property (nonatomic, strong)		IBOutlet UIView                        * retrieveView;
@property (nonatomic, strong)		IBOutlet UILabel                       * loggedInasField;
@property (nonatomic, strong)		IBOutlet UIButton                      * logoutButton;
@property (nonatomic, strong)		IBOutlet UISwitch                      * saveLoginButton;
@property (nonatomic, strong)		IBOutlet UIView                        * loggedInView;
@property (nonatomic)		NSInteger                                            activePage;
@property (nonatomic)		NSInteger                                            activeFieldIndex;
@property (nonatomic)		CGRect                                         activeFieldFrame;
@property (nonatomic, strong)		NSMutableArray                         * activeFieldArray;
@property (nonatomic, strong)		IBOutlet UITextField                   * activeField;
@property (nonatomic)		BOOL                                           keyboardIsShown;
@property (nonatomic)		CGPoint                                        viewOffset;
@property (nonatomic, strong)		IBOutlet UIButton                      * activeFormSubmitButton;
@property (nonatomic, strong)		IBOutlet UIActivityIndicatorView       * activeActivityView;
@property (nonatomic, strong)		IBOutlet UILabel                       * activeFormMessageLabel;
@property (nonatomic)		UserAccountMode                                viewMode;
@property (nonatomic, strong)		NSMutableArray                         * formFieldArray;

-(void)didReceiveRegisterResponse:(NSDictionary*)dict;
-(void)didReceiveLoginResponse:(NSDictionary*)dict;
- (void)keyboardWillHide:(NSNotification*)notification;
-(void)keyboardWillShow:(NSNotification*)notification;

-(void)showResponseMessageUIForView:(UIView*)iview withMessage:(NSString*)messageid;


-(void)clearFields;
-(void)closeKeyboard;
-(void)saveLoginControlChanged:(id)sender;
- (IBAction) logoutButtonSelected:(id)sender ;
- (IBAction)registerButtonSelected:(id)sender;
- (IBAction)loginButtonSelected:(id)sender;
-(IBAction)closeKeyboardFromUI:(id)sender;
- (IBAction)retrievePasswordButtonSelected:(id)sender;
-(void)updateFormPage;
-(IBAction)didCancelButton:(id)sender;

@end


@implementation AccountViewController



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
	
	_viewMode=kUserAccountLoggedIn;
	
	[self createPersistentUI];
	
    [super viewDidLoad];
	
}

-(void)viewWillAppear:(BOOL)animated{
	
	[super viewWillAppear:animated];
	
	_viewMode=[UserAccount sharedInstance].accountMode;
	
	[self createNonPersistentUI];
	
}

-(void)viewWillDisappear:(BOOL)animated{
	
	[self forceActiveFieldResign];
	
	[super viewWillDisappear:animated];
}


// for some reason [self.view endEditing:YES] does not work for this view
-(void)forceActiveFieldResign{
	
	if(_activeField!=nil)
		[_activeField resignFirstResponder];
	
}


-(void)createPersistentUI{
	
	// set up scroll view with layoutbox for sub items
	_contentView=[[LayoutBox alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 10)];
	_contentView.backgroundColor=[UIColor clearColor];
	_contentView.layoutMode=BUHorizontalLayoutMode;
	_contentView.paddingTop=10;
	[_scrollView addSubview:_contentView];
	
	_activePage=0;
	_scrollView.pagingEnabled=YES;
	_scrollView.delegate=self;
	_pageControl.hidesForSinglePage=YES;
	[_pageControl addTarget:self action:@selector(pageControlValueChanged:) forControlEvents:UIControlEventValueChanged];
	
	
	// add ui and targets to form buttons
	UIButton *button=nil;
	button=(UIButton*)[_loginView viewWithTag:kSubmitButtonTag];
	button.styleId=@"DarkGreyButton";
	[button setTitle:LocalisedString(@"login") forState:UIControlStateNormal];
	[button addTarget:self action:@selector(loginButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
	
	button=(UIButton*)[_registerView viewWithTag:kSubmitButtonTag];
	button.styleId=@"DarkGreyButton";
	[button setTitle:LocalisedString(@"createaccount") forState:UIControlStateNormal];
	[button addTarget:self action:@selector(registerButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
	
	button=(UIButton*)[_retrieveView viewWithTag:kSubmitButtonTag];
	button.styleId=@"DarkGreyButton";
	[button setTitle:LocalisedString(@"submit") forState:UIControlStateNormal];
	[button addTarget:self action:@selector(retrievePasswordButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
	
	// logged in UI
	_logoutButton.styleId=@"DarkGreyButton";
	[_logoutButton setTitle:LocalisedString(@"clearsubmit") forState:UIControlStateNormal];
	[_logoutButton addTarget:self action:@selector(logoutButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
	[_saveLoginButton addTarget:self action:@selector(saveLoginControlChanged:) forControlEvents:UIControlEventValueChanged];
	
	
	
	_formFieldArray=[[NSMutableArray alloc]init];
	NSMutableArray *rar=[[NSMutableArray alloc]initWithObjects:_registerUsernameField,_registerPsswordField,_registerVisibleNameField,_registerEmailField,nil];
	[_formFieldArray addObject:rar];
	NSMutableArray *lar=[[NSMutableArray alloc]initWithObjects:_loginUsernameField,_loginPasswordField,nil];
	[_formFieldArray addObject:lar];
	
	
	
	/*
		NSMutableArray *par=[[NSMutableArray alloc]initWithObjects:retrieveEmailField,nil];
	[formFieldArray addObject:par];
	[par release];
	*/
	
	
	
	
	if(_isModal==YES){
		CGRect pframe=_pageControlView.frame;
		pframe.origin.y=pframe.origin.y+TABBARHEIGHT;
		_pageControlView.frame=pframe;
		
		UIBarButtonItem *closebutton=[[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStylePlain target:self action:@selector(didCancelButton:)];
		self.navigationItem.rightBarButtonItem=closebutton;
	}
	
}


-(void)createNonPersistentUI{
	
	[_activeActivityView stopAnimating];
	[_contentView removeAllSubViews];
	
	switch(_viewMode){
		
		case kUserAccountLoggedIn:
			
			[_contentView addSubview:_loggedInView];
			
			_loggedInasField.text=[UserAccount sharedInstance].user.username;
			BOOL sl=[UserAccount sharedInstance].user.autoLogin;
			_saveLoginButton.on=sl;
			_rightLabel.text=@"";
			_leftLabel.text=@"";
			
			[_scrollView setContentSize:CGSizeMake(_contentView.width, _contentView.height)];
		break;
			
		case kUserAccountNotLoggedIn:
			
			_loginUsernameField.text=@"";
			_loginPasswordField.text=@"";
			
			[_contentView addSubview:_registerView];
			[_contentView addSubview:_loginView];
			//[contentView addSubview:retrieveView];
			
			[_scrollView setContentSize:CGSizeMake(_contentView.width, _contentView.height)];
		break;
		
		case kUserAccountCredentialsExist:
			
			[_scrollView setContentSize:CGSizeMake(_contentView.width, _contentView.height)];
			
			[[UserAccount sharedInstance] loginExistingUser];
			
		break;
	}
	

	// update page support
	_pageControl.numberOfPages=[_contentView.items count];
	_activePage=0;
	_pageControl.currentPage=_activePage;
	[_pageControl updateCurrentPageDisplay];
	_scrollView.scrollEnabled=_contentView.width>SCREENWIDTH;
	[self updateFormPage];
	
	[_scrollView scrollRectToVisible:CGRectMake(0, 0, SCREENWIDTH, 1) animated:YES];
	
	
}





//
/***********************************************
 * @description			UTILITY METHODS
 ***********************************************/
//

-(void)showResponseMessageUIForView:(UIView*)iview withMessage:(NSString*)messageid{
	
	_activeFormSubmitButton=(UIButton*) [iview viewWithTag:kSubmitButtonTag];
	_activeActivityView=(UIActivityIndicatorView*) [iview viewWithTag:kActivityTag];
	_activeFormMessageLabel=(UILabel*) [iview viewWithTag:kMessageFieldTag];
	
	[_activeActivityView stopAnimating];
	
	_activeFormMessageLabel.text=[[StringManager sharedInstance] stringForSection:@"account" andType:messageid];
	_activeFormSubmitButton.enabled=YES;
	
}

-(void)showMessageUIForView:(UIView*)iview withMessage:(NSString*)message{
	
	_activeFormSubmitButton=(UIButton*) [iview viewWithTag:kSubmitButtonTag];
	_activeActivityView=(UIActivityIndicatorView*) [iview viewWithTag:kActivityTag];
	_activeFormMessageLabel=(UILabel*) [iview viewWithTag:kMessageFieldTag];
	
	[_activeActivityView stopAnimating];
	_activeFormMessageLabel.text=[[StringManager sharedInstance] stringForSection:STRINGID andType:message];
	_activeFormSubmitButton.enabled=YES;
	
}



-(void)showRequestUIForView:(UIView*)iview{
	
	[self closeKeyboard];
	
	_activeFormSubmitButton=(UIButton*) [iview viewWithTag:kSubmitButtonTag];
	_activeActivityView=(UIActivityIndicatorView*) [iview viewWithTag:kActivityTag];
	_activeFormMessageLabel=(UILabel*) [iview viewWithTag:kMessageFieldTag];
	
	[_activeActivityView startAnimating];
	_activeFormMessageLabel.text=@"";
	_activeFormSubmitButton.enabled=NO;
}

	
	

//
/***********************************************
 * @description			REQUEST METHODS
 ***********************************************/
//


-(void)didReceiveLoginResponse:(NSDictionary*)dict{
	
	NSString	*state=[dict objectForKey:@"state"];
	
	if([state isEqualToString:SUCCESS]){
		
		_viewMode=[UserAccount sharedInstance].accountMode;
		[self showMessageUIForView:_loginView withMessage:@""];
		[self createNonPersistentUI];
		
		if(_isModal==YES && _shouldAutoClose==YES){
			[self doNavigationSelector:RIGHT];
             
			[[NSNotificationCenter defaultCenter] postNotificationName:USERACCOUNTLOGINSUCCESS object:nil];
		}
		
	}else if ([state isEqualToString:ERROR]) {
		[self showResponseMessageUIForView:_loginView withMessage:[dict objectForKey:MESSAGE]];
	}
	
}



-(void)didReceiveRegisterResponse:(NSDictionary*)dict{
	
	NSString	*state=[dict objectForKey:@"state"];
	
	if([state isEqualToString:SUCCESS]){
		
		_viewMode=[UserAccount sharedInstance].accountMode;
		[self showMessageUIForView:_registerView withMessage:@""];
		[self createNonPersistentUI];
		
		if(_isModal==YES && _shouldAutoClose==YES){
			[self doNavigationSelector:RIGHT];
			
			[[NSNotificationCenter defaultCenter] postNotificationName:USERACCOUNTREGISTERSUCCESS object:nil];
		}
		
	}else if ([state isEqualToString:ERROR]) {
		[self showResponseMessageUIForView:_registerView withMessage:[dict objectForKey:MESSAGE]];
	}
}

-(void)didReceivePasswordResponse:(NSDictionary*)dict{
	
	NSString	*state=[dict objectForKey:@"state"];
	
	if([state isEqualToString:SUCCESS]){
		[self showMessageUIForView:_retrieveView withMessage:[dict objectForKey:MESSAGE]];
	}else if ([state isEqualToString:ERROR]) {
		[self showResponseMessageUIForView:_retrieveView withMessage:[dict objectForKey:MESSAGE]];
	}
}


//
/***********************************************
 * @description			PAGE EVENTS
 ***********************************************/
//

-(void)scrollViewDidEndDecelerating:(UIScrollView *)sc{
	BetterLog(@"");
	CGPoint offset=_scrollView.contentOffset;
	_activePage=offset.x/SCREENWIDTH;
	_pageControl.currentPage=_activePage;
	[self updateFormPage];
}


-(IBAction)pageControlValueChanged:(id)sender{
	BetterLog(@"");
	UIPageControl *pc=(UIPageControl*)sender;
	CGPoint offset=CGPointMake(pc.currentPage*SCREENWIDTH, 0);
	[_scrollView setContentOffset:offset animated:YES];
	
}
-(void)scrollViewDidEndScrollingAnimation:(UIScrollView*)sc{
	BetterLog(@"");
	[self scrollViewDidEndDecelerating:_scrollView];
}


-(void)updateFormPage{
	
	if(_activePage>=_formFieldArray.count)
		return;
	
	if(_viewMode==kUserAccountNotLoggedIn){
		_activeFieldArray=[_formFieldArray objectAtIndex:_activePage];
	}
	
	if(_viewMode==kUserAccountLoggedIn){
		_rightLabel.text=@"";
		_leftLabel.text=@"";
		return;
	}
	
	if(_activePage==0){
		_leftLabel.text=@"";
		_rightLabel.text=LocalisedString(@"login");
	}else {
		_leftLabel.text=LocalisedString(@"createaccount");
		_rightLabel.text=@"";
	}

}



//
/***********************************************
 * @description			TEXTFIELD METHODS
 ***********************************************/
//

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
	
	BetterLog(@"activeFieldIndex=%li",(long)_activeFieldIndex);
	NSInteger newfieldIndex=_activeFieldIndex+1;
	
	if(newfieldIndex==[_activeFieldArray count]){
		[_activeField resignFirstResponder];
		return NO;
	}
	
	_activeFieldIndex=newfieldIndex;
	if(_activeFieldIndex<[_activeFieldArray count]){
		_activeField=[_activeFieldArray objectAtIndex:_activeFieldIndex];
	}
	[_activeField becomeFirstResponder];
	
	return YES;
	
}



- (void)textFieldDidBeginEditing:(UITextField*)textField{
	
	_activeFieldIndex=textField.tag;
	_activeField=textField;
	_activeFieldFrame=_activeField.frame;
}


#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
-(void)keyboardWillShow:(NSNotification*)notification{
	
    if (_keyboardIsShown) {
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
	_viewOffset=_scrollView.contentOffset;
    
	// resize scroll view to available viewable height
    CGRect viewFrame = _scrollView.frame; 
	int taboffset=0;
	if(self.navigationController.tabBarController.hidesBottomBarWhenPushed==NO)
		taboffset=TABBARHEIGHT+22;
	viewFrame.size.height -= (keyboardSize.height-taboffset );
	
	//
	[UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.3];
    [_scrollView setFrame:viewFrame];
    [UIView commitAnimations];
	
	// get and map nested field rect to main view coordinate 
	CGRect textFieldRect = _activeFieldFrame;
	CGRect newRect=[_activeField convertRect:textFieldRect toView:self.scrollView ];
	
	textFieldRect=CGRectMake(newRect.origin.x, textFieldRect.origin.y, textFieldRect.size.width, textFieldRect.size.height);
	
	
	CGFloat ypos=textFieldRect.origin.y;
	if(ypos>0 && ypos>(viewFrame.size.height/2)){
		textFieldRect.origin.y += 10;
		[_scrollView scrollRectToVisible:textFieldRect animated:YES];
	}else {
		[_scrollView scrollRectToVisible:textFieldRect animated:YES];
	}
	
	
    _keyboardIsShown = YES;
}


- (void)keyboardWillHide:(NSNotification*)notification{
	
	if(!_keyboardIsShown)
		return;
	
    NSDictionary* userInfo = [notification userInfo];
	
    NSValue* boundsValue = [userInfo objectForKey:UIKeyboardBoundsUserInfoKey];
    CGSize keyboardSize = [boundsValue CGRectValue].size;
    CGRect viewFrame = _scrollView.frame;
	
    viewFrame.size.height += (keyboardSize.height);
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:0.3];
	[_scrollView setFrame:viewFrame];
	[UIView commitAnimations];
	
	CGRect oldFrame=CGRectMake(_viewOffset.x, _viewOffset.y, viewFrame.size.width , viewFrame.size.height );
	[_scrollView scrollRectToVisible:oldFrame animated:YES];
	
    _keyboardIsShown = NO;
}


-(void)closeKeyboard{
	[_activeField resignFirstResponder];
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
	NSString  *efieldString=_loginUsernameField.text;
	BOOL eresult=[efieldString length]>kUsernameExtent;
	
	NSString  *pfieldString=_loginPasswordField.text;
	BOOL presult=[pfieldString length]>kpasswordExtent;
	
	if(presult==YES && eresult==YES){
		
		[self showRequestUIForView:_loginView];
		
		[[UserAccount sharedInstance] loginUserWithUserName:efieldString andPassword:pfieldString displayHUD:YES ];
		
	}else {
		if(eresult==NO){
			[self showMessageUIForView:_loginView withMessage:@"error_syntax_username"];
			return;
		}
		if(presult==NO){
			[self showMessageUIForView:_loginView withMessage:@"error_syntax_password"];
			return;
		}
	}
	
	
	
}

- (IBAction)registerButtonSelected:(id)sender {
	
	BetterLog(@"");
	
	NSString  *efieldString=_registerUsernameField.text;
	BOOL eresult=[efieldString length]>kUsernameExtent;
	
	NSString  *pfieldString=_registerPsswordField.text;
	BOOL presult=[pfieldString length]>kpasswordExtent;
	
	NSString  *visfieldString=_registerVisibleNameField.text;
	BOOL visresult=[visfieldString length]>kUsernameExtent;
	
	NSString  *emfieldString=_registerEmailField.text;
	BOOL emresult=[StringUtilities validateEmail:emfieldString]; 
	
	
	if(presult==YES && eresult==YES && emresult==YES && visresult==YES){
		
		[self showRequestUIForView:_registerView];
		
		[[UserAccount sharedInstance] registerUserWithUserName:_registerUsernameField.text 
												   andPassword:_registerPsswordField.text 
												   visibleName:_registerVisibleNameField.text 
														 email:_registerEmailField.text];
		
	}else {
		
		if (eresult==NO) {
			[self showMessageUIForView:_registerView withMessage:@"error_syntax_username"];
		}else if(presult==NO) {
			[self showMessageUIForView:_registerView withMessage:@"error_syntax_password"];
		}else if(visresult==NO) {
			[self showMessageUIForView:_registerView withMessage:@"error_syntax_visiblename"];
		}else if(emresult==NO) {
			[self showMessageUIForView:_registerView withMessage:@"error_syntax_email"];
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
	_viewMode=[UserAccount sharedInstance].accountMode;
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



@end
