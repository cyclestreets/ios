//
//  TextViewAlert.h
//
//
//  Created by Neil Edwards on 31/01/2011.
//  Copyright 2011 buffer. All rights reserved.
//

/*
 *	Text Alert View
 *
 *  File: TextAlertView.h
 *	Abstract: UIAlertView extension with UITextField (Interface Declaration).
 *
 */

#import <UIKit/UIKit.h>

#define kUITextFieldHeight 30.0
#define kUITextFieldXPadding 12.0
#define kUITextFieldYPadding 10.0
#define kUIAlertOffset 100.0

@interface TextViewAlert : UIAlertView {
	UITextField *textField;
	BOOL layoutDone;
}

@property (nonatomic, strong) UITextField *textField;

- (id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate 
  cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...;

@end

