//  AppDelegate.h
//  CycleStreets
//

#import <UIKit/UIKit.h>


@interface AppDelegate : NSObject <UIApplicationDelegate> {
	
    
}

@property (nonatomic, strong)	IBOutlet UIWindow		*window;
@property (nonatomic, strong)	UITabBarController		*tabBarController;

-(void)showTabBarViewControllerByName:(NSString*)viewname;

@end

