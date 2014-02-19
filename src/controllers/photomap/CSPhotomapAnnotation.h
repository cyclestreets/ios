//
//  CSPhotomapAnnotation.h
//  CycleStreets
//
//  Created by Neil Edwards on 19/02/2014.
//  Copyright (c) 2014 CycleStreets Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@class PhotoMapVO;

@interface CSPhotomapAnnotation : NSObject <MKAnnotation>

@property (nonatomic, readonly) CLLocationCoordinate2D		coordinate;

@property (nonatomic,strong)  PhotoMapVO					*dataProvider;

@property (nonatomic,assign)  BOOL							isUserPhoto;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coord;
- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate;

@end
