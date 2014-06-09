//
//  UIButton+tintImage.h
//  Jumbler
//
//  Created by Filip Stefansson on 13-10-20.
//  Copyright (c) 2013 Pixby Media AB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (tintImage)
-(void)setImageTintColor:(UIColor *)color forState:(UIControlState)state;
-(void)setBackgroundTintColor:(UIColor *)color forState:(UIControlState)state;

+(void)tintButtonImages:(NSArray *)buttons withColor:(UIColor *)color forState:(UIControlState)state;
+(void)tintButtonBackgrounds:(NSArray *)buttons withColor:(UIColor *)color forState:(UIControlState)state;
@end
