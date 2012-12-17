//
//  CSGraphView.m
//  CycleStreets
//
//  Created by Neil Edwards on 17/12/2012.
//  Copyright (c) 2012 CycleStreets Ltd. All rights reserved.
//

#import "CSGraphView.h"

@interface CSGraphView()

-(void)sendDelegateMessageWithPoint:(CGPoint)point;

@end

@implementation CSGraphView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}





-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
	
	UITouch *touch1 = [touches anyObject];
	CGPoint touchLocation = [touch1 locationInView:self];
	
	[self sendDelegateMessageWithPoint:touchLocation];
	
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
	
	UITouch *touch1 = [touches anyObject];
	CGPoint touchLocation = [touch1 locationInView:self];
	
	[self sendDelegateMessageWithPoint:touchLocation];
	
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
	
	if([_delegate respondsToSelector:@selector(cancelTouchInGraph)]){
		[_delegate cancelTouchInGraph];
	}
	
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
	
	if([_delegate respondsToSelector:@selector(cancelTouchInGraph)]){
		[_delegate cancelTouchInGraph];
	}
	
}

-(void)sendDelegateMessageWithPoint:(CGPoint)point{
	
	if([_delegate respondsToSelector:@selector(handleTouchInGraph:)]){
		[_delegate handleTouchInGraph:point];
	}
	
}

@end
