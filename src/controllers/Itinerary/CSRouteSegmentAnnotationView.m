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
			self.image=[UIImage imageNamed:@"CSIcon_start_wisp.png"];
			break;
		case WayPointTypeFinish:
			self.image=[UIImage imageNamed:@"CSIcon_finish_wisp.png"];
			break;
		
	}
	
	
}

@end
