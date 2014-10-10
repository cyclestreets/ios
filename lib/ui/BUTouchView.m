//
//  BUTouchView.m
//
//  Created by Neil Edwards on 19/02/2013.
//
//

#import "BUTouchView.h"
#import "GlobalUtilities.h"

//
@implementation BUTouchView
@synthesize outSideBlock;
@synthesize inSideBlock;




- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
	[super touchesBegan:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesCancelled:touches withEvent:event];
}


-(void)setTouchedOutsideBlock:(BUTouchedOutsideBlock)_outsideBlock
{
    self.outSideBlock = [_outsideBlock copy];

}

-(void)setTouchedInsideBlock:(BUTouchedInsideBlock)_insideBlock
{
    self.inSideBlock = [_insideBlock copy];

    
}

-(UIView*)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *subview = [super hitTest:point withEvent:event];
    
    if(UIEventTypeTouches == event.type)
    {
        BOOL touchedInside = subview == self;
        
        if(_exclusiveTouch==NO){
            
                if(!touchedInside){
                    
                for(UIView *s in self.subviews){
                    if(s == subview) {
                        touchedInside = YES;
                        break;
                    }
                }
            }
            
        }
        
        
        
        if(touchedInside && inSideBlock)
        {
            inSideBlock();
        }
        else if(!touchedInside && outSideBlock)
        {
            outSideBlock();
        }
    }
    
    return subview;
}


-(void)executeOutsideBlock{
    outSideBlock();
}
-(void)executeInsideBlock{
    inSideBlock();
}

@end
