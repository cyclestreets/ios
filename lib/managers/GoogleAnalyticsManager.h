//
//  GoogleAnalyticsManager.h
//
//
//  Created by Neil Edwards on 27/10/2010.
//  Copyright 2010 Chroma. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GANTracker.h"
#import "SynthesizeSingleton.h"


@interface GoogleAnalyticsManager : NSObject {
    
    BOOL                        GAEnabled;

}
@property (nonatomic)	BOOL		GAEnabled;
SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(GoogleAnalyticsManager);

-(void)trackPageViewWithNavigation:(NSArray*)views;
-(void)trackPageViewWithNavigation:(NSArray*)views andFragment:(NSString*)fragment;
-(void)trackEvent:(NSString*)event action:(NSString*)action;
-(void)trackPageViewWithString:(NSString*)string;;
@end
