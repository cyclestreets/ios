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

//  AssetTable.h
//  CycleStreets
//
//  Created by Alan Paxton on 19/08/2010.
//

#import <UIKit/UIKit.h>
@class ALAssetsGroup;
@class AssetImage;

@interface AssetTable : UITableViewController {

	NSMutableArray *assets;
	ALAssetsGroup *assetsGroup;
	AssetImage *assetImage;
}

//The group of assets we are interested in, and the assets we have enumerated in that group.
@property (nonatomic, strong) NSMutableArray *assets;
@property (nonatomic, strong) ALAssetsGroup *assetsGroup;
@property (nonatomic, strong) AssetImage *assetImage;

@end
