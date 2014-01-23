//
//  HCSTrackConfigViewController.m
//  CycleStreets
//
//  Created by Neil Edwards on 20/01/2014.
//  Copyright (c) 2014 CycleStreets Ltd. All rights reserved.
//

#import "HCSTrackConfigViewController.h"
#import "AppConstants.h"
#import "UserLocationManager.h"
#import "RMMapView.h"
#import "CycleStreets.h"
#import "SVPulsingAnnotationView.h"
#import "UIView+Additions.h"
#import "GlobalUtilities.h"
#import "UIActionSheet+BlocksKit.h"
#import "HCSMapViewController.h"
#import "PickerViewController.h"

#import "TripManager.h"
#import "Trip.h"
#import "User.h"



#import "CoreDataStore.h"

#import <CoreLocation/CoreLocation.h>

static NSString *const LOCATIONSUBSCRIBERID=@"HCSTrackConfig";

@interface HCSTrackConfigViewController ()<GPSLocationProvider,RMMapViewDelegate,UIActionSheetDelegate>


// hackney
@property (nonatomic, strong) TripManager							*tripManager;



@property (nonatomic, strong) IBOutlet RMMapView						* mapView;//map of current area
@property (nonatomic, strong) IBOutlet UILabel							* attributionLabel;// map type label


@property(nonatomic,weak) IBOutlet UILabel								*trackDurationLabel;
@property(nonatomic,weak) IBOutlet UILabel								*trackSpeedLabel;
@property(nonatomic,weak) IBOutlet UILabel								*trackDistanceLabel;

@property(nonatomic,weak) IBOutlet UIButton								*actionButton;


@property (nonatomic, strong) CLLocation								* lastLocation;// last location
@property (nonatomic, strong) CLLocation								* currentLocation;

@property (nonatomic, strong) SVPulsingAnnotationView					* gpsLocationView;


// opration

@property (nonatomic,strong)  NSTimer									*trackTimer;


// state
@property (nonatomic,assign)  BOOL										isRecordingTrack;
@property (nonatomic,assign)  BOOL										shouldUpdateDuration;
@property (nonatomic,assign)  BOOL										didUpdateUserLocation;
@property (nonatomic,assign)  BOOL										userInfoSaved;


-(void)updateUI;


@end

@implementation HCSTrackConfigViewController



//
/***********************************************
 * @description		NOTIFICATIONS
 ***********************************************/
//

-(void)listNotificationInterests{
	
	[self initialise];
    
	[notifications addObject:GPSLOCATIONCOMPLETE];
	[notifications addObject:GPSLOCATIONUPDATE];
	[notifications addObject:GPSLOCATIONFAILED];
	
	[super listNotificationInterests];
	
}

-(void)didReceiveNotification:(NSNotification*)notification{
	
	[super didReceiveNotification:notification];
	
	NSString		*name=notification.name;
	
	if([[UserLocationManager sharedInstance] hasSubscriber:LOCATIONSUBSCRIBERID]){
		
		if([name isEqualToString:GPSLOCATIONCOMPLETE]){
			[self locationDidComplete:notification];
		}
		
		if([name isEqualToString:GPSLOCATIONUPDATE]){
			[self locationDidUpdate:notification];
		}
		
		if([name isEqualToString:GPSLOCATIONFAILED]){
			[self locationDidFail:notification];
		}
		
	}
	
}



#pragma mark - Location updates

-(void)locationDidComplete:(NSNotification*)notification{
	
	BetterLog(@"");
	
	CLLocation *location=(CLLocation*)[notification object];
	
	self.lastLocation=location;
	
	[CycleStreets zoomMapView:_mapView toLocation:location];
	
	
	[self displayLocationIndicator:YES];
	
	
}

-(void)locationDidUpdate:(NSNotification*)notification{
	
	CLLocation *location=(CLLocation*)[notification object];
	CLLocationDistance deltaDistance = [location distanceFromLocation:_lastLocation];
	
	self.lastLocation=_currentLocation;
	self.currentLocation=location;
	
	[CycleStreets zoomMapView:_mapView toLocation:_currentLocation];
	
	[self displayLocationIndicator:YES];
	
    
	if ( !_didUpdateUserLocation )
	{
		NSLog(@"zooming to current user location");
		//MKCoordinateRegion region = { newLocation.coordinate, { 0.0078, 0.0068 } };
		//[mapView setRegion:region animated:YES];
		
		_didUpdateUserLocation = YES;
	}
	
	// only update map if deltaDistance is at least some epsilon
	else if ( deltaDistance > 1.0 )
	{
		//NSLog(@"center map to current user location");
		[_mapView setCenterCoordinate:_currentLocation.coordinate animated:YES];
	}
	
	if ( _isRecordingTrack )
	{
		// add to CoreData store
		CLLocationDistance distance = [_tripManager addCoord:_currentLocation];
		_trackDistanceLabel.text = [NSString stringWithFormat:@"%.1f mi", distance / 1609.344];
	}
	
	// 	double mph = ( [trip.distance doubleValue] / 1609.344 ) / ( [trip.duration doubleValue] / 3600. );
	if ( _currentLocation.speed >= 0 )
		_trackSpeedLabel.text = [NSString stringWithFormat:@"%.1f mph", _currentLocation.speed * 3600 / 1609.344];
	else
		_trackSpeedLabel.text = @"0.0 mph";
	
}

-(void)locationDidFail:(NSNotification*)notification{
	
	
	//[self resetLocationOverlay];
	
}



-(void)displayLocationIndicator:(BOOL)display{
	
	if(_gpsLocationView.superview==nil && display==YES)
		[self.mapView addSubview:_gpsLocationView];
	
	
	int alpha=display==YES ? 1 :0;
	
	if(_gpsLocationView.superview!=nil)
		[_gpsLocationView updateToLocation];
	
	if(display==YES && _gpsLocationView.alpha==1)
		return;
	
	if(display==NO && _gpsLocationView.alpha==0)
		return;
	
	if(display==YES){
		_gpsLocationView.visible=display;
		_gpsLocationView.alpha=0;
	}
	
	
	[UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
		_gpsLocationView.alpha=alpha;
	} completion:^(BOOL finished) {
		if(_gpsLocationView.alpha==0){
			_gpsLocationView.visible=display;
			[_gpsLocationView removeFromSuperview];
		}
		
	}];
	
}


//
/***********************************************
 * @description			VIEW METHODS
 ***********************************************/
//

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.tripManager=[TripManager sharedInstance];
	_tripManager.parent          = self;
	
	[self hasUserInfoBeenSaved];
	
    [self createPersistentUI];
}


-(void)viewWillAppear:(BOOL)animated{
    
    [self createNonPersistentUI];
    
    [super viewWillAppear:animated];
}


-(void)createPersistentUI{
	
	
	[RMMapView class];
	[_mapView setDelegate:self];
	
	
	self.gpsLocationView=[[SVPulsingAnnotationView alloc]initWithFrame:_mapView.frame];
	_gpsLocationView.annotationColor = [UIColor colorWithRed:0.678431 green:0 blue:0 alpha:1];
	_gpsLocationView.visible=NO;
	_gpsLocationView.alpha=0;
	[_gpsLocationView setLocationProvider:self];
	
	
	//TODO: UI styling
	
	[_actionButton addTarget:self action:@selector(didSelectActionButton:) forControlEvents:UIControlEventTouchUpInside];
	
	
}

-(void)createNonPersistentUI{
    
	
	[[UserLocationManager sharedInstance] startUpdatingLocationForSubscriber:LOCATIONSUBSCRIBERID];
    
    
}



-(void)updateUI{
	
	if ( _shouldUpdateDuration )
	{
		NSDate *startDate = [[_trackTimer userInfo] objectForKey:@"StartDate"];
		NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:startDate];
		
		static NSDateFormatter *inputFormatter = nil;
		if ( inputFormatter == nil )
			inputFormatter = [[NSDateFormatter alloc] init];
		
		[inputFormatter setDateFormat:@"HH:mm:ss"];
		NSDate *fauxDate = [inputFormatter dateFromString:@"00:00:00"];
		[inputFormatter setDateFormat:@"HH:mm:ss"];
		NSDate *outputDate = [[NSDate alloc] initWithTimeInterval:interval sinceDate:fauxDate];
		
		self.trackDurationLabel.text = [inputFormatter stringFromDate:outputDate];
	}
	
	
}


- (void)resetDurationDisplay
{
	_trackDurationLabel.text = @"00:00:00";
	
	_trackDistanceLabel.text = @"0 mi";
}

-(void)resetTimer{
	
	if(_trackTimer!=nil)
		[_trackTimer invalidate];
}



#pragma mark - RMMap delegate


-(void)doubleTapOnMap:(RMMapView*)map At:(CGPoint)point{
	
}

- (void) afterMapMove: (RMMapView*) map {
	[self afterMapChanged:map];
}


- (void) afterMapZoom: (RMMapView*) map byFactor: (float) zoomFactor near:(CGPoint) center {
	[self afterMapChanged:map];
}

- (void) afterMapChanged: (RMMapView*) map {
	
	if(_gpsLocationView.superview!=nil)
		[_gpsLocationView updateToLocation];
	
}



#pragma mark - UI events


-(IBAction)didSelectActionButton:(id)sender{
	
	if(_isRecordingTrack == NO)
    {
        BetterLog(@"start");
        
        // start the timer if needed
        if ( _trackTimer == nil )
        {
			[self resetDurationDisplay];
			self.trackTimer = [NSTimer scheduledTimerWithTimeInterval:0.5f
													 target:self selector:@selector(updateUI)
												   userInfo:[self newTripTimerUserInfo] repeats:YES];
        }
        
       // set start button to "Save"
		[_actionButton setTitle:@"Save" forState:UIControlStateNormal];
		
        _isRecordingTrack = YES;
		[[TripManager sharedInstance] startTrip];
        
        // set flag to update counter
        _shouldUpdateDuration = YES;
    }
    // do the saving
    else
    {
		__weak __block HCSTrackConfigViewController *weakSelf=self;
		UIActionSheet *actionSheet=[UIActionSheet sheetWithTitle:@""];
		[actionSheet setDestructiveButtonWithTitle:@"Discard"	handler:^{
			[weakSelf resetRecordingInProgress];
		}];
		[actionSheet addButtonWithTitle:@"Save" handler:^{
			[weakSelf save];
		}];
		
		[actionSheet setCancelButtonWithTitle:@"Continue" handler:^{
			_shouldUpdateDuration=YES;
		}];
		
		
		
		[actionSheet showInView:[[[UIApplication sharedApplication]delegate]window]];
		
    }
	
}


- (void)save
{
	[[NSUserDefaults standardUserDefaults] setInteger:0 forKey: @"pickerCategory"];
    [[NSUserDefaults standardUserDefaults] synchronize];
	// go directly to TripPurpose, user can cancel from there
	if ( YES )
	{
		// Trip Purpose
		NSLog(@"INIT + PUSH");
		PickerViewController *tripPurposePickerView = [[PickerViewController alloc]
													   //initWithPurpose:[tripManager getPurposeIndex]];
													   initWithNibName:@"TripPurposePicker" bundle:nil];
		[tripPurposePickerView setDelegate:self];
		//[[self navigationController] pushViewController:pickerViewController animated:YES];
		[self.navigationController presentModalViewController:tripPurposePickerView animated:YES];
		
	}
	
	// prompt to confirm first
	else
	{
		// pause updating the counter
		_shouldUpdateDuration = NO;
		
		// construct purpose confirmation string
		NSString *purpose = nil;
		if ( _tripManager != nil )
			purpose = [self getPurposeString:[_tripManager getPurposeIndex]];
		
		
		__weak __block HCSTrackConfigViewController *weakSelf=self;
		UIActionSheet *actionSheet=[UIActionSheet sheetWithTitle:@"Stop recording & save this trip?"];
		
		[actionSheet addButtonWithTitle:@"Save" handler:^{
			[weakSelf save];
		}];
		
		[actionSheet setCancelButtonWithTitle:@"Continue" handler:^{
			_shouldUpdateDuration=YES;
		}];
		
		[actionSheet showFromTabBar:self.navigationController.tabBarController.tabBar];

		
	}
    
}


- (void)didEnterTripDetails:(NSString *)details{
    [_tripManager saveNotes:details];
    NSLog(@"Trip Added details: %@",details);
}

- (void)saveTrip{
    [_tripManager saveTrip];
    NSLog(@"Save trip");
}

- (void)displayUploadedTripMap
{
    Trip *trip = _tripManager.trip;
    [self resetRecordingInProgress];
    
    // load map view of saved trip
    HCSMapViewController *mvc = [[HCSMapViewController alloc] initWithTrip:trip];
    [[self navigationController] pushViewController:mvc animated:YES];
    NSLog(@"displayUploadedTripMap");
    
}


- (void)displayUploadedNote
{
//    Note *note = noteManager.note;
//    
//    // load map view of note
//    NoteViewController *mvc = [[NoteViewController alloc] initWithNote:note];
//    [[self navigationController] pushViewController:mvc animated:YES];
//    NSLog(@"displayUploadedNote");
    
}



#pragma mark - Trip methods

- (BOOL)hasUserInfoBeenSaved
{
	BOOL response = NO;
	
	NSError *error;
	NSArray *fetchResults=[[CoreDataStore mainStore] allForEntity:@"User" error:&error];
	
	if ( fetchResults.count>0 ){
		
		if ( fetchResults != nil ){
			
			User *user = (User*)[fetchResults objectAtIndex:0];
			
			self.userInfoSaved = [user userInfoSaved];
			response = _userInfoSaved;
			
		}else{
			// Handle the error.
			NSLog(@"no saved user");
			if ( error != nil )
				NSLog(@"PersonalInfo viewDidLoad fetch error %@, %@", error, [error localizedDescription]);
		}
	}else{
		NSLog(@"no saved user");
	}
		
	
	return response;
}


- (NSDictionary *)newTripTimerUserInfo
{
    return [NSDictionary dictionaryWithObjectsAndKeys:[NSDate date], @"StartDate",
			[NSNull null], @"TripManager", nil ];
}



- (void)resetRecordingInProgress
{
	[[TripManager sharedInstance] resetTrip];
	_actionButton.enabled = YES;
	[_actionButton setTitle:@"Start" forState:UIControlStateNormal];
	
	_tripManager.dirty = YES;
	
	[self resetDurationDisplay];
	[self resetTimer];
}



#pragma mark - Location Provider


- (float)getX {
	CGPoint p = [self.mapView coordinateToPixel:self.currentLocation.coordinate];
	return p.x;
}

- (float)getY {
	CGPoint p = [self.mapView coordinateToPixel:self.currentLocation.coordinate];
	return p.y;
}

- (float)getRadius {
	
	double metresPerPixel = [_mapView metersPerPixel];
	float locationRadius=(self.currentLocation.horizontalAccuracy / metresPerPixel);
	
	return MAX(locationRadius, 40.0f);
}



#pragma mark TripPurposeDelegate methods


- (NSString *)setPurpose:(unsigned int)index
{
	NSString *purpose = [_tripManager setPurpose:index];
	return [self updatePurposeWithString:purpose];
}


- (NSString *)getPurposeString:(unsigned int)index
{
	return [_tripManager getPurposeString:index];
}

- (NSString *)updatePurposeWithString:(NSString *)purpose
{
	// only enable start button if we don't already have a pending trip
	if ( _trackTimer == nil )
		_actionButton.enabled = YES;
	
	_actionButton.hidden = NO;
	
	return purpose;
}


- (NSString *)updatePurposeWithIndex:(unsigned int)index
{
	return [self updatePurposeWithString:[_tripManager getPurposeString:index]];
}


- (void)didCancelPurpose
{
	[self.navigationController dismissModalViewControllerAnimated:YES];
    [[TripManager sharedInstance] startTrip];
	_isRecordingTrack = YES;
	_shouldUpdateDuration = YES;
}


- (void)didCancelNote
{
	[self.navigationController dismissModalViewControllerAnimated:YES];
    
}


- (void)didPickPurpose:(unsigned int)index
{
	_isRecordingTrack = NO;
    [[TripManager sharedInstance]resetTrip];
	_actionButton.enabled = YES;
	[self resetTimer];
	
	[_tripManager setPurpose:index];
	//[tripManager promptForTripNotes];
    //do something here: may change to be the save as a separate view. Not prompt.
}



#pragma mark Manager methods

- (void)initTripManager:(TripManager*)manager
{
	manager.dirty			= YES;
	self.tripManager		= manager;
    manager.parent          = self;
}


//- (void)initNoteManager:(NoteManager*)manager
//{
//	self.noteManager = manager;
//    manager.parent = self;
//}


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
