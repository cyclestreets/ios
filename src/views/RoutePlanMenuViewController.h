//
//  RoutePlanMenuViewController.h
//  CycleStreets
//
//  Created by neil on 27/03/2012.
//  Copyright (c) 2012 CycleStreets Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RoutePlanMenuViewController : UIViewController{
	
	
	NSString		*plan;
	
	IBOutlet		UISegmentedControl			*routePlanControl;
	
	
}
@property (nonatomic, strong) NSString		* plan;
@property (nonatomic, strong) IBOutlet UISegmentedControl		* routePlanControl;
@end
