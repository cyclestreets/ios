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

//  Donate.m
//  CycleStreets
//
//  Created by Alan Paxton on 07/09/2010.
//

#import "DonateViewController.h"
#import "Common.h"

@implementation DonateViewController

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
	NSString *donateFilePath = [[NSBundle mainBundle] pathForResource:@"donate" ofType:@"html"];
	NSURL *donateURL = [NSURL fileURLWithPath:donateFilePath];
	[self.webView loadRequest:[NSURLRequest requestWithURL:donateURL]];	
	[self.webView setDelegate:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.homeButton = [[[UIBarButtonItem alloc] initWithTitle:@"Donate Home" style:UIBarButtonItemStyleBordered target:self action:@selector(didHome)] autorelease];
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

- (void)viewDidUnload {
	self.webView = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	self.webView = nil;
    [super dealloc];
}


@end
