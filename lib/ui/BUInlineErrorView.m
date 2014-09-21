//
//  BUInlineErrorView
//  Buffer
//
//  Created by Neil Edwards on 20/08/2013.
//  Copyright (c) 2013 buffer. All rights reserved.
//

#import "BUInlineErrorView.h"
#import "LayoutBox.h"
#import "ExpandedUILabel.h"
#import "StringManager.h"
#import "UIView+Additions.h"
#import "ViewUtilities.h"

#define ERRORSTRINGTYPE @"errorStrings"

@interface BUInlineErrorView()

@property (weak, nonatomic) IBOutlet UILabel                *titleLabel;
@property (weak, nonatomic) IBOutlet ExpandedUILabel        *contentLabel;

@property (nonatomic,assign) BOOL                           errorIsActive;

@property (nonatomic,assign) CGPoint                        offsetPoint;

@property (nonatomic,assign) float							initialHeight;


@end

@implementation BUInlineErrorView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)awakeFromNib{
    
	self.initialHeight=self.height;
    self.layoutMode=BUVerticalLayoutMode;
	self.fixedWidth=YES;
	self.paddingLeft=20;
	self.paddingTop=5;
    self.itemPadding=0;
	self.paddingBottom=5;
	self.backgroundColor=UIColorFromRGB(0xA81616);
	[self initFromNIB];
    
    
}


-(void)showInlineErrorForType:(NSString*)type  show:(BOOL)show addtionalMessage:(NSString*)message
                   targetView:(UIView*)targetView offset:(CGPoint)offset{
    
    self.offsetPoint=offset;
    
    if(show==YES){
        
        self.width=targetView.width;
		self.height=_initialHeight;
        
        NSString *titleString=[[StringManager sharedInstance] stringForSection:ERRORSTRINGTYPE andType:[NSString stringWithFormat:@"errortitle_%@",type]];
		
		if(titleString==nil){
			_titleLabel.text=@"Error";
		}else {
			_titleLabel.text=titleString;
		}
        
		
		if(message==nil){
			_contentLabel.text=[[StringManager sharedInstance] stringForSection:ERRORSTRINGTYPE andType:[NSString stringWithFormat:@"errorcontent_%@",type]];
		}else {
			_contentLabel.text=message;
		}
		
		[self refresh];
		
		
		if(_errorIsActive==NO){
			
            
			CGRect initrect=self.frame;
			initrect.origin.y=0-(self.height+10);
			self.frame=initrect;
			[targetView addSubview:self];
			[ViewUtilities drawUIViewEdgeShadow:self];
			
			
			[UIView animateWithDuration:0.4f
								  delay:0
								options:UIViewAnimationOptionCurveEaseOut
							 animations:^{
								 CGRect rect=CGRectMake(_offsetPoint.x, _offsetPoint.y, self.width-offset.x, self.height);
								 self.frame=rect;
							 }
							 completion:^(BOOL finished){
								 [self hideError:YES];
							 }];
			_errorIsActive=YES;
			
			
		}else {
            
            // instant remove
            
            [self removeFromSuperview];
			
		}
        
	}
    
    
}


-(void)hideError:(BOOL)animated{
    
    if(animated){
        
        [UIView animateWithDuration:0.4f
                              delay:2.0f
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             CGRect rect=CGRectMake(_offsetPoint.x, _offsetPoint.y-(self.height+10), self.width, self.height);
                             self.frame=rect;
                         }
                         completion:^(BOOL finished){
                             _errorIsActive=NO;
                             [self removeFromSuperview];
                         }];
 
        
    }else{
        _errorIsActive=NO;
        [self removeFromSuperview];
    }
    
    
}



@end
