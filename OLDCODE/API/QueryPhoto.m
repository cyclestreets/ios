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

//  QueryPhoto.m
//  CycleStreets
//
//  Created by Alan Paxton on 03/05/2010.
//

#import "QueryPhoto.h"
#import "XMLRequest.h"
#import "PhotoMapListVO.h"
#import "CycleStreets.h"

static NSString *format = @"%@?key=%@&longitude=%f&latitude=%f&n=%f&e=%f&w=%f&s=%f&zoom=%@&useDom=%@&thumbnailsize=%@&limit=%d&suppressplaceholders=1&minimaldata=1";

static NSString *urlPrefix = @"http://www.cyclestreets.net/api/photos.xml";
static NSString *useDom = @"1";
static NSString *zoom = @"13"; //what is zoom in this context ?
static NSString *thumbnailSize = @"300";

@implementation QueryPhoto

- (id) initNorthEast:(CLLocationCoordinate2D)ne SouthWest:(CLLocationCoordinate2D)sw limit:(NSInteger)limit {
	if (self = [super init]) {
		CycleStreets *cycleStreets = [CycleStreets sharedInstance];
		
		//Fake up a centre point
		CLLocationCoordinate2D centre;
		centre.latitude = (ne.latitude + sw.latitude)/2;
		centre.longitude = (ne.longitude + sw.longitude)/2;
		
		NSString *newURL = [NSString
							stringWithFormat:format,
							urlPrefix,
							[cycleStreets APIKey],
							centre.longitude,
							centre.latitude,
							ne.latitude,
							ne.longitude,
							sw.longitude,
							sw.latitude,
							zoom,
							useDom,
							thumbnailSize,
							limit];
		url = newURL;
	}
	return self;
}

- (id) initNorthEast:(CLLocationCoordinate2D)ne SouthWest:(CLLocationCoordinate2D)sw {
	return [self initNorthEast:ne SouthWest:sw limit:25];
}

+ (NSString *) example {
	return @"http://www.cyclestreets.net/api/photos.xml?useDom=1&latitude=52.209124&longitude=0.1272992&zoom=13&w=0.0854996&s=52.1821951&e=0.1690987&n=52.2360528&feature=cycleparking&meta=good&thumbnailsize=300";
}

- (void) runWithTarget:(NSObject *)resultTarget onSuccess:(SEL)successMethod onFailure:(SEL)failureMethod {
	request = [[XMLRequest alloc] initWithURL:url
									 delegate:(NSObject *)resultTarget
										  tag:nil
									onSuccess:(SEL)successMethod
									onFailure:(SEL)failureMethod];
	request.elementsToParse = [PhotoMapListVO photoListXMLElementNames];
	[request.request addValue:@"gzip" forHTTPHeaderField:@"Accepts-Encoding"];
	[request start];
}

- (NSString *)description {
	NSString *copy = [url copy];
	return copy;
}

- (void) dealloc {
	url = nil;
	request = nil;
}

@end
