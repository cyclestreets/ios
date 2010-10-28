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
#import "UIButton+Blue.h"
#import "Common.h"
#import "BusyAlert.h"

@implementation LoginView

@synthesize username;
@synthesize password;
@synthesize loginButton;
@synthesize email;
@synthesize visibleName;
@synthesize registerButton;
@synthesize loginOrRegister;

@synthesize loginDelegate;

- (void)showCorrectMode {
	NSString *selected = [loginOrRegister titleForSegmentAtIndex:[loginOrRegister selectedSegmentIndex]];
	if ([[selected lowercaseString] isEqualToString:@"login"]) {
		email.hidden = YES;
		visibleName.hidden = YES;
		password.returnKeyType = UIReturnKeyGo;
	} else {
		email.hidden = NO;
		visibleName.hidden = NO;
		password.returnKeyType = UIReturnKeyDefault;
		email.returnKeyType = UIReturnKeyGo;
	}
	loginButton.hidden = YES;
	registerButton.hidden = YES;
}

- (void)viewDidLoad {
	[loginButton setupBlue];
	[registerButton setupBlue];
	[self showCorrectMode];
}

- (IBAction)didLoginButton {
	DLog(@"didLoginButton");
	[loginDelegate didLogin:username.text withPassword:password.text];
}

- (IBAction)didRegisterButton {
	DLog(@">>>");
	[loginDelegate didRegister:username.text
				  withPassword:password.text
					 withEmail:email.text
					  withName:visibleName.text];
}

-(IBAction)textFieldReturn:(id)sender
{
	[sender resignFirstResponder];
	NSString *selected = [loginOrRegister titleForSegmentAtIndex:[loginOrRegister selectedSegmentIndex]];
	if (sender == password && [[selected lowercaseString] isEqualToString:@"login"]) {
		[loginDelegate didLogin:username.text withPassword:password.text];
	} else if (sender == email) {
		[loginDelegate didRegister:username.text
					  withPassword:password.text
						 withEmail:email.text
						  withName:visibleName.text];		
	}
}

-(IBAction)didCancelButton {
	[loginDelegate didCancel];
}

-(IBAction)didToggle {
	[self showCorrectMode];
}

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

-(void)clearFields {
	self.username.text = @"";
	self.password.text = @"";
	self.email.text = @"";
	self.visibleName.text = @"";
}

- (void)nullify {
	self.username = nil;
	self.password = nil;
	self.loginButton = nil;
	self.email = nil;
	self.visibleName = nil;
	self.registerButton = nil;
	self.loginDelegate = nil;
}

- (void)viewDidUnload {
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	[self nullify];
	[super viewDidUnload];
	DLog(@">>>");
}


- (void)dealloc {
	[self nullify];
    [super dealloc];
}


@end
