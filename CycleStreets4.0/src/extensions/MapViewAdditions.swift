//
//  MapViewAdditions.swift
//  FishLegal
//
//  Created by Neil Edwards on 02/11/2015.
//  Copyright © 2015 buffer. All rights reserved.
//

import Foundation
import MapKit


var MERCATOR_OFFSET: Double = 268435456
var MERCATOR_RADIUS:Double = 85445659.44705395

extension MKMapView{
    
    
    func longitudeToPixelSpaceX(_ longitude:Double)->Double
    {
    return round(MERCATOR_OFFSET + MERCATOR_RADIUS * longitude * Double.pi / 180.0);
    }
    
    func latitudeToPixelSpaceY(_ latitude:Double)->Double
    {
    return round(MERCATOR_OFFSET - MERCATOR_RADIUS * log((1 + sin(latitude * Double.pi / Double(180.0))) / (1 - sin(latitude * Double.pi / Double(180.0)))) / 2.0);
    }
    
    func pixelSpaceXToLongitude(_ pixelX:Double)->Double
    {
    return ((round(pixelX) - MERCATOR_OFFSET) / MERCATOR_RADIUS) * 180.0 / Double.pi;
    }
    
    func pixelSpaceYToLatitude(_ pixelY:Double)->Double
    {
    return (Double.pi / 2.0 - 2.0 * atan(exp((round(pixelY) - MERCATOR_OFFSET) / MERCATOR_RADIUS))) * 180.0 / Double.pi;
    }
    
    
    
    
    
    func coordinateSpanWithMapView(_ mapView:MKMapView, centerCoordinate:CLLocationCoordinate2D, zoomLevel:UInt)->MKCoordinateSpan{
    
            // convert center coordiate to pixel space
        let centerPixelX:Double = self.longitudeToPixelSpaceX(centerCoordinate.longitude)
        let centerPixelY:Double = self.latitudeToPixelSpaceY(centerCoordinate.latitude)
        
        // determine the scale value from the zoom level
        let zoomExponent:Int  = Int(20-zoomLevel);
        let zoomScale:Double  = pow(2.0, Double(zoomExponent));
        
        // scale the map’s size in pixel space
        let mapSizeInPixels:CGSize  = mapView.bounds.size;
        let scaledMapWidth:Double  = Double(mapSizeInPixels.width) * zoomScale;
        let scaledMapHeight:Double  = Double(mapSizeInPixels.height) * zoomScale;
        
        // figure out the position of the top-left pixel
        let topLeftPixelX:Double  = centerPixelX - (scaledMapWidth / 2);
        let topLeftPixelY:Double  = centerPixelY - (scaledMapHeight / 2);
        
        // find delta between left and right longitudes
        let minLng:CLLocationDegrees  = self.pixelSpaceXToLongitude(topLeftPixelX)
        let maxLng:CLLocationDegrees  = self.pixelSpaceXToLongitude(topLeftPixelX + scaledMapWidth)
        let longitudeDelta:CLLocationDegrees  = maxLng - minLng;
        
        // find delta between top and bottom latitudes
        let minLat:CLLocationDegrees  = self.pixelSpaceYToLatitude(topLeftPixelY)
        let maxLat:CLLocationDegrees  = self.pixelSpaceYToLatitude(topLeftPixelY + scaledMapHeight)
        let latitudeDelta:CLLocationDegrees  = -1 * (maxLat - minLat);
        
        // create and return the lat/lng span
        let span:MKCoordinateSpan  = MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta);
        return span;
    }
    
    
    
    
    func setCenterCoordinate(_ centerCoordinate:CLLocationCoordinate2D,zoomLevel:UInt, animated:Bool){
        
        var zoomLevel=zoomLevel;
        
        // clamp large numbers to 28
        zoomLevel = min(zoomLevel, 20);
    
        // use the zoom level to compute the region
        let span:MKCoordinateSpan  = self.coordinateSpanWithMapView(self, centerCoordinate: centerCoordinate, zoomLevel: zoomLevel)
        let region:MKCoordinateRegion  = MKCoordinateRegion(center: centerCoordinate, span: span);
        
        // set the region like normal
        self.setRegion(region, animated: animated)
    }
    
    
    var zoomLevel: Double {
        get {
            return log2(360 * (Double(self.frame.size.width/256) / self.region.span.longitudeDelta)) + 1;
        }
        
        set (newZoomLevel){
            setNewCenterCoordinate(self.centerCoordinate, zoomLevel: newZoomLevel-1, animated: false)
        }
    }
    
    private func setNewCenterCoordinate(_ coordinate: CLLocationCoordinate2D, zoomLevel: Double, animated: Bool){
        let span = MKCoordinateSpan(latitudeDelta: 0, longitudeDelta: 360 / pow(2, zoomLevel) * Double(self.frame.size.width) / 256)
        setRegion(MKCoordinateRegion(center: coordinate, span: span), animated: animated)
    }
    
//    func getZoomLevel()->Double {
//        return log2(360 * (Double(self.frame.size.width/256) / Double(self.region.span.longitudeDelta)))+1;
//    }
    
    
    
    func annotationsWithoutUserLocation()->Array<MKAnnotation>{
        
        var myAnnotations:Array=self.annotations
        
        myAnnotations = self.annotations.filter({
            !($0 as MKAnnotation).isEqual(self.userLocation)
        })
        
        return myAnnotations;
    }
    
    
    func mapRectForAnnotations()->MKMapRect{
    
        var zoomRect:MKMapRect  = MKMapRect.null;
        self.annotations.forEach({ (annotation:MKAnnotation) -> () in
            
            let annotationPoint:MKMapPoint  = MKMapPoint(annotation.coordinate);
            let pointRect:MKMapRect  = MKMapRect(x: annotationPoint.x, y: annotationPoint.y, width: 0, height: 0);
            if zoomRect.isNull {
                zoomRect = pointRect;
            } else {
                zoomRect = zoomRect.union(pointRect);
            }
        })
    
        return zoomRect;
    
    }
    
    func zoomToFitAnnotations() {
    
        var zoomRect:MKMapRect  = MKMapRect.null;
         self.annotations.forEach({ (annotation:MKAnnotation) -> () in
            let annotationPoint:MKMapPoint  = MKMapPoint(annotation.coordinate);
            let pointRect:MKMapRect  = MKMapRect(x: annotationPoint.x, y: annotationPoint.y, width: 0, height: 0);
            if zoomRect.isNull {
                zoomRect = pointRect;
            } else {
                zoomRect = zoomRect.union(pointRect);
            }
        })
        self.setVisibleMapRect(zoomRect, animated: true)
    }
    
    
    func getMapRectUsingAnnotations(_ theAnnotations:Array<MKAnnotation>)->MKMapRect {
        
        var points:[MKMapPoint]=[];
        points.reserveCapacity(theAnnotations.count)
        
        for i in 0 ..< theAnnotations.count{
            
            let annotation=theAnnotations[i]
            points.append(MKMapPoint(annotation.coordinate))
            
        }
        
        let polygon:MKPolygon=MKPolygon(points: &points , count: points.count)
        return polygon.boundingMapRect
        
    }
    
    
    
    
    
    func NWforMapView(_ coordinate:CLLocationCoordinate2D)->CLLocationCoordinate2D{
        
        let bounds:CGRect  = self.bounds;
        let nw:CLLocationCoordinate2D  = self.convert(bounds.origin, toCoordinateFrom: self)
        
        return nw;
    }
    
    
    func SEforMapView(_ coordinate:CLLocationCoordinate2D)->CLLocationCoordinate2D{
        
        let bounds:CGRect  = self.bounds;
        let se:CLLocationCoordinate2D  = self.convert(CGPoint(x: bounds.origin.x + bounds.size.width, y: bounds.origin.y + bounds.size.height), toCoordinateFrom: self)
        
        return se;
    }
    
    
    func NEforMapView(_ coordinate:CLLocationCoordinate2D)->CLLocationCoordinate2D{
        
        let nw:CLLocationCoordinate2D  = self.NWforMapView(coordinate)
        let se:CLLocationCoordinate2D = self.SEforMapView(coordinate)
        
        let ne=CLLocationCoordinate2DMake(nw.latitude, se.longitude)
        
        return ne;
    
    }
    
    func SWforMapView(_ coordinate:CLLocationCoordinate2D)->CLLocationCoordinate2D{
        
        let nw:CLLocationCoordinate2D  = self.NWforMapView(coordinate)
        let se:CLLocationCoordinate2D = self.SEforMapView(coordinate)
        
        let sw=CLLocationCoordinate2DMake(se.latitude, nw.longitude)
        
        return sw;
        
    }
    
    
    /* Standardises and angle to [-180 to 180] degrees */
    fileprivate func standardAngle( _ angle: CLLocationDegrees) -> CLLocationDegrees {
        var angle=angle
        angle=angle.truncatingRemainder(dividingBy: 360)
        return angle < -180 ? -360 - angle : angle > 180 ? 360 - 180 : angle
    }
    
    /* confirms that a region contains a location */
    func regionContains(_ region: MKCoordinateRegion, coordinate: CLLocationCoordinate2D) -> Bool {
        let deltaLat = abs(standardAngle(region.center.latitude - coordinate.latitude))
        let deltalong = abs(standardAngle(region.center.longitude - coordinate.longitude))
        return region.span.latitudeDelta >= deltaLat && region.span.longitudeDelta >= deltalong
    }
    
    
    
    func rectForCoordinates(coordinates: [CLLocationCoordinate2D])->MKMapRect{
        
        let points = coordinates.map { MKMapPoint($0) }
        let rects = points.map { MKMapRect(origin: $0, size: MKMapSize(width: 0, height: 0)) }
        let fittingRect = rects.reduce(MKMapRect.null, { x, y in
            x.union(y)
        })
        return fittingRect
    }
    
}



extension CLLocationCoordinate2D:CustomStringConvertible
{
    init(coords : String)
    {
        var fullNameArr = coords.components(separatedBy: ";")
        self.init()
        self.latitude = NumberFormatter().number(from: fullNameArr[0])!.doubleValue
        self.longitude = (fullNameArr.count > 1) ? NumberFormatter().number(from: fullNameArr[1])!.doubleValue : 0
    }
    
    public var description : String
        {
            return "\(self.latitude);\(self.longitude)"
    }
}
