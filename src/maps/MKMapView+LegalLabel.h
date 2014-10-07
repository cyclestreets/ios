//
//  MKMapView+LegalLabel.h
//  CycleStreets
//
//  Created by Neil Edwards on 25/09/2014.
//  Copyright (c) 2014 CycleStreets Ltd. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface MKMapView (LegalLabel)

typedef enum {
	MKMapViewLegalLabelPositionBottomLeft = 0,
	MKMapViewLegalLabelPositionBottomCenter = 1,
	MKMapViewLegalLabelPositionBottomRight = 2,
} MKMapViewLegalLabelPosition;

@property (nonatomic, readonly) UILabel *legalLabel;

- (void)moveLegalLabelToPosition:(MKMapViewLegalLabelPosition)position;

@end
