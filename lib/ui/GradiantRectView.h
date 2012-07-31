//
//  GradiantRectView.h
//
//
//  Created by Neil Edwards on 30/04/2009.
//  Copyright 2009 buffer. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kDefaultStrokeColor         [UIColor whiteColor]
#define kDefaultRectColor           [UIColor blueColor]
#define kDefaultStrokeWidth         0.0
#define kDefaultCornerRadius        0.0

@interface GradiantRectView : UIView {
	UIColor     *strokeColor;
    UIColor     *rectColor;
	UIColor     *startColor;
	UIColor     *endColor;
    CGFloat     strokeWidth;
    CGFloat     cornerRadius;
}
@property(nonatomic,strong)UIColor *strokeColor;
@property(nonatomic,strong)UIColor *rectColor;
@property(nonatomic,strong)UIColor *startColor;
@property(nonatomic,strong)UIColor *endColor;
@property(nonatomic,assign)CGFloat strokeWidth;
@property(nonatomic,assign)CGFloat cornerRadius;

@end
