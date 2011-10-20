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

//  Favourites.h
//  CycleStreets
//
//  Created by Alan Paxton on 09/03/2010.
//

#import <UIKit/UIKit.h>
@class Route;
@class RouteSummary;

@interface FavouritesViewController : UITableViewController {
	NSMutableArray *favourites;
	NSMutableDictionary *routes;
	RouteSummary *routeSummary;
	
	
	// rowHeights
	NSMutableArray  *rowHeightsArray;
}

@property (nonatomic, retain)	NSMutableArray	*favourites;
@property (nonatomic, retain)	NSMutableDictionary	*routes;
@property (nonatomic, retain)	RouteSummary	*routeSummary;
@property (nonatomic, retain)	NSMutableArray	*rowHeightsArray;

- (Route *) routeWithIdentifier:(NSInteger)identifier;

- (void) clear;

-(void)createRowHeightsArray;

-(IBAction)retrieveRouteByNumberButtonSelected:(id)sender;


-(void)routeByIdResponse;

@end
