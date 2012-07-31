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

#import "GlobalUtilities.h"

@implementation AssetGroupTable

@synthesize assetLibrary;
@synthesize assetGroups;
@synthesize currentGroup;

#pragma mark -
#pragma mark Initialization



#pragma mark -
#pragma mark View lifecycle

- (void)loadGroups {
	self.assetGroups = [[NSMutableArray alloc] init];
	if (self.assetLibrary == nil) {
		self.assetLibrary = [[ALAssetsLibrary alloc] init];
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
	
	

	((UITableView *)self.view).rowHeight = 80;
	
	UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
																	  style:UIBarButtonItemStyleBordered
																	 target:self
																	 action:@selector(didCancelSelection)];
	self.navigationController.toolbar.tintColor=UIColorFromRGB(0x008000);
	self.navigationController.navigationBar.tintColor=UIColorFromRGB(0x008000);
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


#pragma mark -
#pragma mark asset library

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
     return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.assetGroups == nil) {
		return 0;
	}
    return [self.assetGroups count];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"AssetGroupTableCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
	ALAssetsGroup *assetGroup = [assetGroups objectAtIndex:indexPath.row];
	cell.imageView.image = [UIImage imageWithCGImage:[assetGroup posterImage]];
	cell.textLabel.text = [assetGroup valueForProperty:ALAssetsGroupPropertyName];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}





#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
	if (self.currentGroup == nil) {
		self.currentGroup = [[AssetTable alloc] init];
	}
	self.currentGroup.assetsGroup = [assetGroups objectAtIndex:indexPath.row];
	[self.navigationController pushViewController:self.currentGroup animated:YES];
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (void)nullify {
	self.assetGroups = nil;
	self.assetLibrary = nil;
	self.currentGroup = nil;	
}

- (void)viewDidUnload {
    [self nullify];
	[super viewDidUnload];
}


- (void)dealloc {
	[self nullify];
}


@end

