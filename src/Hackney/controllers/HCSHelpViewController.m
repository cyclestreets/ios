//
//  HCSHelpViewController.m
//  CycleStreets
//
//  Created by Neil Edwards on 27/01/2014.
//  Copyright (c) 2014 CycleStreets Ltd. All rights reserved.
//

#import "HCSHelpViewController.h"
#import "UIView+Additions.h"
#import "GlobalUtilities.h"
#import "StringManager.h"

@interface HCSHelpViewController ()

@property(nonatomic,weak) IBOutlet UIView				*contentView;
@property(nonatomic,weak) IBOutlet UIScrollView         *scrollView;

@end

@implementation HCSHelpViewController



//
/***********************************************
 * @description		NOTIFICATIONS
 ***********************************************/
//

-(void)listNotificationInterests{
    
	
	
	[super listNotificationInterests];
	
}

-(void)didReceiveNotification:(NSNotification*)notification{
	
	
	
}


//
/***********************************************
 * @description			VIEW METHODS
 ***********************************************/
//

- (void)viewDidLoad
{
	
	self.extendedLayoutIncludesOpaqueBars=NO;
	self.edgesForExtendedLayout = UIRectEdgeNone;
	
    [super viewDidLoad];
	
    [self createPersistentUI];
}


-(void)viewWillAppear:(BOOL)animated{
    
    [self createNonPersistentUI];
    
    [super viewWillAppear:animated];
}


-(void)createPersistentUI{
	
	if (self.presentingViewController) {
		self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(didSelectDismissbutton)];
	}
	
	
	[_scrollView addSubview:_contentView];
	[_scrollView setContentSize:_contentView.size];
    
}

-(void)createNonPersistentUI{
    
    
    
}




//
/***********************************************
 * @description			UI EVENTS
 ***********************************************/
//

-(IBAction)didSelectDismissbutton{
	
	[self dismissViewControllerAnimated:YES completion:^{
		
	}];
	
}



-(IBAction)didSelectOSMbutton:(id)sender{
	
	NSString *urlString=[[StringManager sharedInstance] stringForSection:@"global" andType:@"OSMURL"];
	
	if(urlString!=nil)
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
	
}
-(IBAction)didSelectCSbutton:(id)sender{
	
	NSString *urlString=[[StringManager sharedInstance] stringForSection:@"global" andType:@"CSURL"];
	
	if(urlString!=nil)
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
	
}


//
/***********************************************
 * @description			SEGUE METHODS
 ***********************************************/
//

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    
    
}


//
/***********************************************
 * @description			MEMORY
 ***********************************************/
//
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}


@end
