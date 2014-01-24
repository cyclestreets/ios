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
#import "UIAlertView+BlocksKit.h"
#import "HCSMapViewController.h"

#import "constants.h"
#import "Trip.h"

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

// data
@property (nonatomic,strong) NSMutableArray					*dataProvider;
@property (nonatomic,strong)  Trip							*selectedTrip;

// ui
@property (nonatomic,weak) IBOutlet UITableView				*tableView;


// state


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
	
	
	if ( [[TripManager sharedInstance] countZeroDistanceTrips] ){
		
		UIAlertView *alert=[UIAlertView alertWithTitle:kZeroDistanceTitle message:kZeroDistanceMessage];
		[alert setCancelButtonWithTitle:@"Cancel"	handler:nil];
		[alert addButtonWithTitle:@"Recalculate" handler:^{
			//TODO: we will not have thsi stupid thing, tripmamanger need a new method that takes a trip [tripManager recalculateTripDistances];
		}];
		[alert show];
		
		
	}else if ( [[TripManager sharedInstance] countUnSyncedTrips] ){
		
		UIAlertView *alert=[UIAlertView alertWithTitle:kUnsyncedTitle message:kUnsyncedMessage];
		[alert addButtonWithTitle:@"OK" handler:^{
			[self displaySelectedTripMap];
		}];
		[alert show];
	}
	else
		NSLog(@"no zero distance or unsynced trips found");
	
	// no trip selection by default
	self.selectedTrip = nil;
    
	#pragma message  ("What does this do?")
    /*
	 pickerCategory = [[NSUserDefaults standardUserDefaults] integerForKey:@"pickerCategory"];
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey: @"pickerCategory"];
    [[NSUserDefaults standardUserDefaults] synchronize];
	 */
    
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
    

	
	self.selectedTrip = (Trip *)[_dataProvider objectAtIndex:indexPath.row];
	
	// check for recordingInProgress
	Trip *currentRecordingTrip = [TripManager sharedInstance].currentRecordingTrip;
	
	// if trip not yet uploaded => prompt to re-upload
	if ( currentRecordingTrip != _selectedTrip ){
		
		if ( !_selectedTrip.uploaded ){
			
			[TripManager sharedInstance].selectedTrip=_selectedTrip;
			//[self promptToConfirmPurpose];
		}else{
			[self displaySelectedTripMap];
		}
		
			
	}

}




- (void)displaySelectedTripMap
{
	
	if ( _selectedTrip ){
		HCSMapViewController *mvc = [[HCSMapViewController alloc] initWithTrip:_selectedTrip];
		[[self navigationController] pushViewController:mvc animated:YES];
	}
	
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
