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

//  Credits.m
//  CycleStreets
//
//  Created by Alan Paxton on 09/03/2010.
//

#import "Credits.h"
#import "WebPopup.h"
#import "UIButton+Blue.h"
#import "Common.h"

@implementation Credits

@synthesize webView;
@synthesize homeButton;
@synthesize failAlert;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

- (void)home {
	NSString *creditsFilePath = [[NSBundle mainBundle] pathForResource:@"credits" ofType:@"html"];
	NSURL *creditsURL = [NSURL fileURLWithPath:creditsFilePath];
	[self.webView loadRequest:[NSURLRequest requestWithURL:creditsURL]];	
	[self.webView setDelegate:self];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.homeButton = [[[UIBarButtonItem alloc] initWithTitle:@"Credits Home" style:UIBarButtonItemStyleBordered target:self action:@selector(didHome)] autorelease];
	self.navigationItem.rightBarButtonItem = self.homeButton;
	
	[self home];
}

- (void)didHome {
	[self home];
}

#pragma mark web view delegate

- (void)webViewDidStartLoad:(UIWebView *)webView {
	DLog(@"webViewDidStartLoad");
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	DLog(@"webViewDidFinishLoad");
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	DLog(@"webView:didFailLoadWithError");
	if (self.failAlert == nil) {
		self.failAlert = [[[UIAlertView alloc] initWithTitle:@"CycleStreets"
													 message:@"Unable to load web page."
													delegate:nil
										   cancelButtonTitle:@"OK"
										   otherButtonTitles:nil]
						  autorelease];
	}
	[self.failAlert show];
}

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

- (void)nullify {
	self.webView = nil;
	self.homeButton = nil;
	self.failAlert = nil;
}

- (void)viewDidUnload {
	[self nullify];
    [super viewDidUnload];
	DLog(@">>>");
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[self nullify];
    [super dealloc];
}


@end
