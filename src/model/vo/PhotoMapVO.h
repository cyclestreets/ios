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

//  PhotoEntry.h
//  CycleStreets
//
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef NS_ENUM(NSUInteger, PhotoMapMediaType) {
	PhotoMapMediaType_Image,
	PhotoMapMediaType_Video
};

@interface PhotoMapVO : NSObject


@property (nonatomic)	CLLocationCoordinate2D		locationCoords;
@property (nonatomic, strong)	NSString			*csid;
@property (nonatomic, strong)	NSString			*caption;

// image
@property (nonatomic, strong)	NSString			*bigImageURL;
@property (nonatomic, strong)	NSString			*smallImageURL;

@property (nonatomic, assign)	PhotoMapMediaType	mediaType;

@property (nonatomic, strong)	NSString			*videoURL;


@property(nonatomic,readonly)  BOOL					hasVideo;
@property(nonatomic,readonly)  BOOL					hasPhoto;


// v2
-(void)updateWithAPIDict:(NSDictionary*)dict;


// deprecate
- (id)initWithDictionary:(NSDictionary *)fields;



- (CLLocationCoordinate2D)location;

- (void) generateSmallImageURL:(NSString *)sizes;

-(NSString*)csImageUrlString;


@end
