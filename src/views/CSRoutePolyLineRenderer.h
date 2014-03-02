
//
//  CSRoutePolyLineRenderer.h
//  CycleStreets
//
//  Created by Neil Edwards on 25/02/2014.
//  Copyright (c) 2014 CycleStreets Ltd. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface CSRoutePolyLineRenderer : MKOverlayPathRenderer



@property (nonatomic,strong)  UIColor				*primaryColor;
@property (nonatomic,strong)  UIColor				*secondaryColor;

@property (nonatomic,assign)  float					primaryDash;
@property (nonatomic,assign)  float					secondaryDash;


@end
