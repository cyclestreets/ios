//
//  RoutePlanMenuViewController.m
//  CycleStreets
//
//  Created by neil on 27/03/2012.
//  Copyright (c) 2012 CycleStreets Ltd. All rights reserved.
//

#import "RoutePlanMenuViewController.h"
#import "SettingsVO.h"
#import "SettingsManager.h"

@interface RoutePlanMenuViewController(Private)

- (void) select:(UISegmentedControl *)control byString:(NSString *)selectTitle;
-(IBAction)changed:(id)sender;

@end


@implementation RoutePlanMenuViewController
@synthesize plan;
@synthesize routePlanControl;



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.contentSizeForViewInPopover = self.view.frame.size;
    }
    return self;
}




- (void)viewDidLoad
{
    [super viewDidLoad];
	
	
}

-(void)viewWillAppear:(BOOL)animated{
	
	if(plan==nil){
		SettingsVO *dataProvider=[SettingsManager sharedInstance].dataProvider;
		self.plan=dataProvider.plan;
	}
	[self select:routePlanControl byString:plan];
	
	[routePlanControl addTarget:self action:@selector(changed:) forControlEvents:UIControlEventValueChanged];
	
	
	[super viewWillAppear:animated];
}


- (void) select:(UISegmentedControl *)control byString:(NSString *)selectTitle {
	for (NSInteger i = 0; i < [control numberOfSegments]; i++) {
		NSString *title = [[control titleForSegmentAtIndex:i] lowercaseString];
		if (NSOrderedSame == [title compare: selectTitle]) {
			control.selectedSegmentIndex = i;
			break;
		}
	}	
}

-(IBAction)changed:(id)sender{
	
	CSRoutePlanType index=routePlanControl.selectedSegmentIndex;
	
	NSString *planType=[AppConstants planConstantToString:index];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:EVENTMAPROUTEPLAN object:nil userInfo:[NSDictionary dictionaryWithObject:planType forKey:@"planType"]];
	
}


//
/***********************************************
 * @description			UIEVENTS
 ***********************************************/
//



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
