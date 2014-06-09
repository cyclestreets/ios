UITintedButton
==============

Ever wanted to tint a UIButton like you do with a UIBarButtonItem or a UINavigationItem? Here you go!

![Screenshot](https://raw.githubusercontent.com/filipstefansson/UITintedButton/master/screenshot.png)

This category adds two instance methods and two class methods to UIButton:

	-(void)setImageTintColor:(UIColor *)color forState:(UIControlState)state;
	-(void)setBackgroundTintColor:(UIColor *)color forState:(UIControlState)state;
	
	+(void)tintButtonImages:(NSArray *)buttons withColor:(UIColor *)color forState:(UIControlState)state;
	+(void)tintButtonBackgrounds:(NSArray *)buttons withColor:(UIColor *)color forState:(UIControlState)state;

## Installation

### CocoaPods

``` pod 'UITintedButton' ```

### Manual

Drag ```UIButton+tintImage.h``` and ```UIButton+tintImage.m```.

## Usage

	#import UIButton+tintImage.h
	
	// Tint single buttons
	[button setImageTintColor:[UIColor redColor] forState:UIControlStateNormal];
    [button setBackgroundTintColor:[UIColor redColor] forState:UIControlStateNormal];
    
    // Tint multiple buttons
    [UIButton tintButtonImages:@[button1, button2, button3] withColor:[UIColor redColor] forState:UIControlStateNormal];
    [UIButton tintButtonBackgrounds:@[button1, button2, button3] withColor:[UIColor redColor] forState:UIControlStateNormal];
