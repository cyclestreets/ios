//
//  GradiantRectView.h
//  RacingUK
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
@property(nonatomic,retain)UIColor *strokeColor;
@property(nonatomic,retain)UIColor *rectColor;
@property(nonatomic,retain)UIColor *startColor;
@property(nonatomic,retain)UIColor *endColor;
@property(nonatomic,assign)CGFloat strokeWidth;
@property(nonatomic,assign)CGFloat cornerRadius;

@end
