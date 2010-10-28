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

//  AssetGroupTable.m
//  CycleStreets
//
//  Created by Alan Paxton on 19/08/2010.
//

#import "AssetGroupTable.h"
#import "AssetTable.h"
#import <CoreLocation/CoreLocation.h>
#import "Common.h"

@implementation AssetGroupTable

@synthesize assetLibrary;
@synthesize assetGroups;
@synthesize currentGroup;

#pragma mark -
#pragma mark Initialization

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if ((self = [super initWithStyle:style])) {
    }
    return self;
}
*/


#pragma mark -
#pragma mark View lifecycle

- (void)loadGroups {
	self.assetGroups = [[[NSMutableArray alloc] init] autorelease];
	if (self.assetLibrary == nil) {
		self.assetLibrary = [[[ALAssetsLibrary alloc] init] autorelease];
	}
	[self.assetLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos | ALAssetsGroupLibrary
									 usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
										 if (group != nil) {
											 [self.assetGroups addObject:group];
										 } else {
											 [(UITableView *)self.view reloadData];
										 }
									 }
								   failureBlock:^(NSError *error) {
								   }
	 ];
}

- (void)assetsChanged {
	[self loadGroups];
}

- (void)didCancelSelection {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"NotificationLibraryAsset" object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
	((UITableView *)self.view).rowHeight = 80;
	
	UIBarButtonItem *cancelButton = [[[UIBarButtonItem alloc] initWithTitle:@"Cancel"
																	  style:UIBarButtonItemStyleBordered
																	 target:self
																	 action:@selector(didCancelSelection)]
									 autorelease];
	self.toolbarItems = [NSArray arrayWithObject:cancelButton];
	[self.navigationController setToolbarHidden:NO];
	self.title = @"Photos";
	
	//register for asset changes.
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(assetsChanged)
												 name:ALAssetsLibraryChangedNotification
											   object:nil];
	[self loadGroups];
}

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

#pragma mark -
#pragma mark asset library

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	if (self.assetGroups == nil) {
		return 0;
	}
    return [self.assetGroups count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"AssetGroupTableCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
	ALAssetsGroup *assetGroup = [assetGroups objectAtIndex:indexPath.row];
	cell.imageView.image = [UIImage imageWithCGImage:[assetGroup posterImage]];
	cell.textLabel.text = [assetGroup valueForProperty:ALAssetsGroupPropertyName];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	if (self.currentGroup == nil) {
		self.currentGroup = [[[AssetTable alloc] init] autorelease];
	}
	self.currentGroup.assetsGroup = [assetGroups objectAtIndex:indexPath.row];
	[self.navigationController pushViewController:self.currentGroup animated:YES];
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)nullify {
	self.assetGroups = nil;
	self.assetLibrary = nil;
	self.currentGroup = nil;	
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
	[self nullify];
	[super viewDidUnload];
}


- (void)dealloc {
	[self nullify];
    [super dealloc];
}


@end

