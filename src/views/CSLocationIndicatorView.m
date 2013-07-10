//
//  CSLocationIndicatorView.m
//  CycleStreets
//
//  Created by Neil Edwards on 09/07/2013.
//  Copyright (c) 2013 CycleStreets Ltd. All rights reserved.
//

#import "CSLocationIndicatorView.h"
#import "UIView+Additions.h"
#import <QuartzCore/QuartzCore.h>

@interface CSLocationIndicatorView()

@property (nonatomic, strong) CALayer *locationPointLayer;
@property (nonatomic, strong) CALayer *locationRadiusLayer;

@property (nonatomic, assign) float radius;

@end

@implementation CSLocationIndicatorView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}


-(void)updateToLocation{
	
	self.x=[_locationProvider getX]-(self.width/2);
	self.y=[_locationProvider getY]-(self.height/2);
	
	_radius = MAX(60.f,[_locationProvider getRadius]);
	[self adjustLayersForLocation];

}


-(void)adjustLayersForLocation{
	
	[_locationRadiusLayer removeFromSuperlayer];
    _locationRadiusLayer = nil;
    
    [_locationPointLayer removeFromSuperlayer];
    _locationPointLayer = nil;
    
    [self.layer addSublayer:self.locationRadiusLayer];
    [self.layer addSublayer:self.locationPointLayer];
	
}


// TODO: this should only be created once, then animated in size
-(CALayer*)locationRadiusLayer{
	
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	
	CGContextSetLineWidth( ctx, MAX(_radius, 10.0f));
	
	CGContextSetStrokeColorWithColor(ctx, [UIColor colorWithRed:0.2 green:0.2 blue:1.0 alpha:0.75].CGColor);
	CGContextAddArc( ctx,
					[_locationProvider getX],
					[_locationProvider getY],
					_radius * 1.5,
					0,
					2*3.142,
					0);
	CGContextStrokePath(ctx);
	
}


-(CALayer*)locationPointLayer{
	
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	
	double radius = [_locationProvider getRadius];
	
	CGContextSetStrokeColorWithColor(ctx, [UIColor colorWithRed:0.2 green:0.2 blue:1.0 alpha:1].CGColor);
	CGContextAddArc( ctx,
					[_locationProvider getX],
					[_locationProvider getY],
					20,
					0,
					2*3.142,
					0);
	CGContextStrokePath(ctx);
	
	
}

@end
