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

//  AssetGroupTable.h
//
//  Created by Alan Paxton on 19/08/2010.
//
//  This file is part of CycleStreets for iOS.
//  
//  CycleStreets for iOS is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//  
//  CycleStreets for iOS is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//  
//  You should have received a copy of the GNU General Public License
//  along with CycleStreets for iOS.  If not, see <http://www.gnu.org/licenses/>.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
@class AssetTable;

@interface AssetGroupTable : UITableViewController {

	ALAssetsLibrary *assetLibrary;
	NSMutableArray *assetGroups;
	AssetTable *currentGroup;
}

@property (nonatomic, retain) ALAssetsLibrary *assetLibrary;
@property (nonatomic, retain) NSMutableArray *assetGroups;
@property (nonatomic, retain) AssetTable *currentGroup;

@end
