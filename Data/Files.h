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

//  Files.h
//  CycleStreets
//
//  Created by Alan Paxton on 09/03/2010.
//

#import <Foundation/Foundation.h>


@interface Files : NSObject {
	NSString *documentsDirectory;
	NSString *clientid;
}

@property (nonatomic, copy) NSString *clientid;

#pragma mark file constant functions

// file with plist of routing settings
- (NSString *) settingsFile;

// file with plist of misc bits
- (NSString *) miscFile;

// directory containing files named by route-id. Each is just the route XML.
- (NSString *) routesDirectory;

// file with list of favourites objects.
- (NSString *) favouritesFile;

// once-off file for logging to routing calls
- (NSString *) clientidFile;

#pragma mark methods

// the plist of settings
- (NSDictionary *) settings;

- (void)setSettings:(NSDictionary *) newSettings;

- (NSDictionary *) photoCategories;

- (void)setPhotoCategories:(NSDictionary *) newCategories;

- (NSDictionary *) photoLocations;

- (void)setPhotoLocations:(NSDictionary *) newLocations;

// the plist of misc
- (NSDictionary *) misc;

// set the entirety
- (void)setMisc:(NSDictionary *) newMisc;

// get a single value
-(NSString *)miscValueForKey:(NSString *)key;

// set a single value
-(void)setMiscValue:(NSString *)value forKey:(NSString *)key;

// password through KeyChain
- (void)setPassword:(NSString *)password;

- (NSString *)password;

- (void)resetPasswordInKeyChain;

// list the serial numbers of the routes which are favourites
- (NSArray *) favourites;

// save the new favourites list
- (void)setFavourites:(NSArray *) newFavourites;

// retrieve the XML of a route
- (NSData *) route:(NSInteger) routeIdentifier;

// save the data of a route - route may be a new route
- (void)setRoute:(NSInteger) routeIdentifier data:(NSData *)xml;

// remove the route file.
- (void)deleteRoute:(NSInteger) routeIdentifier;

@end
