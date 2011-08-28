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

//  CategoryLoader.h
//  CycleStreets
//
//  Created by Alan Paxton on 04/08/2010.
//

#import <Foundation/Foundation.h>
@class Categories;

@interface CategoryLoader : NSObject {
	@private NSArray *categories;
	@private NSArray *categoryLabels;
	@private NSArray *metaCategories;
	@private NSArray *metaCategoryLabels;	
}

@property (nonatomic, retain) NSArray *categories;
@property (nonatomic, retain) NSArray *categoryLabels;
@property (nonatomic, retain) NSArray *metaCategories;
@property (nonatomic, retain) NSArray *metaCategoryLabels;
@property (nonatomic, retain) Categories *categoriesAPIMethod;

- (void) setupCategories;

+ (NSString *)defaultCategory;
+ (NSString *)defaultMetaCategory;
@end
