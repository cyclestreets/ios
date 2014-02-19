//
//  CSPhotomapAnnotationView.m
//  CycleStreets
//
//  Created by Neil Edwards on 19/02/2014.
//  Copyright (c) 2014 CycleStreets Ltd. All rights reserved.
//

#import "CSPhotomapAnnotationView.h"
#import "UIView+Additions.h"
#import "CSPhotomapAnnotation.h"

@implementation CSPhotomapAnnotationView

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
	
	CSPhotomapAnnotation* annotation=self.annotation;
	
	switch (annotation.isUserPhoto) {
		case YES:
			self.image=[UIImage imageNamed:@"UIIcon_userphotomap.png"];
			break;
		case NO:
			self.image=[UIImage imageNamed:@"UIIcon_photomap.png"];
			break;

	}
	
}


@end
