//
//  BUInlineErrorView
//  Buffer
//
//  Created by Neil Edwards on 20/08/2013.
//  Copyright (c) 2013 buffer. All rights reserved.
//

#import "LayoutBox.h"

@interface BUInlineErrorView : LayoutBox

-(void)showInlineErrorForType:(NSString*)type  show:(BOOL)show addtionalMessage:(NSString*)message
                   targetView:(UIView*)targetView offset:(CGPoint)offset;

-(void)hideError:(BOOL)animated;

@end
