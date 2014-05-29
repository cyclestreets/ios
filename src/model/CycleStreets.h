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

//  CycleStreets.h
//  CycleStreets
//
//

#import <Foundation/Foundation.h>
#import "SynthesizeSingleton.h"
#import "Files.h"
#import "RMTileSource.h"
#import "RMMapView.h"
#import <CoreLocation/CoreLocation.h>


extern const NSInteger MAX_ZOOM_LOCATION;
extern const NSInteger MAX_ZOOM_LOCATION_ACCURACY;
extern const NSInteger MAX_ZOOM_SEGMENT;


@interface CycleStreets : NSObject {
}

@property (nonatomic, strong)		Files								* files;
@property (nonatomic, strong)		NSString							* APIKey;
@property (nonatomic, strong)		NSString							* userAgent;

SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(CycleStreets);


//+ ( NSObject <RMTileSource> *)tileSource;
+ (NSArray *)mapStyles;
+ (NSString *)currentMapStyle;
+ (NSString *)mapAttribution;
+(NSString*)tileTemplate;
+ (void)zoomMapView:(RMMapView *)mapView toLocation:(CLLocation *)newLocation;

@end
