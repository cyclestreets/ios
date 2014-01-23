//
//  HCSRouteListViewController.m
//  CycleStreets
//
//  Created by Neil Edwards on 20/01/2014.
//  Copyright (c) 2014 CycleStreets Ltd. All rights reserved.
//

#import "HCSRouteListViewController.h"
#import "CoreDataStore.h"
#import "TripManager.h"
#import "UIView+Additions.h"
#import "AppConstants.h"
#import "GenericConstants.h"

#import "constants.h"

static float const kAccessoryViewX=282.0;
static float const kAccessoryViewY=24.0;

static NSString *const  kCellReuseIdentifierCheck=@"CheckMark";
static NSString *const kCellReuseIdentifierExclamation=@"Exclamataion";
static NSString *const kCellReuseIdentifierInProgress=@"InProgress";

static int const kRowHeight=	75;
static int const kTagTitle=	1;
static int const kTagDetail=	2;
static int const kTagImage=	3;

@interface HCSRouteListViewController ()

@property (nonatomic,strong) NSMutableArray					*dataProvider;
@property (nonatomic,weak) IBOutlet UITableView				*tableView;


@end

@implementation HCSRouteListViewController

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


#pragma mark - Data Provider


-(void)refreshUIFromDataProvider{
	
	NSError *error;
	NSMutableArray *tripArray=[[[CoreDataStore mainStore] allForEntity:@"Trip" orderBy:@"start" ascending:NO error:&error] mutableCopy];
	
	if (tripArray == nil) {
		// Handle the error.
		NSLog(@"no saved trips");
		if ( error != nil )
			NSLog(@"Unresolved error2 %@, %@", error, [error userInfo]);
	}
	
	self.dataProvider=tripArray;
	[self.tableView reloadData];
	
}


//
/***********************************************
 * @description			VIEW METHODS
 ***********************************************/
//

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    [self createPersistentUI];
}


-(void)viewWillAppear:(BOOL)animated{
    
    [self createNonPersistentUI];
    
    [super viewWillAppear:animated];
}


-(void)createPersistentUI{
	
	
	
	if ( [[TripManager sharedInstance] countZeroDistanceTrips] )
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kZeroDistanceTitle
														message:kZeroDistanceMessage
													   delegate:self
											  cancelButtonTitle:@"Cancel"
											  otherButtonTitles:@"Recalculate", nil];
		alert.tag = 202;
		[alert show];
	}
	
	// check for countUnSyncedTrips
	else if ( [[TripManager sharedInstance] countUnSyncedTrips] )
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kUnsyncedTitle
														message:kUnsyncedMessage
													   delegate:nil
											  cancelButtonTitle:nil
											  otherButtonTitles:@"OK", nil];
		alert.tag = 303;
		[alert show];
	}
	else
		NSLog(@"no zero distance or unsynced trips found");
	
	// no trip selection by default
	selectedTrip = nil;
    
    pickerCategory = [[NSUserDefaults standardUserDefaults] integerForKey:@"pickerCategory"];
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey: @"pickerCategory"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

-(void)createNonPersistentUI{
    
	[self refreshUIFromDataProvider];
    
    
}



#pragma mark UITableView
//
/***********************************************
 * @description			UITABLEVIEW DELEGATES
 ***********************************************/
//

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 0;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}


-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
	Trip *trip = (Trip *)[_dataProvider objectAtIndex:indexPath.row];
	
	//Trip *currentTripinProgress = [[TripManager sharedInstance] getRecordingInProgress];

	
    
    return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
	/*
    // Navigation logic may go here. Create and push another view controller.
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
	
	// identify trip by row
	//NSLog(@"didSelectRow: %d", indexPath.row);
	selectedTrip = (Trip *)[trips objectAtIndex:indexPath.row];
	//NSLog(@"%@", selectedTrip);
	
	// check for recordingInProgress
	Trip *recordingInProgress = [delegate getRecordingInProgress];
	
	// if trip not yet uploaded => prompt to re-upload
	if ( recordingInProgress != selectedTrip )
	{
		if ( !selectedTrip.uploaded )
		{
			// init new TripManager instance with selected trip
			// release previously set tripManager
			if ( tripManager )
				[tripManager release];
			
			tripManager = [[TripManager alloc] initWithTrip:selectedTrip];
			//tripManager.activityDelegate = self;
			tripManager.alertDelegate = self;
			tripManager.parent = self;
			// prompt to upload
			[self promptToConfirmPurpose];
		}
		
		// else => goto map view
		else
			[self displaySelectedTripMap];
	}

    */
}



//
/***********************************************
 * @description			UI EVENTS
 ***********************************************/
//




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
