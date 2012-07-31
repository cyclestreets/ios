//
//  HudManager.m
//
//
//  Created by Neil Edwards on 22/06/2011.
//  Copyright 2011 Buffer. All rights reserved.
//

#import "HudManager.h"
#import "GlobalUtilities.h"


@implementation HudManager
SYNTHESIZE_SINGLETON_FOR_CLASS(HudManager);
@synthesize HUD;
@synthesize isShowing;
@synthesize activeWindowType;



- (id)init
{
    if ((self = [super init])) {
        isShowing = NO;
		activeWindowType=HUDWindowTypeNone;
    }
    return self;
}




//
/***********************************************
 * @description			HUDSUPPORT
 ***********************************************/
//


-(void)showHudWithType:(HUDWindowType)windowType withTitle:(NSString*)title andMessage:(NSString*)message{
	[self showHudWithType:windowType withTitle:title andMessage:message andDelay:1  andAllowTouch:NO];
}
-(void)showHudWithType:(HUDWindowType)windowType withTitle:(NSString*)title andMessage:(NSString*)message andDelay:(int)delayTime andAllowTouch:(BOOL)allowTouch{
    
	BetterLog(@"isShowing=%i",isShowing);
	
	if(isShowing==NO){
        if(HUD==nil){
            MBProgressHUD *hud=[[MBProgressHUD alloc] initWithView:[[UIApplication sharedApplication] keyWindow]];
            hud.removeFromSuperViewOnHide=YES;
            self.HUD=hud;
            [[[UIApplication sharedApplication] keyWindow] addSubview:self.HUD];
            HUD.delegate = self;
        }else{
           
        }
	}else {
		
		[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(removeHUD) object:nil];
	}
	
	NSString *titleText=title;
	NSString *messageText=message;
	
	if(activeWindowType!=windowType){
		
		switch(windowType){
			
			case HUDWindowTypeProgress:
				HUD.mode = MBProgressHUDModeIndeterminate;
				
			break;
			
			case HUDWindowTypeError:
				HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"exclaim.png"]];
				HUD.mode = MBProgressHUDModeCustomView;
				[self performSelector:@selector(removeHUD) withObject:nil afterDelay:delayTime];
			break;
				
			case HUDWindowTypeSuccess:
				HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkMark.png"]];
				HUD.mode = MBProgressHUDModeCustomView;
				[self performSelector:@selector(removeHUD) withObject:nil afterDelay:delayTime];
			break;
				
			case HUDWindowTypeLock:
				HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lock.png"]];
				HUD.mode = MBProgressHUDModeCustomView;
				[self performSelector:@selector(removeHUD) withObject:nil afterDelay:delayTime];
			break;
				
			case HUDWindowTypeIcon:
				HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:message]];
                messageText=nil;
				HUD.mode = MBProgressHUDModeCustomView;
				[self performSelector:@selector(removeHUD) withObject:nil afterDelay:delayTime];
			break;
				
			case HUDWindowTypeServer:
				HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"exclaim.png"]];
				HUD.mode = MBProgressHUDModeCustomView;
				titleText=@"Server Error";
				messageText=@"A Server error occured, please try again.";
				[self performSelector:@selector(removeHUD) withObject:nil afterDelay:delayTime];
			break;
		
		}
		
	}else {
		
		
	}

	
	if(titleText==nil && messageText!=nil){
		HUD.labelText=messageText;
	}
    if(titleText!=nil){
		HUD.labelText=titleText;
	}
	if(titleText!=nil && messageText!=nil){
		HUD.detailsLabelText=messageText;
	}
	HUD.touchToContinue=allowTouch;

	if(isShowing==NO){
		isShowing=YES;
		[HUD show:YES];
	}
	
}




-(void)updateHUDMessage:(NSString*)message{
	if(isShowing==YES)
	[HUD setDetailsLabelText:message];
}
-(void)updateHUDTitle:(NSString*)title{
	if(isShowing==YES)
	[HUD setLabelText:title];
}


-(void)removeHUD{
	[HUD hide:YES];	
}

-(void)removeHUD:(BOOL)animated{
	[HUD hide:animated];	
}


-(void)hudWasHidden{
	activeWindowType=HUDWindowTypeNone;
	isShowing=NO;
    HUD=nil;
}


@end
