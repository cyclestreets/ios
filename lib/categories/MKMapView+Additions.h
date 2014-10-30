//
//  MKMapView+Additions.h
//  CycleStreets
//
//  Created by Neil Edwards on 17/02/2014.
//  Copyright (c) 2014 CycleStreets Ltd. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface MKMapView (Additions)

- (void)setCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate
				  zoomLevel:(NSUInteger)zoomLevel
				   animated:(BOOL)animated;

/**
 @brief Will return all annotations on the map except for the users.
 */
-(NSArray*)annotationsWithoutUserLocation;

/**
 @brief Returns YES if the specified region is "null".
 */
+ (BOOL) isMKCoordinateRegionNull: (MKCoordinateRegion) region;

/**
 @brief Returns YES if the specified region is "null" or empty.
 */
+ (BOOL) isMKCoordinateRegionEmpty: (MKCoordinateRegion) region;

/**
 @brief Returns a debug description string for the region.
 */
+ (NSString*) MKCoordinateRegionDebugDescription: (MKCoordinateRegion) region;

/**
 @brief This method will fit and zoom all the annotations onto the map
 */
-(void) zoomToFitAnnotations;

/**
 @brief This method will fit and zoom all the annotations on the map except the user one
 */
-(void) zoomToFitAnnotationsWithoutUserLocation;


-(double) getZoomLevel;


-(MKMapRect)mapRectForAnnotations;


-(CLLocationCoordinate2D)NEforMapView;
-(CLLocationCoordinate2D)SWforMapView;
-(CLLocationCoordinate2D)NWforMapView;
-(CLLocationCoordinate2D)SEforMapView;

@end
