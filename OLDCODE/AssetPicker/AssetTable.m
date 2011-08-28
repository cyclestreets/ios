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

//  AssetTable.m
//  CycleStreets
//
//  Created by Alan Paxton on 19/08/2010.
//

#import "AssetTable.h"
#import "AssetImage.h"
#import "ALAsset+Info.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <CoreLocation/CoreLocation.h>
#import "GlobalUtilities.h"


@implementation AssetTable

@synthesize assets;
@synthesize assetImage;

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

-(ALAssetsGroup *)assetsGroup {
	return assetsGroup;
}

-(void)setAssetsGroup:(ALAssetsGroup *)newAssetsGroup {
	[newAssetsGroup retain];
	[assetsGroup release];
	assetsGroup = newAssetsGroup;
	self.title = [self.assetsGroup valueForProperty:ALAssetsGroupPropertyName];
	self.assets = [[[NSMutableArray alloc] init] autorelease];
	
	[newAssetsGroup enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
		if (result != nil) {
			//insert latest first
			[self.assets insertObject:result atIndex:0];
		} else {
			[(UITableView *)self.view reloadData];
		}
	}];	
}

/*
 * begin test code
 */

/*
- (void)testProcessAssetsGroup:(ALAssetsGroup *)group {
	[group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
		ALAssetRepresentation *representation = [result defaultRepresentation];
		NSDictionary *metadata = [representation metadata];
		
		CLLocation *assetLocation = [result valueForProperty:ALAssetPropertyLocation];
		NSDate *date = [result valueForProperty:ALAssetPropertyDate];
		CLLocationCoordinate2D coordinate = assetLocation.coordinate;
		if (CLLocationCoordinate2DIsValid(coordinate)) {
			BetterLog(@"asset %@ %@ %@", [result description], [assetLocation description], [date description]);
		}
	}];
}
 */

/*
 * end test code
 */



#pragma mark -
#pragma mark View lifecycle

- (void)didCancelSelection {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"NotificationLibraryAsset" object:nil];
	[self.navigationController popToRootViewControllerAnimated:YES];
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
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	if (self.assets == nil) {
		return 0;
	}
	return [self.assets count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"AssetTableCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
	ALAsset *asset = [self.assets objectAtIndex:indexPath.row];
	cell.imageView.image = [UIImage imageWithCGImage:[asset thumbnail]];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	NSDateFormatter *fmt = [[[NSDateFormatter alloc] init] autorelease];
	[fmt setDateStyle:NSDateFormatterMediumStyle];
	cell.textLabel.text = [fmt stringFromDate:[asset date]];
	
	//comment these out except when debugging, as they access the file and are slow
	//CLLocationCoordinate2D coordinate = [asset location];
	//BetterLog(@"asset location %@", [NSString stringWithFormat:@"%f, %f", coordinate.latitude, coordinate.longitude]);
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


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
	if (self.assetImage == nil) {
		self.assetImage = [[[AssetImage alloc] initWithNibName:@"AssetImage" bundle:nil] autorelease];
	}
	[self.navigationController pushViewController:self.assetImage animated:YES];
	self.assetImage.asset = [assets objectAtIndex:indexPath.row];
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)nullify {
	self.assets = nil;
	[assetsGroup release];
	assetsGroup = nil;
	self.assetImage = nil;	
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
	BetterLog(@">>>");
	[self nullify];
	[super viewDidUnload];
}


- (void)dealloc {
	[self nullify];
    [super dealloc];
}


@end

