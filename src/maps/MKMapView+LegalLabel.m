//
//  MKMapView+LegalLabel.m
//  CycleStreets
//
//  Created by Neil Edwards on 25/09/2014.
//  Copyright (c) 2014 CycleStreets Ltd. All rights reserved.
//

#import "MKMapView+LegalLabel.h"

@implementation MKMapView (LegalLabel)

#pragma mark - Properties

- (UILabel *)legalLabel
{
	if(self.subviews.count>1){
		if([[self.subviews objectAtIndex:1] isKindOfClass:[UILabel class]]){
			return [self.subviews objectAtIndex:1];
		}
	}
	
	return nil;
}


#pragma mark - Public methods

- (void)moveLegalLabelToPosition:(MKMapViewLegalLabelPosition)position
{
	UILabel *label = self.legalLabel;
	CGPoint point = [self getPointForLabel:label atPosition:position];
	label.center = point;
}


#pragma mark - Private methods

- (CGPoint)getPointForLabel:(UILabel *)label atPosition:(MKMapViewLegalLabelPosition)position
{
	int x = 0;
 
	switch (position) {
		case MKMapViewLegalLabelPositionBottomLeft:
			x = label.center.x;
			break;
		case MKMapViewLegalLabelPositionBottomCenter:
			x = self.center.x;
			break;
		case MKMapViewLegalLabelPositionBottomRight:
			x = self.frame.size.width - label.center.x;
			break;
	}
 
	CGPoint result = CGPointMake(x, label.center.y);
	return result;
}

@end
