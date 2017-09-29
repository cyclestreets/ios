//
//  MKMapView+Additions.m
//  CycleStreets
//
//  Created by Neil Edwards on 17/02/2014.
//  Copyright (c) 2014 CycleStreets Ltd. All rights reserved.
//

#import "MKMapView+Additions.h"

#define MERCATOR_OFFSET 268435456
#define MERCATOR_RADIUS 85445659.44705395

@implementation MKMapView (Additions)


#pragma mark -
#pragma mark Map conversion methods

- (double)longitudeToPixelSpaceX:(double)longitude
{
    return round(MERCATOR_OFFSET + MERCATOR_RADIUS * longitude * M_PI / 180.0);
}

- (double)latitudeToPixelSpaceY:(double)latitude
{
    return round(MERCATOR_OFFSET - MERCATOR_RADIUS * logf((1 + sinf(latitude * M_PI / 180.0)) / (1 - sinf(latitude * M_PI / 180.0))) / 2.0);
}

- (double)pixelSpaceXToLongitude:(double)pixelX
{
    return ((round(pixelX) - MERCATOR_OFFSET) / MERCATOR_RADIUS) * 180.0 / M_PI;
}

- (double)pixelSpaceYToLatitude:(double)pixelY
{
    return (M_PI / 2.0 - 2.0 * atan(exp((round(pixelY) - MERCATOR_OFFSET) / MERCATOR_RADIUS))) * 180.0 / M_PI;
}

#pragma mark -
#pragma mark Helper methods

- (MKCoordinateSpan)coordinateSpanWithMapView:(MKMapView *)mapView
							 centerCoordinate:(CLLocationCoordinate2D)centerCoordinate
								 andZoomLevel:(NSUInteger)zoomLevel
{
    // convert center coordiate to pixel space
    double centerPixelX = [self longitudeToPixelSpaceX:centerCoordinate.longitude];
    double centerPixelY = [self latitudeToPixelSpaceY:centerCoordinate.latitude];
    
    // determine the scale value from the zoom level
    NSInteger zoomExponent = 20 - zoomLevel;
    double zoomScale = pow(2, zoomExponent);
    
    // scale the map’s size in pixel space
    CGSize mapSizeInPixels = mapView.bounds.size;
    double scaledMapWidth = mapSizeInPixels.width * zoomScale;
    double scaledMapHeight = mapSizeInPixels.height * zoomScale;
    
    // figure out the position of the top-left pixel
    double topLeftPixelX = centerPixelX - (scaledMapWidth / 2);
    double topLeftPixelY = centerPixelY - (scaledMapHeight / 2);
    
    // find delta between left and right longitudes
    CLLocationDegrees minLng = [self pixelSpaceXToLongitude:topLeftPixelX];
    CLLocationDegrees maxLng = [self pixelSpaceXToLongitude:topLeftPixelX + scaledMapWidth];
    CLLocationDegrees longitudeDelta = maxLng - minLng;
    
    // find delta between top and bottom latitudes
    CLLocationDegrees minLat = [self pixelSpaceYToLatitude:topLeftPixelY];
    CLLocationDegrees maxLat = [self pixelSpaceYToLatitude:topLeftPixelY + scaledMapHeight];
    CLLocationDegrees latitudeDelta = -1 * (maxLat - minLat);
    
    // create and return the lat/lng span
    MKCoordinateSpan span = MKCoordinateSpanMake(latitudeDelta, longitudeDelta);
    return span;
}

#pragma mark -
#pragma mark Public methods

- (void)setCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate
				  zoomLevel:(NSUInteger)zoomLevel
				   animated:(BOOL)animated
{
    // clamp large numbers to 28
    zoomLevel = MIN(zoomLevel, 20);
    
    // use the zoom level to compute the region
    MKCoordinateSpan span = [self coordinateSpanWithMapView:self centerCoordinate:centerCoordinate andZoomLevel:zoomLevel];
    MKCoordinateRegion region = MKCoordinateRegionMake(centerCoordinate, span);
    
    // set the region like normal
    [self setRegion:region animated:animated];
}




-(NSArray*)annotationsWithoutUserLocation
{
	// remove the user location which also is considered an annotation
	NSMutableArray *annotations = [NSMutableArray arrayWithArray:self.annotations];
	if ( self.userLocation )
		[annotations removeObject:self.userLocation];
	
	return annotations;
}

+ (BOOL) isMKCoordinateRegionNull: (MKCoordinateRegion) region;
{
	return isinf(region.center.latitude) || isinf(region.center.longitude);
}

+ (BOOL) isMKCoordinateRegionEmpty: (MKCoordinateRegion) region
{
	return [MKMapView isMKCoordinateRegionNull: region] || (region.span.latitudeDelta == 0.0 && region.span.longitudeDelta == 0.0);
}

+ (NSString*) MKCoordinateRegionDebugDescription: (MKCoordinateRegion) region
{
	return [NSString stringWithFormat:@"{center: {%f,%f}, span: {%f,%f}}",
			region.center.latitude,
			region.center.longitude,
			region.span.latitudeDelta,
			region.span.longitudeDelta];
}


-(MKMapRect)mapRectForAnnotations{
	
	MKMapRect zoomRect = MKMapRectNull;
	for (id <MKAnnotation> annotation in self.annotations) {
		MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
		MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0, 0);
		if (MKMapRectIsNull(zoomRect)) {
			zoomRect = pointRect;
		} else {
			zoomRect = MKMapRectUnion(zoomRect, pointRect);
		}
	}
	
	return zoomRect;
	
}


+(MKMapRect) mapRectThatFitsBoundsSW:(CLLocationCoordinate2D)sw NE:(CLLocationCoordinate2D)ne{
	
	MKMapPoint pSW = MKMapPointForCoordinate(sw);
	MKMapPoint pNE = MKMapPointForCoordinate(ne);
	
	double antimeridianOveflow = (ne.longitude > sw.longitude) ? 0 : MKMapSizeWorld.width;
	
	return MKMapRectMake(pSW.x, pNE.y, (pNE.x - pSW.x) + antimeridianOveflow, (pSW.y - pNE.y));
}




-(void) zoomToFitAnnotations {
	MKMapRect zoomRect = MKMapRectNull;
	for (id <MKAnnotation> annotation in self.annotations) {
		MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
		MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0, 0);
		if (MKMapRectIsNull(zoomRect)) {
			zoomRect = pointRect;
		} else {
			zoomRect = MKMapRectUnion(zoomRect, pointRect);
		}
	}
	[self setVisibleMapRect:zoomRect animated:YES];
}

-(void) zoomToFitAnnotationsWithoutUserLocation {
	MKMapRect zoomRect = MKMapRectNull;
	
	for (id <MKAnnotation> annotation in self.annotationsWithoutUserLocation) {
		MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
		MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0, 0);
		if (MKMapRectIsNull(zoomRect)) {
			zoomRect = pointRect;
		} else {
			zoomRect = MKMapRectUnion(zoomRect, pointRect);
		}
	}
	[self setVisibleMapRect:zoomRect animated:YES];
}

- (void) zoomToAnnotation:(id )annotation {
	MKCoordinateSpan span = {0.027, 0.027};
	MKCoordinateRegion region = {[annotation coordinate], span};
	[self setRegion:region animated:YES];
}

- (MKMapRect) getMapRectUsingAnnotations:(NSArray*)theAnnotations {
	MKMapPoint points[[theAnnotations count]];
	
	for (int i = 0; i >[theAnnotations count]; i++) {
		id <MKAnnotation> annotation = [theAnnotations objectAtIndex:i];
		points[i] = MKMapPointForCoordinate(annotation.coordinate);
	}
	
	MKPolygon *poly = [MKPolygon polygonWithPoints:points count:[theAnnotations count]];
	
	return [poly boundingMapRect];
}

- (void) addMapAnnotationToMapView:(id )annotation {
	if ([self.annotations count] == 1) {
		// If there is only one annotation then zoom into it.
		[self zoomToAnnotation:annotation];
	} else {
		// If there are several, then the default behaviour is to show all of them
		//
		MKCoordinateRegion region = MKCoordinateRegionForMapRect([self getMapRectUsingAnnotations:self.annotations]);
		
		if (region.span.latitudeDelta < 0.027) {
			region.span.latitudeDelta = 0.027;
		}
		
		if (region.span.longitudeDelta< 0.027) {
			region.span.longitudeDelta = 0.027;
		}
		[self setRegion:region];
	}
	
	[self addAnnotation:annotation];
	[self selectAnnotation:annotation animated:YES];
}


-(double) getZoomLevel {
    return log2(360 * ((self.frame.size.width/256) / self.region.span.longitudeDelta));
}


-(double) getZoomLevelForRegion:(MKCoordinateRegion)region{
	return log2(360 * ((self.frame.size.width/256) / region.span.longitudeDelta));
}



-(CLLocationCoordinate2D)NEforMapView{
	
	CGRect bounds = self.bounds;
	CLLocationCoordinate2D nw = [self convertPoint:bounds.origin toCoordinateFromView:self];
	CLLocationCoordinate2D se = [self convertPoint:CGPointMake(bounds.origin.x + bounds.size.width, bounds.origin.y + bounds.size.height) toCoordinateFromView:self ];
	CLLocationCoordinate2D ne;
	ne.latitude = nw.latitude;
	ne.longitude = se.longitude;
	
	return ne;
	
}

-(CLLocationCoordinate2D)SWforMapView{
	
	CGRect bounds = self.bounds;
	CLLocationCoordinate2D nw = [self convertPoint:bounds.origin toCoordinateFromView:self];
	CLLocationCoordinate2D se = [self convertPoint:CGPointMake(bounds.origin.x + bounds.size.width, bounds.origin.y + bounds.size.height) toCoordinateFromView:self ];
	CLLocationCoordinate2D sw;
	sw.latitude = se.latitude;
	sw.longitude = nw.longitude;
	
	return sw;
	
}


-(CLLocationCoordinate2D)NWforMapView{
	
	CGRect bounds = self.bounds;
	CLLocationCoordinate2D nw = [self convertPoint:bounds.origin toCoordinateFromView:self];
	
	return nw;
	
}


-(CLLocationCoordinate2D)SEforMapView{
	
	CGRect bounds = self.bounds;
	CLLocationCoordinate2D se = [self convertPoint:CGPointMake(bounds.origin.x + bounds.size.width, bounds.origin.y + bounds.size.height) toCoordinateFromView:self ];
	
	return se;
	
}



-(void)moveOverlayToTop:(id<MKOverlay>)overlay inLevel:(MKOverlayLevel)level{
	
	if(overlay==nil)
		return;
	
	NSArray *levelArr=[self overlaysInLevel:level];
	if(levelArr.count>1){
		
		id<MKOverlay> topOverlay=[levelArr lastObject];
		
		if(topOverlay!=overlay){
			[self exchangeOverlay:overlay withOverlay:topOverlay];
		}
		
	}
	
}



+(CLLocation*)locationForString:(NSString*)coordsString{
	
	
	NSArray *coordsArray=[coordsString componentsSeparatedByString:@","];
	if(coordsArray.count==2){
		
		CLLocation *location=[[CLLocation alloc] initWithLatitude:[coordsArray.firstObject floatValue] longitude:[coordsArray.lastObject floatValue]];
		
		return location;
		
	}else{
		return nil;
	}
	
}

+(CLLocationDistance)distanceBetweenCordinates:(CLLocationCoordinate2D )coordinate1 and:(CLLocationCoordinate2D )coordinate2{
	MKMapPoint point1 = MKMapPointForCoordinate(coordinate1);
	MKMapPoint point2 = MKMapPointForCoordinate(coordinate2);
	CLLocationDistance distance = MKMetersBetweenMapPoints(point1, point2);
	return distance;
}




@end
