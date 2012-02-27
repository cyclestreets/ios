//
//  GoogleAnalyticsManager.m
//
//
//  Created by Neil Edwards on 27/10/2010.
//  Copyright 2010 CycleStreets.. All rights reserved.
//

#import "GoogleAnalyticsManager.h"
#import "SynthesizeSingleton.h"
#import "GANTracker.h"
#import "SuperViewController.h"
#import "GlobalUtilities.h"
#import "AppConfigManager.h"

static const NSInteger kGANDispatchPeriodSec = 10;


@interface GoogleAnalyticsManager(Private)

-(void)sendTrackArray:(NSMutableArray*)pathArray;

@end


@implementation GoogleAnalyticsManager
SYNTHESIZE_SINGLETON_FOR_CLASS(GoogleAnalyticsManager);
@synthesize GAEnabled;

//=========================================================== 
// dealloc
//=========================================================== 
- (void)dealloc
{
    
    [super dealloc];
}



-(id)init{
	
	if (self = [super init])
	{
        
        GAEnabled=[[[AppConfigManager sharedInstance].configDict objectForKey:@"GAEnabled"] boolValue];
        
        if(GAEnabled==YES){
            
            NSString *GATrackingCode=[[AppConfigManager sharedInstance].configDict objectForKey:@"GATrackingCode"];
		
            [[GANTracker sharedTracker] startTrackerWithAccountID:GATrackingCode dispatchPeriod:kGANDispatchPeriodSec delegate:nil];
         
         }
		
	}
	return self;
}



//
/***********************************************
 * @description			path will be full navigation path to item ie racecard/meeting/race/runner
 ***********************************************/
//
-(void)trackPageViewWithNavigation:(NSArray*)views{
	if(GAEnabled==YES){
        if ([views count]>0) {

            NSMutableArray	*pathArray=[[NSMutableArray alloc]init];
            for(SuperViewController *viewcontroller in views){
                if(viewcontroller!=nil){
                    if([viewcontroller respondsToSelector:@selector(GATag)]){
                        NSString *gatag=[viewcontroller performSelector:@selector(GATag)];
                        if(gatag!=nil)
                        [pathArray addObject:[viewcontroller performSelector:@selector(GATag)]];
                    }
                }
            }
            
            if([pathArray count]>0){
                [self sendTrackArray:pathArray];
            }
            [pathArray release];
            
        }
	}
}
		

//
/***********************************************
 * @description			accepts viewcontroller navigation array plus fragment, used for views that are not loaded via navigation push
 ***********************************************/
//
-(void)trackPageViewWithNavigation:(NSArray*)views andFragment:(NSString*)fragment{
	if(GAEnabled==YES){
        if ([views count]>0) {
            NSMutableArray	*pathArray=[[NSMutableArray alloc]init];
            for(SuperViewController *viewcontroller in views){
                if(viewcontroller!=nil){
                    if([viewcontroller respondsToSelector:@selector(GATag)]){
                        NSString *gatag=[viewcontroller performSelector:@selector(GATag)];
                        if(gatag!=nil)
                            [pathArray addObject:[viewcontroller performSelector:@selector(GATag)]];
                    }
                }
            }
            
            [pathArray addObject:fragment];
            
            if([pathArray count]>0){
                [self sendTrackArray:pathArray];
            }
            [pathArray release];
        }
	}
}



-(void)sendTrackArray:(NSMutableArray*)pathArray{
	
	BetterLog(@"GA Enabled=%i  for path=%@",GAEnabled,pathArray);
	
	if(GAEnabled==YES){
        NSString *pathString=[NSString stringWithFormat:@"/%@",[pathArray componentsJoinedByString:@"/"]];
        
        BetterLog(@"GA Enabled=%i  for path=%@",GAEnabled,pathString);
        
        
        NSError *error=nil;
        if (![[GANTracker sharedTracker] trackPageview:	pathString
                                        withError:&error]) {
            // Handle error here
        }
	}
}



-(void)trackEvent:(NSString*)event action:(NSString*)action{
	if(GAEnabled==YES){
        NSError *error=nil;
        if (![[GANTracker sharedTracker] trackEvent:event
                                             action:action
                                              label:@"CycleStreets"
                                              value:-1
                                          withError:&error]) {
            // Handle error here
        }
	}
}
					  

//
/***********************************************
 * @description			adds whatever string you want 
 ***********************************************/
//

-(void)trackPageViewWithString:(NSString*)string{
	NSMutableArray	*pathArray=[[NSMutableArray alloc]init];
	[pathArray addObject:string];
	[self sendTrackArray:pathArray];
	[pathArray release];
}


@end
