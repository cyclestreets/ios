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

//  AddPhoto.h
//  CycleStreets
//
//  Created by Alan Paxton on 26/05/2010.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
@class XMLRequest;

@interface AddPhoto : NSObject {
	NSString *url;
	NSMutableData *body;
	XMLRequest *request;
	
	NSString *username;
	NSString *password;
	
	NSString *caption;
	NSString *longitude;
	NSString *latitude;
	NSString *privacy;
	NSString *time;
	NSString *category;
	NSString *metaCategory;
	
	NSData *imageData;
}

@property (nonatomic, copy) NSString *longitude;
@property (nonatomic, copy) NSString *latitude;
@property (nonatomic, copy) NSString *privacy;
@property (nonatomic, copy) NSString *time;
@property (nonatomic, copy) NSString *caption;
@property (nonatomic, copy) NSString *category;
@property (nonatomic, copy) NSString *metaCategory;

@property (nonatomic, strong) NSData *imageData;

- (id) initWithUsername:(NSString *)username withPassword:(NSString *)password;

- (void) runWithTarget:(NSObject *)resultTarget onSuccess:(SEL)successMethod onFailure:(SEL)failureMethod;

@end
