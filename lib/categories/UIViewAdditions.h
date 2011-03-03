//
//  UIViewAdditions.h
//

#import <UIKit/UIKit.h>


@interface UIView (MFAdditions)

- (id) initWithParent:(UIView *)parent;
+ (id) viewWithParent:(UIView *)parent;

// Position of the top-left corner in superview's coordinates
@property CGPoint position;
@property CGFloat x;
@property CGFloat y;

// Setting size keeps the position (top-left corner) constant
@property CGSize size;
@property CGFloat width;
@property CGFloat height;

@end

@interface UIImageView (MFAdditions)

- (void) setImageWithName:(NSString *)name;

@end
