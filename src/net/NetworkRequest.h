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

//  NetworkRequest.h
//  Properties
//
//  Created by Alan Paxton on 10/02/2010.
//

#import <Foundation/Foundation.h>

@interface NetworkRequest : NSObject {
	NSMutableURLRequest *request;
	NSURLConnection *connection;
	NSMutableData *data;
	NSURLResponse *response;
	
	NSObject *target;
	NSObject *tag;
	
	SEL success;
	SEL failure;
}

@property (nonatomic, strong) NSMutableURLRequest *request;
@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSMutableData *data;
@property (nonatomic, strong) NSURLResponse *response;
@property (nonatomic, strong) NSObject *target;
@property (nonatomic, strong) NSObject *tag;
@property SEL success;
@property SEL failure;

- (id)initWithURL:(NSString *)urlString delegate:(NSObject *)resultTarget tag:(NSObject *)instanceTag onSuccess:(SEL)successMethod onFailure:(SEL)failureMethod;

- (void)start;

- (void) cancel;

@end
