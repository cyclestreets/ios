//
//  BUCalloutView.h
//  CycleStreets
//
//  Created by Neil Edwards on 13/12/2012.
//  Copyright (c) 2012 CycleStreets Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BUCalloutView : UIView


@property (nonatomic, strong) UIColor *strokeColor;
@property (nonatomic, strong) UIColor *fillColor;
@property CGFloat strokeWidth;
@property CGFloat cornerRadius;

-(void)updateTitleLabel:(NSString*)str;

@end
