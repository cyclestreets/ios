//
//  HudManager.h
//
//
//  Created by Neil Edwards on 22/06/2011.
//  Copyright 2011 Chroma. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SynthesizeSingleton.h"
#import "MBProgressHUD.h"

enum  {
	HUDWindowTypeProgress=0,
	HUDWindowTypeSuccess=1,
	HUDWindowTypeError=2,
	HUDWindowTypeLock=3,
	HUDWindowTypeServer=4,
	HUDWindowTypeNone
};
typedef int HUDWindowType;


@interface HudManager : NSObject <MBProgressHUDDelegate>{
	
	MBProgressHUD				*HUD;
	
	BOOL						isShowing;
	
	HUDWindowType				activeWindowType;
	

}
SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(HudManager);
@property (nonatomic, retain)		MBProgressHUD				* HUD;
@property (nonatomic, assign)		BOOL				 isShowing;
@property (nonatomic, assign)		HUDWindowType				 activeWindowType;
- (id)init;
-(void)showHudWithType:(HUDWindowType)windowType withTitle:(NSString*)title andMessage:(NSString*)message;
-(void)showHudWithType:(HUDWindowType)windowType withTitle:(NSString*)title andMessage:(NSString*)message andDelay:(int)delayTime andAllowTouch:(BOOL)allowTouch;
-(void)updateHUDMessage:(NSString*)message;
-(void)updateHUDTitle:(NSString*)title;
-(void)removeHUD;

@end
