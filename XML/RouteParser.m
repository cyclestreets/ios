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

//  RouteParser.m
//  CycleStreets
//
//  Created by Alan Paxton on 03/03/2010.
//

#import "RouteParser.h"


@implementation RouteParser

@synthesize elementLists;
@synthesize categorisedElementLists;
@synthesize error;

- (NSMutableArray *)listPerElement:(NSArray *)elements {
	//build an empty dictionary for each element of interest. Collect them in a list.
	NSMutableArray *objects = [[[NSMutableArray alloc] init] autorelease];
	for (NSObject *element in elements) {
		NSMutableArray *list = [[NSMutableArray alloc] init];
		[objects addObject:list];
		[list release];
	}
	return objects;
}

- (id) initWithData:(NSData *)data forElements:(NSArray *)elements withCategories:(NSArray *)categories {
	if (self = [super init]) {
		XMLParser = [[NSXMLParser alloc] initWithData:data];
		
		//set up parse state to OK
		error = nil;
		
		//dictionary mapping element names of interest to the list of collected elements
		elementLists = [[NSMutableDictionary alloc] initWithObjects:[self listPerElement: elements] forKeys:elements];
		
		// stack of the current elements. pushed/popped when we pass the appropriate route or segment elements. Starts empty.
		elementStack = [[NSMutableArray alloc] init];
		
		// retain the list of names
		currentNames = [[NSMutableArray alloc] init];
		
		//dictionary mapping different groups to elementlists
		categorisedElementLists = [[NSMutableDictionary alloc] initWithObjects:[self listPerElement: categories] forKeys:categories];
	}
	return self;
}

- (id) initWithData:(NSData *)data forElements:(NSArray *)elements {
	return [self initWithData:data forElements:elements withCategories:[[[NSArray alloc] init] autorelease]];
}

// Parser convenience function.
+ (RouteParser *) parse:(NSData *)data forElements:(NSArray *)elements withCategories:(NSArray *)categories {
	RouteParser *parser = [[RouteParser alloc] initWithData: data forElements:elements withCategories:categories];
	[parser autorelease];
	[parser parse];
	return parser;
}

+ (RouteParser *) parse:(NSData *)data forElements:(NSArray *)elements {
	return [self parse:data forElements:elements withCategories:[[[NSArray alloc] init] autorelease]];
}

- (void) parse {
	[XMLParser setDelegate:self];
	[XMLParser parse];
}

#pragma mark parser delegate methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qualifiedName
	attributes:(NSDictionary *)attributeDict {
	[currentNames addObject:elementName];
	NSMutableArray *list = [elementLists objectForKey:elementName];
	if (list) {
		//this is an element gathered individually. Push a new dictionary for it.
		NSMutableDictionary *elementDict = [[NSMutableDictionary alloc] init];
		[list addObject:elementDict];
		[elementDict release]; //since it is retained by the dictionary.
		[elementStack addObject:elementDict]; //it is now the element we are filling.
		[elementDict addEntriesFromDictionary:attributeDict];
		
		//add the new dictionary also to the categories
		for (NSString *name in currentNames) {
			NSMutableArray *categorisedList = [categorisedElementLists objectForKey:name];
			if (categorisedList) {
				[categorisedList addObject:elementDict];
			}
		}
	}
}

- (void)parser:(NSXMLParser *)parser
 didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName {
	NSMutableArray *list = [elementLists objectForKey:elementName];
	[currentNames removeLastObject];
	if (list) {
		//pop completed dictionary from the element stack, as the element we are gathering has ended.
		if ([elementStack count] > 0) {
			[elementStack removeLastObject];
		}
	}
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	if ([elementStack count] > 0) {
		//use the current element as a simple key/value.
		NSMutableDictionary *elementDict = [elementStack lastObject];
		[elementDict setObject:string forKey:[currentNames lastObject]];
	}
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
	[elementLists release];
	elementLists = nil;
	error = parseError;
	[error retain];
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
	//nothing to do.
}

#pragma mark

- (void) dealloc {
	[XMLParser release];
	XMLParser = nil;
	[elementLists release];
	elementLists = nil;
	[categorisedElementLists release];
	categorisedElementLists = nil;
	[elementStack release];
	elementStack = nil;
	[currentNames release];
	currentNames = nil;
	[error release];
	error = nil;

	[super dealloc];
}

@end
