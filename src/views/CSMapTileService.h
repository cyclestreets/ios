//
//  CSMapTileService.h
//  CycleStreets
//
//  Created by Neil Edwards on 10/10/2014.
//  Copyright (c) 2014 CycleStreets Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CycleStreets.h"


@class MKMapView,CSMapSource,ExpandedUILabel;

@interface CSMapTileService : NSObject

+(void)updateMapStyleForMap:(MKMapView*)mapView toMapStyle:(CSMapSource*)mapSource withOverlays:(NSArray*)overlays;

+(void)updateMapAttributonLabel:(ExpandedUILabel*)label forMap:(MKMapView*)mapView forMapStyle:(CSMapSource*)mapSource inView:(UIView *)view;


@end
