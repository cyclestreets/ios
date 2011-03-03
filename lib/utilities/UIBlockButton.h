//
//  UIBlockButton.h
//  NagMe
//
//  Created by Neil Edwards on 25/11/2010.
//  Copyright 2010 buffer. All rights reserved.
//
// Adds ^block  support for UIbutton events
// Note: will only work currently for IB instantiated buttons

#import <Foundation/Foundation.h>


typedef void (^ActionBlock)();

@interface UIBlockButton : UIButton {
	ActionBlock _actionBlock;
}
-(void) handleControlEvent:(UIControlEvents)event withBlock:(ActionBlock) action;
@end
