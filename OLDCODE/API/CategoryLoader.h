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
#import "SynthesizeSingleton.h"
@class Categories;

@interface CategoryLoader : NSObject {
	@private NSArray *categories;
	@private NSArray *categoryLabels;
	@private NSArray *metaCategories;
	@private NSArray *metaCategoryLabels;	
}
SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(CategoryLoader);
@property (nonatomic, strong) NSArray *categories;
@property (nonatomic, strong) NSArray *categoryLabels;
@property (nonatomic, strong) NSArray *metaCategories;
@property (nonatomic, strong) NSArray *metaCategoryLabels;
@property (nonatomic, strong) Categories *categoriesAPIMethod;

- (void) setupCategories;

+ (NSString *)defaultCategory;
+ (NSString *)defaultMetaCategory;
@end
