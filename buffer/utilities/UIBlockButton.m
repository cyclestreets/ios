//
//  UIBlockButton.m
//  NagMe
//
//  Created by Neil Edwards on 25/11/2010.
//  Copyright 2010 buffer. All rights reserved.
//

#import "UIBlockButton.h"


@implementation UIBlockButton

-(void) handleControlEvent:(UIControlEvents)event withBlock:(ActionBlock) action{
	_actionBlock = Block_copy(action);
	[self addTarget:self action:@selector(callActionBlock:) forControlEvents:event];
}

-(void) callActionBlock:(id)sender{
	_actionBlock();
}

-(void) dealloc{
	Block_release(_actionBlock);
	[super dealloc];
}
@end
