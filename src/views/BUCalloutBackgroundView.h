//
//  BUCalloutBackgroundView.h
//  CycleStreets
//
//  Created by Neil Edwards on 13/12/2012.
//  Copyright (c) 2012 CycleStreets Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kDefaultStrokeColor         [UIColor whiteColor]
#define kDefaultRectColor           [UIColor whiteColor]
#define kDefaultStrokeWidth         1.0
#define kDefaultCornerRadius        6.0

@interface BUCalloutBackgroundView : UIView

@property (nonatomic, strong) UIColor *strokeColor;
@property (nonatomic, strong) UIColor *fillColor;
@property (nonatomic, assign) CGFloat strokeWidth;
@property (nonatomic, assign) CGFloat cornerRadius;

@end
