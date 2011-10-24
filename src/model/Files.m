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

//  Files.m
//  CycleStreets
//
//  Created by Alan Paxton on 09/03/2010.
//

#import "Files.h"
#import "KeyChainItemWrapper.h"

static NSString *settingsFileConst = @"settings";
static NSString *miscFileConst = @"misc";
static NSString *categoriesFileConst = @"category";
static NSString *favouritesFileConst = @"favourites";
static NSString *locationsFileConst = @"locations";
static NSString *routesDirectoryConst = @"routes";
static NSString *clientidFileConst = @"clientid";

@implementation Files

@synthesize clientid;

- (id) init {
	if (self = [super init]) {
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		documentsDirectory = [[paths objectAtIndex:0] copy];
		
		[[NSFileManager defaultManager] createDirectoryAtPath:[self routesDirectory] withIntermediateDirectories:YES attributes:nil error:nil];
		
		if (![[NSFileManager defaultManager] isWritableFileAtPath:[self clientidFile]]) {
			//one-off generate the clientid file
			NSString *unescaped = [NSString stringWithFormat:@"CSiPhoneAppV100 %@",[[NSDate date] description]];
			NSString *escaped = [unescaped stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
			[escaped writeToFile:[self clientidFile] atomically:YES encoding:NSUTF8StringEncoding error:nil];
		}
		clientid = [[NSString stringWithContentsOfFile:[self clientidFile] encoding:NSUTF8StringEncoding error:nil] retain];
	}
	return self;
}

// file with plist of settings
- (NSString *) settingsFile {
	return [documentsDirectory stringByAppendingPathComponent:settingsFileConst];
}

// file with plist of misc
- (NSString *) miscFile {
	return [documentsDirectory stringByAppendingPathComponent:miscFileConst];
}

// file with list of favourites objects.
- (NSString *) favouritesFile {
	return [documentsDirectory stringByAppendingPathComponent:favouritesFileConst];
}

// file with list of favourites objects.
- (NSString *) categoriesFile {
	return [documentsDirectory stringByAppendingPathComponent:categoriesFileConst];
}

// file with list of favourites objects.
- (NSString *) locationsFile {
	return [documentsDirectory stringByAppendingPathComponent:locationsFileConst];
}

// directory containing files named by route-id. Each is just the route XML.
- (NSString *) routesDirectory {
	return [documentsDirectory stringByAppendingPathComponent:routesDirectoryConst];
}

// the plist of settings
- (NSDictionary *) settings {
	NSDictionary *result = [NSDictionary dictionaryWithContentsOfFile:[self settingsFile]];
	//NSLog(@"settings=%@",result);
	if (result == nil) {
		result = [NSDictionary dictionaryWithObjectsAndKeys:nil];
	}
	return result;
}

// the plist of misc
- (NSDictionary *) misc {
	NSDictionary *result = [NSDictionary dictionaryWithContentsOfFile:[self miscFile]];
	if (result == nil) {
		result = [NSDictionary dictionaryWithObjectsAndKeys:nil];
	}
	return result;
}

// the plist of photos
- (NSDictionary *) photoCategories {
	NSDictionary *result = [NSDictionary dictionaryWithContentsOfFile:[self categoriesFile]];
	if (result == nil) {
		result = [NSDictionary dictionaryWithObjectsAndKeys:nil];
	}
	return result;
}

// the plist of locations
- (NSDictionary *) photoLocations {
	NSDictionary *result = [NSDictionary dictionaryWithContentsOfFile:[self locationsFile]];
	if (result == nil) {
		result = [NSDictionary dictionaryWithObjectsAndKeys:nil];
	}
	return result;
}

// set the plist of settings.
- (void)setSettings:(NSDictionary *) newSettings {
	[newSettings writeToFile:[self settingsFile] atomically:YES];
}

// set the plist of categories.
- (void)setPhotoCategories:(NSDictionary *) newCategories {
	[newCategories writeToFile:[self categoriesFile] atomically:YES];
}

// set the plist of locations.
- (void)setPhotoLocations:(NSDictionary *) newLocations {
	[newLocations writeToFile:[self locationsFile] atomically:YES];
}

// get a single value
-(NSString *)miscValueForKey:(NSString *)key {
	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:[self miscFile]];
	if (dict == nil) {
		dict = [NSDictionary dictionaryWithObjectsAndKeys:nil];
	}
	return [dict valueForKey:key];	
}

// set a single value
-(void)setMiscValue:(NSString *)value forKey:(NSString *)key {
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:[self miscFile]];
	if (dict == nil) {
		dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:nil];
	}
	[dict setValue:value forKey:key];
	[dict writeToFile:[self miscFile] atomically:YES];
}

// set the plist of misc.
- (void)setMisc:(NSDictionary *) newMisc {
	[newMisc writeToFile:[self miscFile] atomically:YES];
}

// password through KeyChain
- (void)setPassword:(NSString *)password {
	
	KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"net.cyclestreets.password" accessGroup:nil];
	[wrapper setObject:password forKey:(id)kSecValueData];
	[wrapper release];
}

- (NSString *)password {
	KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"net.cyclestreets.password" accessGroup:nil];
	NSString *value = [wrapper objectForKey:(id)kSecValueData];
	[wrapper release];
	return value;
}

- (void)resetPasswordInKeyChain {
	KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"net.cyclestreets.password" accessGroup:nil];
	[wrapper resetKeychainItem];
	[wrapper release];
}

// list the serial numbers of the routes which are favourites
- (NSMutableArray *) favourites {
	NSMutableArray *result = [NSMutableArray arrayWithContentsOfFile:[self favouritesFile]];
	if (nil == result) {
		// empty array is the default.
		result = [NSMutableArray array];
	}
	return result;	
}

// save the new favourites list
- (void)setFavourites:(NSArray *) newFavourites {
	[newFavourites writeToFile:[self favouritesFile] atomically:YES];
}

// retrieve the XML of a route
- (RouteVO *) route:(NSInteger) routeIdentifier {
	NSString *routeFile = [[self routesDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"%d", routeIdentifier]];
	
	NSMutableData *data = [[NSMutableData alloc] initWithContentsOfFile:routeFile];
	NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
	RouteVO *route = [unarchiver decodeObjectForKey:kROUTEARCHIVEKEY];
	[unarchiver finishDecoding];
	[unarchiver release];
	[data release];
	
	return route;
}

// save the data of a route - route may be a new route
- (void)setRoute:(NSInteger) routeIdentifier data:(RouteVO *)route {
	
	NSString *routeFile = [[self routesDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"%d", routeIdentifier]];
	
	NSMutableData *data = [[NSMutableData alloc] init];
	NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
	[archiver encodeObject:route forKey:kROUTEARCHIVEKEY];
	[archiver finishEncoding];
	[data writeToFile:routeFile atomically:YES];
	
	[data release];
	[archiver release];
	
}

// remove the route file.
- (void)deleteRoute:(NSInteger) routeIdentifier {
	NSString *routeFile = [[self routesDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"%d", routeIdentifier]];
	NSError *error = [[[NSError alloc] init] autorelease];
	[[NSFileManager defaultManager] removeItemAtPath:routeFile error:&error];
}

// once-off file for logging to routing calls
- (NSString *) clientidFile {
	return [documentsDirectory stringByAppendingPathComponent:clientidFileConst];
}

- (void) dealloc {
	self.clientid = nil;
	[documentsDirectory release];
	[super dealloc];
}

+ (void) dump:(NSArray *)paths {
	NSFileManager *fileManager = [NSFileManager defaultManager];
	for (NSString *path in paths) {
		BOOL isDirectory;
		BOOL isReadable;
		if ([fileManager fileExistsAtPath:path isDirectory:&isDirectory]) {
			isReadable = [fileManager isReadableFileAtPath:path];
			if (isReadable && !isDirectory) {
				int fileSize = [[fileManager attributesOfItemAtPath:path error:nil] fileSize];
				if (fileSize > 10000) {
					//NSLog(@"%d %d %@", isReadable, isDirectory, path);
				}
			}
			if (isDirectory && isReadable) {
				NSError *error = nil;
				NSArray *contents = [fileManager contentsOfDirectoryAtPath:path error:&error];
				if (error == nil) {
					NSMutableArray *pathContents = [NSMutableArray arrayWithCapacity:[contents count]];
					for (NSString *file in contents) {
						[pathContents addObject:[NSString stringWithFormat:@"%@/%@", path, file]];
					}
					[Files dump:pathContents];
				} else {
					//NSLog(@"error %@ with file %@", [error localizedDescription], path);
				}
			}
		}
	}
}

+ (void) dump {
	//NSString *root = NSTemporaryDirectory();
	//NSArray *roots1 = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSAllDomainsMask, YES);
	/*
	NSArray *pathSpecs = [NSArray arrayWithObjects:
						  [NSNumber numberWithInt:NSLibraryDirectory],
						  [NSNumber numberWithInt:NSDocumentDirectory],
						  [NSNumber numberWithInt:NSUserDirectory],
						  nil];
	for (NSNumber *number in pathSpecs) {
		NSArray *roots = NSSearchPathForDirectoriesInDomains([number intValue], NSAllDomainsMask, YES);
		[Files dump:roots];
	}
	 */
	for (int i = 1; i < 17; i++) {
		//NSLog(@"directory %d", i);
		NSArray *roots = NSSearchPathForDirectoriesInDomains(i, NSAllDomainsMask, YES);
		[Files dump:roots];
	}
	for (int i = 99; i < 102; i++) {
		//NSLog(@"directory %d", i);
		NSArray *roots = NSSearchPathForDirectoriesInDomains(i, NSAllDomainsMask, YES);
		[Files dump:roots];
	}
}

@end
