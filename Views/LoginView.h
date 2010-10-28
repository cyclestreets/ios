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
@class BusyAlert;

@protocol LoginDelegate
- (void)didLogin:(NSString *)username withPassword:(NSString *)password;
- (void)didRegister:(NSString *)username
	   withPassword:(NSString *)password
		  withEmail:(NSString *)email
		   withName:(NSString *)visibleName;
- (void)didCancel;
@end

@interface LoginView : UIViewController {
	UISegmentedControl *loginOrRegister;
	
	UITextField *username;
	UITextField *password;
	
	UIButton *loginButton;
	
	UITextField *email;
	UITextField *visibleName;

	UIButton *registerButton;
	
	NSObject <LoginDelegate> *loginDelegate;
}

@property (nonatomic, retain) IBOutlet UITextField *username;
@property (nonatomic, retain) IBOutlet UITextField *password;
@property (nonatomic, retain) IBOutlet UIButton *loginButton;
@property (nonatomic, retain) IBOutlet UITextField *email;
@property (nonatomic, retain) IBOutlet UITextField *visibleName;
@property (nonatomic, retain) IBOutlet UIButton *registerButton;
@property (nonatomic, retain) IBOutlet UISegmentedControl *loginOrRegister;

@property (nonatomic, retain) NSObject <LoginDelegate> *loginDelegate;

-(IBAction)didLoginButton;
-(IBAction)didRegisterButton;
-(IBAction)didCancelButton;
-(IBAction)textFieldReturn:(id)sender;
-(IBAction)didToggle;

-(void)clearFields;

@end
