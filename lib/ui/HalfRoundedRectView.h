//
//  HalfRoundedRectView.h
//
//  Created by Neil Edwards on 6/5/09

#import <UIKit/UIKit.h>

#define kDefaultStrokeColor         [UIColor whiteColor]
#define kDefaultRectColor           [UIColor whiteColor]
#define kDefaultStrokeWidth         1.0
#define kDefaultCornerRadius        10.0

@interface HalfRoundedRectView : UIView {
    UIColor     *strokeColor;
    UIColor     *rectColor;
    CGFloat     strokeWidth;
    CGFloat     cornerRadius;
}
@property (nonatomic, strong) UIColor *strokeColor;
@property (nonatomic, strong) UIColor *rectColor;
@property CGFloat strokeWidth;
@property CGFloat cornerRadius;
@end