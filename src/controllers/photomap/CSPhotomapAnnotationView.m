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
#import "PhotoMapVO.h"
#import "UIImage+PDF.h"
#import "GlobalUtilities.h"

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
	
	if(annotation.isUserPhoto){
		self.image=[UIImage imageNamed:@"UIIcon_userphotomap.png"];
	}else{
		
		switch (annotation.dataProvider.mediaType) {
			case PhotoMapMediaType_Image:
			{
				UIImage *image=[UIImage imageWithPDFNamed:annotation.dataProvider.categoryIconString fitSize:CGSizeMake(40,40)];
				if(image==nil){
					image=[UIImage imageWithPDFNamed:@"bicycles_other.pdf" fitSize:CGSizeMake(40,40)];
				}
				
				self.image=image;
			}
				
			break;
			case PhotoMapMediaType_Video:
				self.image=[UIImage imageNamed:@"UIIcon_videomap.png"];
			break;
		
		}
	}
	
	
}


@end
