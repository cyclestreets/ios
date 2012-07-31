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

//  RouteParser.h
//  CycleStreets
//
//  Created by Alan Paxton on 03/03/2010.
//

#import <Foundation/Foundation.h>


@interface RouteParser : NSObject <NSXMLParserDelegate> {
	NSXMLParser *XMLParser;
	NSDictionary *elementLists;
	NSDictionary *categorisedElementLists;
	NSMutableArray *elementStack;
	NSMutableArray *currentNames;
	NSError *__unsafe_unretained error;
}

@property (nonatomic, readonly) NSDictionary *elementLists;
@property (nonatomic, readonly) NSDictionary *categorisedElementLists;
@property (unsafe_unretained, nonatomic, readonly) NSError *error;

- (id) initWithData:(NSData *)data forElements:(NSArray *)elements withCategories:(NSArray *)categories;

- (id) initWithData:(NSData *)data forElements:(NSArray *)elements;

+ (RouteParser *) parse:(NSData *)data forElements:(NSArray *)elements withCategories:(NSArray *)categories;

+ (RouteParser *) parse:(NSData *)data forElements:(NSArray *)elements;

- (void) parse;

@end
