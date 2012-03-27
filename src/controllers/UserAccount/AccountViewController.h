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

//  LoginView.h
//  BaseLib
//
//  Created by Alan Paxton on 26/05/2010.
//

#import <UIKit/UIKit.h>
#import "UserAccount.h"
#import "LayoutBox.h"
#import "SuperViewController.h"


#define kSubmitButtonTag 499
#define	kActivityTag 500
#define	kMessageFieldTag 501
#define kpasswordExtent 4
#define	kUsernameExtent 5

@interface AccountViewController : SuperViewController <UITextFieldDelegate,UIScrollViewDelegate>{
	
	UIView                              *activeView;
	
	IBOutlet			UIScrollView	*scrollView;
	IBOutlet			UIPageControl	*pageControl;
	IBOutlet			UIView			*pageControlView;
	
	IBOutlet			UILabel			*leftLabel;
	IBOutlet			UILabel			*rightLabel;
	
	
	LayoutBox                           *contentView;
	
	// not logged in
	IBOutlet UITextField                *loginUsernameField;
	IBOutlet UITextField                *loginPasswordField;
	IBOutlet UIButton                   *loginButton;
	IBOutlet	UIView                  *loginView;
	
	// register
	IBOutlet UITextField                *registerUsernameField;
	IBOutlet UITextField                *registerVisibleNameField;
	IBOutlet UITextField                *registerEmailField;
	IBOutlet UITextField                *registerPsswordField;
	IBOutlet UIButton					*registerButton;
	IBOutlet UIView						*registerView;
	
	//password
	IBOutlet	UITextField				*retrieveEmailField;
	IBOutlet	UIView					*retrieveView;
	
	
	// logged in
	IBOutlet		UILabel				*loggedInasField;
	IBOutlet		UIButton			*logoutButton;
	IBOutlet		UISwitch			*saveLoginButton;
	IBOutlet		UIView				*loggedInView;
	
	
	//state
	int									activePage;
	int									activeFieldIndex;
	CGRect								activeFieldFrame;
	NSMutableArray						*activeFieldArray;
	UITextField							*activeField;
	BOOL								keyboardIsShown;
	CGPoint								viewOffset;
	UIButton							*activeFormSubmitButton;
	UIActivityIndicatorView				*activeActivityView;
	UILabel								*activeFormMessageLabel;	
	UserAccountMode						viewMode;
	NSMutableArray						*formFieldArray;
	
	
	BOOL								isModal;
	BOOL								shouldAutoClose;
	
}
@property (nonatomic, retain)		IBOutlet UIView				* activeView;
@property (nonatomic, retain)		IBOutlet UIScrollView				* scrollView;
@property (nonatomic, retain)		IBOutlet UIPageControl				* pageControl;
@property (nonatomic, retain)		IBOutlet UIView				* pageControlView;
@property (nonatomic, retain)		IBOutlet UILabel				* leftLabel;
@property (nonatomic, retain)		IBOutlet UILabel				* rightLabel;
@property (nonatomic, retain)		LayoutBox				* contentView;
@property (nonatomic, retain)		IBOutlet UITextField				* loginUsernameField;
@property (nonatomic, retain)		IBOutlet UITextField				* loginPasswordField;
@property (nonatomic, retain)		IBOutlet UIButton				* loginButton;
@property (nonatomic, retain)		IBOutlet UIView				* loginView;
@property (nonatomic, retain)		IBOutlet UITextField				* registerUsernameField;
@property (nonatomic, retain)		IBOutlet UITextField				* registerVisibleNameField;
@property (nonatomic, retain)		IBOutlet UITextField				* registerEmailField;
@property (nonatomic, retain)		IBOutlet UITextField				* registerPsswordField;
@property (nonatomic, retain)		IBOutlet UIButton				* registerButton;
@property (nonatomic, retain)		IBOutlet UIView				* registerView;
@property (nonatomic, retain)		IBOutlet UITextField				* retrieveEmailField;
@property (nonatomic, retain)		IBOutlet UIView				* retrieveView;
@property (nonatomic, retain)		IBOutlet UILabel				* loggedInasField;
@property (nonatomic, retain)		IBOutlet UIButton				* logoutButton;
@property (nonatomic, retain)		IBOutlet UISwitch				* saveLoginButton;
@property (nonatomic, retain)		IBOutlet UIView				* loggedInView;
@property (nonatomic)		int				 activePage;
@property (nonatomic)		int				 activeFieldIndex;
@property (nonatomic)		CGRect				 activeFieldFrame;
@property (nonatomic, retain)		NSMutableArray				* activeFieldArray;
@property (nonatomic, retain)		IBOutlet UITextField				* activeField;
@property (nonatomic)		BOOL				 keyboardIsShown;
@property (nonatomic)		CGPoint				 viewOffset;
@property (nonatomic, retain)		IBOutlet UIButton				* activeFormSubmitButton;
@property (nonatomic, retain)		IBOutlet UIActivityIndicatorView				* activeActivityView;
@property (nonatomic, retain)		IBOutlet UILabel				* activeFormMessageLabel;
@property (nonatomic)		UserAccountMode				 viewMode;
@property (nonatomic, retain)		NSMutableArray				* formFieldArray;
@property (nonatomic)		BOOL				 isModal;
@property (nonatomic)		BOOL				 shouldAutoClose;


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
