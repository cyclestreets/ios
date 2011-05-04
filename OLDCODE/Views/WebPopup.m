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

//  WebPopup.m
//  CycleStreets
//
//  Created by Alan Paxton on 22/03/2010.
//

#import "WebPopup.h"
#import "Common.h"

@implementation WebPopup

@synthesize webView;


+ (void) popup:(NSURL *)url over:(UIViewController *)parent {
	WebPopup *controller = [[[WebPopup alloc] initWithNibName:@"WebPopup" bundle:nil] autorelease];
	[parent presentModalViewController:controller animated:NO];
	[controller.webView loadRequest:[NSURLRequest requestWithURL:url]];
}


- (void) didDone {
	[self dismissModalViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)nullify {
	self.webView = nil;
}

- (void)viewDidUnload {
    [self nullify];
	[super viewDidUnload];
}


- (void)dealloc {
	[self nullify];
    [super dealloc];
}


@end
