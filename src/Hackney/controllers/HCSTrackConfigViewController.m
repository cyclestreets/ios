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

#import "TripManager.h"
#import "Trip.h"
#import "User.h"

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
		//[mapView setCenterCoordinate:newLocation.coordinate animated:YES];
	}
	
	if ( _isRecordingTrack )
	{
		// add to CoreData store
		//CLLocationDistance distance = [tripManager addCoord:newLocation];
		//_trackDistanceLabel.text = [NSString stringWithFormat:@"%.1f mi", distance / 1609.344];
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
		
        // set recording flag so future location updates will be added as coords
        //appDelegate = [[UIApplication sharedApplication] delegate];
        //appDelegate.isRecording = YES;
        _isRecordingTrack = YES;
        [[NSUserDefaults standardUserDefaults] setBool:_isRecordingTrack forKey:@"isRecordingTrack"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        // set flag to update counter
        _shouldUpdateDuration = YES;
    }
    // do the saving
    else
    {
        NSLog(@"User Press Save Button");
        UIActionSheet *saveActionSheet = [[UIActionSheet alloc]
                           initWithTitle:@""
                           delegate:self
                           cancelButtonTitle:@"Continue"
                           destructiveButtonTitle:@"Discard"
                           otherButtonTitles:@"Save",nil];
        
        [saveActionSheet showInView:[UIApplication sharedApplication].keyWindow];
    }
	
	
	
}


- (NSDictionary *)newTripTimerUserInfo
{
    return [NSDictionary dictionaryWithObjectsAndKeys:[NSDate date], @"StartDate",
			[NSNull null], @"TripManager", nil ];
}



- (void)resetRecordingInProgress
{
	// reset button states
    appDelegate = [[UIApplication sharedApplication] delegate];
    appDelegate.isRecording = NO;
	recording = NO;
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey: @"recording"];
    [[NSUserDefaults standardUserDefaults] synchronize];
	_actionButton.enabled = YES;
	[_actionButton setTitle:@"Start" forState:UIControlStateNormal];
	
	// reset trip, reminder managers
	NSManagedObjectContext *context = _tripManager.managedObjectContext;
	[self initTripManager:[[TripManager alloc] initWithManagedObjectContext:context]];
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
