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

//  BusyAlert.m
//  Properties
//
//  Created by Alan Paxton on 01/03/2010.
//

#import "BusyAlert.h"


@implementation BusyAlert

@synthesize cancelDelegate;



- (id) initWithTitle:(NSString *)title message:(NSString *)message cancel:(NSObject <BusyAlertDelegate> *)cancel {
	if (self = [super init]) {
		self.cancelDelegate = cancel;
		NSString *cancelString = @"Cancel";
		if (cancelDelegate == nil) {
			cancelString = nil;
		}		
		alert = [[UIAlertView alloc]
					  initWithTitle:title
					  message:message
					  delegate:self
					  cancelButtonTitle:cancelString
					  otherButtonTitles:nil];
		spinner = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleGray] autorelease];
		[alert addSubview:spinner];
	}
	return self;
}

- (id) initWithTitle:(NSString *)title message:(NSString *)message {
	return [self initWithTitle:title message:message cancel:nil];
}

- (void)alertViewCancel:(UIAlertView *)alertView {
	[self.cancelDelegate didCancelAlert];
}

- (void) show:(NSString *)message;
{
	alert.message = message;	 
	[alert show];
	CGRect frame;
	frame.origin.y = alert.frame.size.height/2 - 20;
	frame.origin.x = alert.frame.size.width/2 - 40;
	frame.size.width = 40;
	frame.size.height = 40;
	spinner.frame = frame;	
	[spinner startAnimating];
}

- (void) hide {
	[spinner stopAnimating];
	[alert dismissWithClickedButtonIndex:-1 animated:NO];	
}

- (void) dealloc {
	[alert release];
	[spinner release];
	[super dealloc];
}

@end
