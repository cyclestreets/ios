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
#import "UIView+Additions.h"
#import "GlobalUtilities.h"
#import "UIActionSheet+BlocksKit.h"
#import "HCBackgroundLocationManager.h"
#import "HCSMapViewController.h"
#import "PickerViewController.h"
#import "HCSUserDetailsViewController.h"
#import "PhotoWizardViewController.h"
#import "TripManager.h"
#import "Trip.h"
#import "User.h"
#import "RMUserLocation.h"
#import "UserManager.h"
#import "SettingsManager.h"
#import "CoreDataStore.h"
#import "NSTimer+BUPausable.h"


#import <CoreLocation/CoreLocation.h>

static NSString *const LOCATIONSUBSCRIBERID=@"HCSTrackConfig";


@interface HCSTrackConfigViewController ()<RMMapViewDelegate,UIActionSheetDelegate,UIPickerViewDelegate,HCBackgroundLocationManagerDelegate>


// hackney
@property (nonatomic, strong) TripManager								*tripManager;
@property (nonatomic,strong)  Trip										*currentTrip;


@property (nonatomic, strong) IBOutlet RMMapView						* mapView;//map of current area
@property (nonatomic, strong) IBOutlet UILabel							* attributionLabel;// map type label


@property(nonatomic,weak) IBOutlet UILabel								*trackDurationLabel;
@property(nonatomic,weak) IBOutlet UILabel								*trackSpeedLabel;
@property(nonatomic,weak) IBOutlet UILabel								*trackDistanceLabel;

@property(nonatomic,weak) IBOutlet UIButton								*actionButton;
@property (weak, nonatomic) IBOutlet UIView								*actionView;


@property (nonatomic,assign)  CLLocationDistance						currentDistance;

@property (nonatomic, strong) CLLocation								* lastLocation;// last location
@property (nonatomic, strong) CLLocation								* currentLocation;



// opration

@property (nonatomic,strong)  NSTimer									*trackTimer;


// state
@property (nonatomic,assign)  BOOL										isRecordingTrack;
@property (nonatomic,assign)  BOOL										shouldUpdateDuration;
@property (nonatomic,assign)  BOOL										didUpdateUserLocation;



@end

@implementation HCSTrackConfigViewController



#pragma mark - NSNotification

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
	[notifications addObject:MAPSTYLECHANGED];
	[notifications addObject:HCS_TRIPCOMPLETE];
	[notifications addObject:MAPUNITCHANGED];
	
	[super listNotificationInterests];
	
}

-(void)didReceiveNotification:(NSNotification*)notification{
	
	[super didReceiveNotification:notification];
	
	NSString		*name=notification.name;
	
	
	
	if([name isEqualToString:HCS_TRIPCOMPLETE]){
		[self resetRecordingInProgress];
	}
	
	if([name isEqualToString:MAPSTYLECHANGED]){
		[self didNotificationMapStyleChanged];
	}
	
	if([name isEqualToString:MAPUNITCHANGED]){
		[self didNotificationMapUnitChanged];
	}
	
}



- (void) didNotificationMapStyleChanged {
	self.mapView.tileSource = [CycleStreets tileSource];
}


- (void) didNotificationMapUnitChanged {
	
	[self updateUIForDistance];
	
	[self updateUIForSpeed];
	
}



- (void)resetRecordingInProgress{
	
	_isRecordingTrack=NO;
	_shouldUpdateDuration=NO;
	
	[self updateActionStateForTrip];
	
	_mapView.userTrackingMode=RMUserTrackingModeNone;
	
	[self resetDurationDisplays];
	
	[self resetTimer];
}



#pragma mark - RMMap & background Location updates


- (void)mapView:(RMMapView *)mapView didUpdateUserLocation:(RMUserLocation *)userLocation{
	
	if(userLocation.location==nil)
		return;
	
	CLLocation *location=userLocation.location;
	CLLocationDistance deltaDistance = [location distanceFromLocation:_lastLocation];
	
	
	[self didReceiveUpdatedLocations:@[location]];
	
    
	if ( !_didUpdateUserLocation ){
		
		[_mapView setCenterCoordinate:location.coordinate animated:YES];
		
		_didUpdateUserLocation = YES;
		
	}else if ( deltaDistance > 1.0 ){
		
		[_mapView setCenterCoordinate:location.coordinate animated:YES];
	}
	
	
}






#pragma mark - HCBackgroundLocationManagerDelegate method

// this could be adjusted in the future to correctly support deferred background locations
-(void)didReceiveUpdatedLocations:(NSArray*)locations{
	
	// we are not using deferred locations so we can do this.
	CLLocation *location=locations[0];
	
	self.lastLocation=_currentLocation;
	self.currentLocation=location;
	
	if ( _isRecordingTrack ){
		
		self.currentDistance=[_tripManager addCoord:_currentLocation];
		
		[self updateUIForDistance];
		
		[self updateUIForSpeed];
		
	}
	
}


#pragma mark -  UI updates


-(void)pauseTrip:(BOOL)pause{
	
	if(pause==YES){
		[[TripManager sharedInstance] resetTrip];
	}else{
		[[TripManager sharedInstance] startTrip];
	}
	
	[_trackTimer pauseOrResume];
	
	_isRecordingTrack = !pause;
	_shouldUpdateDuration = !pause;
	
}


-(void)updateUIForDuration{
	
	if ( _shouldUpdateDuration ){
		
		if(_trackTimer==nil)
			return;
		
		NSDate *startDate = _trackTimer.startDate;
		NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:startDate];
		
		static NSDateFormatter *inputFormatter = nil;
		if ( inputFormatter == nil )
			inputFormatter = [[NSDateFormatter alloc] init];
		
		[inputFormatter setDateFormat:@"HH:mm:ss"];
		NSDate *fauxDate = [inputFormatter dateFromString:@"00:00:00"];
		[inputFormatter setDateFormat:@"HH:mm:ss"];
		NSDate *outputDate = [[NSDate alloc] initWithTimeInterval:interval sinceDate:fauxDate];
		
		self.trackDurationLabel.text = [inputFormatter stringFromDate:outputDate];
		
	}else{
		
		if(_isRecordingTrack==NO)
			self.trackDurationLabel.text=@"00:00:00";
	}
	
	
}


- (void)resetDurationDisplays{
	
	[self updateUIForDistance];
	[self updateUIForSpeed];
	[self updateUIForDuration];
}


-(void)updateUIForDistance{
	
	
	if ( _isRecordingTrack ){
		
		if([SettingsManager sharedInstance].routeUnitisMiles==YES){
			float totalMiles = _currentDistance/1600;
			_trackDistanceLabel.text=[NSString stringWithFormat:@"%3.1f miles", totalMiles];
		}else {
			float	kms=_currentDistance/1000;
			_trackDistanceLabel.text=[NSString stringWithFormat:@"%4.1f km", kms];
		}
	
	}else{
		_trackDistanceLabel.text = [NSString stringWithFormat:@"0.0 %@",[SettingsManager sharedInstance].routeUnitisMiles ? @"miles" : @"km"];
	}
	
	
}



-(void)updateUIForSpeed{
	
	if ( _isRecordingTrack && _currentLocation.speed >= 0 ){
		
		double kmh=(_currentLocation.speed*TIME_HOUR)/1000;
	
		if([SettingsManager sharedInstance].routeUnitisMiles==YES) {
			double mileSpeed = kmh/1.609;
			_trackSpeedLabel.text= [NSString stringWithFormat:@"%2.0f mph", mileSpeed];
		}else {
			_trackSpeedLabel.text= [NSString stringWithFormat:@"%2.1f km/h", kmh];
		}
	}else{
		_trackSpeedLabel.text = [NSString stringWithFormat:@"0.0 %@",[SettingsManager sharedInstance].routeUnitisMiles ? @"mph" : @"kmh"];
	}
	
}



-(void)updateActionStateForTrip{
	
	if(_isRecordingTrack){
		
		[_actionButton setTitle:@"Finish" forState:UIControlStateNormal];
		
		[UIView animateWithDuration:0.4 animations:^{
			_actionView.backgroundColor=UIColorFromRGB(0xCB0000);
		}];
		
	}else{
		
		[_actionButton setTitle:@"Start" forState:UIControlStateNormal];
		
		[UIView animateWithDuration:0.4 animations:^{
			_actionView.backgroundColor=UIColorFromRGB(0x1B953E);
		}];
		
	}
	
}




-(void)resetTimer{
	
	if(_trackTimer!=nil){
		[_trackTimer invalidate];
		self.trackTimer=nil;
	}
	
}



#pragma mark - UIView methods

//
/***********************************************
 * @description			VIEW METHODS
 ***********************************************/
//

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.displaysConnectionErrors=NO;
	
	self.tripManager=[TripManager sharedInstance];
	
	[HCBackgroundLocationManager sharedInstance].delegate=self;
	
    [self createPersistentUI];
}


-(void)viewWillAppear:(BOOL)animated{
    
    [self createNonPersistentUI];
	
    
    [super viewWillAppear:animated];
}


-(void)createPersistentUI{
	
	
	[RMMapView class];
	[_mapView setDelegate:self];
	_mapView.showsUserLocation=YES;
	_mapView.zoom=15;
	_mapView.tileSource=[CycleStreets tileSource];
	
	
	
	UIButton *button=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 28,18)];
	[button setImage:[UIImage imageNamed:@"UIButtonBarCompose.png"] forState:UIControlStateNormal];
	[button addTarget:self action:@selector(didSelectPhotoWizardButton:) forControlEvents:UIControlEventTouchUpInside];
	UIBarButtonItem *barbutton=[[UIBarButtonItem alloc] initWithCustomView:button];
	[self.navigationItem setRightBarButtonItem:barbutton animated:NO];
	
	
	[self updateUIForSpeed];
	[self updateUIForDistance];
	
	[_actionButton addTarget:self action:@selector(didSelectActionButton:) forControlEvents:UIControlEventTouchUpInside];
	
	
}


-(void)createNonPersistentUI{
    
	
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
		
}



#pragma mark - UI events


-(IBAction)didSelectActionButton:(id)sender{
	
	if(_isRecordingTrack == NO){
		
		
        BetterLog(@"start");
        
        // start the timer if needed
        if ( _trackTimer == nil ){
			
			[self updateUIForDuration];
			self.trackTimer = [NSTimer scheduledTimerWithTimeInterval:0.5f
													 target:self selector:@selector(updateUIForDuration)
												   userInfo:nil repeats:YES];
			_trackTimer.startDate=[NSDate date];
        }
        
       
        _isRecordingTrack = YES;
		self.currentTrip=[[TripManager sharedInstance] createTrip];
		[[TripManager sharedInstance] startTrip];
		
		_mapView.userTrackingMode=RMUserTrackingModeFollow;
		
		[self updateActionStateForTrip];
        
        // set flag to update counter
        _shouldUpdateDuration = YES;
		
		if(_currentLocation)
			[self didReceiveUpdatedLocations:@[_currentLocation]];
		
		
    }else {
		
		NSString *sheetTitle=EMPTYSTRING;
		
		BOOL doesTripContainUsefulData=[TripManager sharedInstance].doesTripContainUsefulData;
		
		if(!doesTripContainUsefulData)
			sheetTitle=@"This Route currently contains no locations,\r please Continue or Delete";
		
		__weak __typeof(&*self)weakSelf = self;
		UIActionSheet *actionSheet=[UIActionSheet bk_actionSheetWithTitle:sheetTitle];
		
		if(doesTripContainUsefulData==YES){
			[actionSheet bk_addButtonWithTitle:@"Finish" handler:^{
				[weakSelf didReceiveUpdatedLocations:@[_currentLocation]];
				[weakSelf initiateSaveTrip];
			}];
		}
		
		[actionSheet bk_setDestructiveButtonWithTitle:@"Delete" handler:^{
			[weakSelf resetRecordingInProgress];
			[[TripManager sharedInstance] removeCurrentRecordingTrip];
		}];
		
		
		[actionSheet bk_setCancelButtonWithTitle:@"Continue" handler:^{
		}];
		
		[actionSheet showInView:[[[UIApplication sharedApplication]delegate]window]];
		
    }
	
}





- (void)initiateSaveTrip{
	
	
	if ( _isRecordingTrack ){
		
		[self pauseTrip:YES];
		
		UINavigationController *nav=nil;
		
		if([[UserManager sharedInstance] hasUserData]){
			
			PickerViewController *tripPurposePickerView = [[PickerViewController alloc] initWithNibName:@"TripPurposePicker" bundle:nil];
			tripPurposePickerView.delegate=self;
			
			nav=[[UINavigationController alloc]initWithRootViewController:tripPurposePickerView];
			
		}else{
			
			HCSUserDetailsViewController *userController=[[HCSUserDetailsViewController alloc]initWithNibName:[HCSUserDetailsViewController nibName] bundle:nil];
			userController.tripDelegate=self;
			userController.viewMode=HCSUserDetailsViewModeSave;
			nav=[[UINavigationController alloc]initWithRootViewController:userController];
			
		}
		
		[self.navigationController presentViewController:nav animated:YES completion:^{
			
		}];
		
	}
    
}



-(void)dismissTripSaveController{
	
	[self.navigationController dismissModalViewControllerAnimated:YES];
	
}




-(IBAction)didSelectPhotoWizardButton:(id)sender{
	
	PhotoWizardViewController *photoWizard=[[PhotoWizardViewController alloc]initWithNibName:[PhotoWizardViewController nibName] bundle:nil];
	photoWizard.extendedLayoutIncludesOpaqueBars=NO;
	photoWizard.edgesForExtendedLayout = UIRectEdgeNone;
	photoWizard.isModal=YES;
	
	[self presentViewController:photoWizard animated:YES completion:^{
		
	}];
	
}






- (void)didCancelSaveJourneyController{
	
	[self.navigationController dismissModalViewControllerAnimated:YES];
    
	[self pauseTrip:NO];
	
}





#pragma mark - generic

//
/***********************************************
 * @description			MEMORY
 ***********************************************/
//
- (void)didReceiveMemoryWarning{
	
    [super didReceiveMemoryWarning];
    
}


@end
