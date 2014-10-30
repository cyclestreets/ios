//
//  CSWaypointAnnotationView.m
//  CycleStreets
//
//  Created by Neil Edwards on 17/02/2014.
//  Copyright (c) 2014 CycleStreets Ltd. All rights reserved.
//

#import "CSWaypointAnnotationView.h"
#import "WayPointVO.h"
#import "CSWaypointAnnotation.h"
#import "UIView+Additions.h"
#import "GenericConstants.h"

@interface CSWaypointAnnotationView()

@property (nonatomic,strong)  UILabel							*indexLabel;


@end

@implementation CSWaypointAnnotationView

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self.superview bringSubviewToFront:self];
	[super touchesBegan:touches withEvent:event];
}

- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
	
	if (self) {
		
		[self updateAnnotation];
		
		self.indexLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, -10, 20, 52)];
		_indexLabel.textAlignment=NSTextAlignmentCenter;
		[_indexLabel setFont:[UIFont boldSystemFontOfSize:14]];
		_indexLabel.textColor=[UIColor whiteColor];
		_indexLabel.backgroundColor=[UIColor clearColor];
		[self addSubview:_indexLabel];
		
		self.centerOffset=CGPointMake(12, 0-self.height/2);
		
		self.calloutOffset=CGPointMake(-12, 0);
		
	}
	
	return self;
}


-(void)setAnnotation:(id<MKAnnotation>)_annotation{
	
	[super setAnnotation:_annotation];
	
	[self updateAnnotation];
	
}


-(void)updateAnnotation{
	
	
	CSWaypointAnnotation* annotation=self.annotation;
	
	_indexLabel.text=EMPTYSTRING;
	
	switch (annotation.dataProvider.waypointType) {
		case WayPointTypeStart:
			self.image=[UIImage imageNamed:@"CSIcon_start_wisp.png"];
			break;
		case WayPointTypeFinish:
			self.image=[UIImage imageNamed:@"CSIcon_finish_wisp.png"];
			break;
		case WayPointTypeIntermediate:
			self.image=[UIImage imageNamed:@"CSIcon_intermediate_wisp.png"];
			_indexLabel.text=[NSString stringWithFormat:@"%i",annotation.index];
			break;
	}
	
	
	
	
}


@end
