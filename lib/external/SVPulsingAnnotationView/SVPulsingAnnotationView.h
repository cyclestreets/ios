//
//  SPRealTimeVehicleAnnotationView.h
//  Transit
//
//  Created by Sam Vermette on 01.03.13.
//
//

#import <MapKit/MapKit.h>

@protocol GPSLocationProvider
- (float)getX;
- (float)getY;
- (float)getRadius;
@end

@interface SVPulsingAnnotationView : UIView

@property (nonatomic, strong) UIColor *annotationColor;
@property (nonatomic, readwrite) NSTimeInterval pulseAnimationDuration;
@property (nonatomic, readwrite) NSTimeInterval delayBetweenPulseCycles;

@property (nonatomic, strong) NSObject <GPSLocationProvider> *locationProvider;


-(void)updateToLocation;

@end
