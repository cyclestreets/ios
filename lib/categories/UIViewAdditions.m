//
//  UIViewAdditions.m
//

#import "UIViewAdditions.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIView (MFAdditions)

- (id)initWithParent:(UIView *)parent {
	self = [self initWithFrame:CGRectZero];
	
	if (!self)
		return nil;
	
	[parent addSubview:self];
	
	return self;
}

+ (id) viewWithParent:(UIView *)parent {
	return [[[self alloc] initWithParent:parent] autorelease];
}

- (CGPoint)position {
	return [self frame].origin;
}

- (void)setPosition:(CGPoint)position {
	CGRect rect = [self frame];
	rect.origin = position;
	[self setFrame:rect];
}

- (CGFloat)x {
	return [self frame].origin.x;
}

- (void)setX:(CGFloat)x {
	CGRect rect = [self frame];
	rect.origin.x = x;
	[self setFrame:rect];
}

- (CGFloat)y {
	return [self frame].origin.y;
}

- (void)setY:(CGFloat)y {
	CGRect rect = [self frame];
	rect.origin.y = y;
	[self setFrame:rect];
}

- (CGSize)size {
	return [self frame].size;
}

- (void)setSize:(CGSize)size {
	CGRect rect = [self frame];
	rect.size = size;
	[self setFrame:rect];
}

- (CGFloat)width {
	return [self frame].size.width;
}

- (void)setWidth:(CGFloat)width {
	CGRect rect = [self frame];
	rect.size.width = width;
	[self setFrame:rect];
}

- (CGFloat)height {
	return [self frame].size.height;
}

- (void)setHeight:(CGFloat)height {
	CGRect rect = [self frame];
	rect.size.height = height;
	[self setFrame:rect];
}

@end

@implementation UIImageView (MFAdditions)

- (void) setImageWithName:(NSString *)name {
	
	[self setImage:[UIImage imageNamed:name]];
	[self sizeToFit];
}

@end
