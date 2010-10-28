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

//  AssetImage.m
//  CycleStreets
//
//  Created by Alan Paxton on 19/08/2010.
//

#import "AssetImage.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "Common.h"

@implementation AssetImage

@synthesize image;
@synthesize asset;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

- (void)didCancelSelection {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"NotificationLibraryAsset" object:nil];
	[self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)didUseSelection {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"NotificationLibraryAsset" object:self.asset];
	[self.navigationController popToRootViewControllerAnimated:YES];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	UIBarButtonItem *cancelButton = [[[UIBarButtonItem alloc] initWithTitle:@"Cancel"
																	  style:UIBarButtonItemStyleDone
																	 target:self
																	 action:@selector(didCancelSelection)]
									 autorelease];
	UIBarButtonItem *gap = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
																		  target:nil
																		  action:nil]
							autorelease];
	UIBarButtonItem *useButton = [[[UIBarButtonItem alloc] initWithTitle:@"Use"
																   style:UIBarButtonItemStyleDone
																  target:self
																  action:@selector(didUseSelection)]
								  autorelease];
	useButton.width = 100;
	self.toolbarItems = [NSArray arrayWithObjects:cancelButton, gap, useButton, nil];
	[self.navigationController setToolbarHidden:NO];	
	
}

-(void)setAsset:(ALAsset *)newAsset {
	[newAsset retain];
	[asset release];
	asset = newAsset;
	
	ALAssetRepresentation *representation = [asset defaultRepresentation];
	self.image.image = [UIImage imageWithCGImage:[representation fullScreenImage]
										   scale:[representation scale]
									 orientation:[representation orientation]];
	
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
	self.image = nil;
	self.asset = nil;
}

- (void)viewDidUnload {
	DLog(@">>>");
	[self nullify];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[self nullify];
    [super dealloc];
}


@end
