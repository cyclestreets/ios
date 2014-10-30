//
//  POIAnnotationView.m
//  CycleStreets
//
//  Created by Neil Edwards on 15/10/2014.
//  Copyright (c) 2014 CycleStreets Ltd. All rights reserved.
//

#import "POIAnnotationView.h"
#import "UIView+Additions.h"
#import "POIAnnotation.h"
#import "ImageCache.h"
#import "GlobalUtilities.h"

@interface POIAnnotationView()

@property (nonatomic,strong)  UILabel							*indexLabel;

@property (nonatomic,strong)  UIImageView						*imageView;

@end

@implementation POIAnnotationView


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self.superview bringSubviewToFront:self];
	[super touchesBegan:touches withEvent:event];
}


- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
	
	if (self) {
		
		
		self.imageView=[[UIImageView alloc]initWithFrame:CGRectMake(2, 2, 24,24)];
		_imageView.contentMode=UIViewContentModeScaleAspectFit;
		[self addSubview:_imageView];
		
		[self updateAnnotation];
		
		
	}
	
	return self;
}


-(void)setAnnotation:(id<MKAnnotation>)_annotation{
	
	[super setAnnotation:_annotation];
	
	[self updateAnnotation];
}


-(void)updateAnnotation{
	
	
	POIAnnotation* annotation=self.annotation;
	UIImage *image=[[ImageCache sharedInstance] imageExists:[NSString stringWithFormat:@"Icon_POI_%@",annotation.dataProvider.poiType] ofType:nil];
	
	_imageView.image=image;
	
}

@end
