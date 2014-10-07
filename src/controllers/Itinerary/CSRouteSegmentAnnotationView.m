//
//  CSRouteSegmentAnnotationView.m
//  CycleStreets
//
//  Created by Neil Edwards on 24/02/2014.
//  Copyright (c) 2014 CycleStreets Ltd. All rights reserved.
//

#import "CSRouteSegmentAnnotationView.h"
#import "UIView+Additions.h"
#import "CSRouteSegmentAnnotation.h"
#import "UIImage+Operations.h"

@implementation CSRouteSegmentAnnotationView


- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
	
	if (self) {
		
		[self updateAnnotation];
		
		self.centerOffset=CGPointMake(12, 0-self.height/2);
		
	}
	
	return self;
}


-(void)setAnnotation:(id<MKAnnotation>)_annotation{
	
	[super setAnnotation:_annotation];
	
	[self updateAnnotation];
	
}



-(void)updateAnnotation{
	
	
	CSRouteSegmentAnnotation* annotation=self.annotation;
	
	switch (annotation.wayPointType) {
		case WayPointTypeStart:
		{
			UIImage *i=[UIImage imageNamed:@"CSIcon_MapArrow_start.png"];
			self.image=[UIImage rotateImage:i byDegrees:annotation.annotationAngle];
			
		}
			
			break;
		case WayPointTypeFinish:
		{
			UIImage *i=[UIImage imageNamed:@"CSIcon_MapArrow_end.png"];
			self.image=[UIImage rotateImage:i byDegrees:annotation.annotationAngle];
		}
			
			break;
		
	}
	
	
}


-(void)updateAnnotationAngle{
	
	CSRouteSegmentAnnotation* annotation=self.annotation;
	
	switch (annotation.wayPointType) {
		case WayPointTypeStart:
		{
			UIImage *i=[UIImage imageNamed:@"CSIcon_MapArrow_start.png"];
			self.image=[UIImage rotateImage:i byDegrees:annotation.annotationAngle];
			
		}
			
			break;
		case WayPointTypeFinish:
		{
			UIImage *i=[UIImage imageNamed:@"CSIcon_MapArrow_end.png"];
			self.image=[UIImage rotateImage:i byDegrees:annotation.annotationAngle];
		}
			
			break;
			
	}
	
}

@end
