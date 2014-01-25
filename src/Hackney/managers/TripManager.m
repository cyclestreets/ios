

#import "constants.h"
#import "Coord.h"
#import "SaveRequest.h"
#import "Trip.h"
#import "TripManager.h"
#import "User.h"
#import "LoadingView.h"
#import "HCSTrackConfigViewController.h"

#import "AppConstants.h"
#import "GlobalUtilities.h"

#import "CoreDataStore.h"

// use this epsilon for both real-time and post-processing distance calculations
#define kEpsilonAccuracy		100.0

// use these epsilons for real-time distance calculation only
#define kEpsilonTimeInterval	10.0
#define kEpsilonSpeed			30.0	// meters per sec = 67 mph

#define kSaveProtocolVersion_1	1
#define kSaveProtocolVersion_2	2
#define kSaveProtocolVersion_3	3

#define kSaveProtocolVersion	kSaveProtocolVersion_3


@interface TripManager()

@property (nonatomic,strong,readwrite)  Trip									*selectedTrip;

@property (nonatomic,strong)  NSMutableArray									*recordingTripCoords;


@end



@implementation TripManager
SYNTHESIZE_SINGLETON_FOR_CLASS(TripManager);




- (instancetype)init
{
	
    if (self = [super init]){
		self.activityDelegate		= self;
		_isRecording					= NO;
		self.recordingTripCoords=[NSMutableArray array];
	}
	return self;

}

- (Trip*)createTrip
{
	NSLog(@"createTrip");
	
	if(_currentRecordingTrip==nil){
		
		// Create and configure a new instance of the Trip entity
		self.currentRecordingTrip=[Trip create];
		[_currentRecordingTrip setStart:[NSDate date]];
		
		[[CoreDataStore mainStore] save];
		
	}
	
	return _currentRecordingTrip;
}

-(void)resetTrip{
	
	_isRecording = NO;
    [[NSUserDefaults standardUserDefaults] setBool:_isRecording forKey: @"recording"];
    [[NSUserDefaults standardUserDefaults] synchronize];
	
	
}

-(void)startTrip{
	
	_isRecording = YES;
    [[NSUserDefaults standardUserDefaults] setBool:_isRecording forKey: @"recording"];
    [[NSUserDefaults standardUserDefaults] synchronize];
	
	
}



-(void)loadSelectedTrip:(Trip*)trip{
	
	self.selectedTrip=trip;
	
	
	// need sorted array of coords for this trip
	
	// set duration of trip
	
	// save trip
	
	// purpose index?
	
}

/*
- (BOOL)loadTrip:(Trip*)_trip
{
    if ( _trip )
	{
		self.trip					= _trip;
		distance					= [_trip.distance doubleValue];
		self.managedObjectContext	= [_trip managedObjectContext];
		
		// NOTE: loading coords can be expensive for a large trip
		NSLog(@"loading %fm trip started at %@...", distance, _trip.start);

		// sort coords by recorded date DESCENDING so that the coord at index=0 is the most recent
		NSSortDescriptor *dateDescriptor = [[NSSortDescriptor alloc] initWithKey:@"recorded"
																	   ascending:NO];
		NSArray *sortDescriptors	= [NSArray arrayWithObjects:dateDescriptor, nil];
		self.coords					= [[[_trip.coords allObjects] sortedArrayUsingDescriptors:sortDescriptors] mutableCopy];
		
		//NSLog(@"loading %d coords completed.", [self.coords count]);

		// recalculate duration
		if ( coords && [Coord count] > 1 )
		{
			Coord *last		= [Coord objectAtIndex:0];
			Coord *first	= [Coord lastObject];
			NSTimeInterval duration = [last.recorded timeIntervalSinceDate:first.recorded];
			NSLog(@"duration = %.0fs", duration);
			[trip setDuration:[NSNumber numberWithDouble:duration]];
		}
		
		// save updated duration to CoreData
		NSError *error;
		if (![self.managedObjectContext save:&error]) {
			// Handle the error.
			NSLog(@"loadTrip error %@, %@", error, [error localizedDescription]);
            
		}
        
	
		// recalculate trip distance
		//CLLocationDistance newDist	= [self calculateTripDistance:_trip];
		
		//NSLog(@"newDist: %f", newDist);
		//NSLog(@"oldDist: %f", distance);
	
		
		// TODO: initialize purposeIndex from trip.purpose
		purposeIndex				= -1;
    }
    return YES;
}
*/


- (void)createTripNotesText
{
	_tripNotesText = [[UITextView alloc] initWithFrame:CGRectMake( 12.0, 50.0, 260.0, 65.0 )];
	_tripNotesText.delegate = self;
	_tripNotesText.enablesReturnKeyAutomatically = NO;
	_tripNotesText.font = [UIFont fontWithName:@"Arial" size:16];
	_tripNotesText.keyboardAppearance = UIKeyboardAppearanceAlert;
	_tripNotesText.keyboardType = UIKeyboardTypeDefault;
	_tripNotesText.returnKeyType = UIReturnKeyDone;
	_tripNotesText.text = kTripNotesPlaceholder;
	_tripNotesText.textColor = [UIColor grayColor];
}


#pragma mark UITextViewDelegate


- (void)textViewDidBeginEditing:(UITextView *)textView
{
	NSLog(@"textViewDidBeginEditing");
	
	if ( [textView.text compare:kTripNotesPlaceholder] == NSOrderedSame )
	{
		textView.text = @"";
		textView.textColor = [UIColor blackColor];
	}
}


- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
	NSLog(@"textViewShouldEndEditing: \"%@\"", textView.text);
	
	if ( [textView.text compare:@""] == NSOrderedSame )
	{
		textView.text = kTripNotesPlaceholder;
		textView.textColor = [UIColor grayColor];
	}
	
	return YES;
}


// this code makes the keyboard dismiss upon typing done / enter / return
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
	if ([text isEqualToString:@"\n"])
	{
		[textView resignFirstResponder];
		return NO;
	}
	
	return YES;
}




- (CLLocationDistance)getDistanceEstimate
{
	return [self calculateTripDistance:_currentRecordingTrip];
}


// converts UserVo to dictionary priot to sending to server as JSON
- (NSDictionary*)encodeUserData
{
	
	NSArray *users=[User allInStore:[CoreDataStore mainStore]];
	NSMutableDictionary *userDict=[NSMutableDictionary dictionary];
	
	if ( users.count>0 ){
		
		User *user = [users firstObject];
		
		      
        NSString *appVersion = [NSString stringWithFormat:@"%@ (%@) on iOS %@",
                                [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"],
                                [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"],
                                [[UIDevice currentDevice] systemVersion]];
        
		
		if ( user != nil ){
			
			// initialize text fields to saved personal info
			[userDict setValue:user.age             forKey:@"age"];
			[userDict setValue:user.email           forKey:@"email"];
			[userDict setValue:user.gender          forKey:@"gender"];
			[userDict setValue:user.homeZIP         forKey:@"homeZIP"];
			[userDict setValue:user.workZIP         forKey:@"workZIP"];
			[userDict setValue:user.schoolZIP       forKey:@"schoolZIP"];
			[userDict setValue:user.cyclingFreq     forKey:@"cyclingFreq"];
            [userDict setValue:user.ethnicity       forKey:@"ethnicity"];
            [userDict setValue:user.income          forKey:@"income"];
            [userDict setValue:user.rider_type      forKey:@"rider_type"];
            [userDict setValue:user.rider_history	forKey:@"rider_history"];
            [userDict setValue:appVersion           forKey:@"app_version"];
		}else{
			NSLog(@"TripManager fetch user FAIL");
		}
			
		
	}else{
		NSLog(@"TripManager WARNING no saved user data to encode");
	}
		
	
    return userDict;
}


// called if user adds note and press save in survey views
- (void)saveNotes:(NSString*)notes{
	if ( _currentRecordingTrip && notes )
		[_currentRecordingTrip setNotes:notes];
}

// save Trip to CoreDate then posts to server: should changed into a AF call
- (void)saveTrip
{
	NSLog(@"about to save trip with %d coords...", [_recordingTripCoords count]);

	if ( _currentRecordingTrip && [_recordingTripCoords count] )
	{
		CLLocationDistance newDist = [self calculateTripDistance:_currentRecordingTrip];
		
		[_currentRecordingTrip setDistance:[NSNumber numberWithDouble:newDist]];
		
		Coord *last		= [_recordingTripCoords objectAtIndex:0];
		Coord *first	= [_recordingTripCoords lastObject];
		NSTimeInterval duration = [last.recorded timeIntervalSinceDate:first.recorded];
		NSLog(@"duration = %.0fs", duration);
		[_currentRecordingTrip setDuration:[NSNumber numberWithDouble:duration]];
	}
	
	[_currentRecordingTrip setSaved:[NSDate date]];
	
	[[CoreDataStore mainStore]save];
	
	// get array of coords
	NSMutableDictionary *tripDict = [NSMutableDictionary dictionaryWithCapacity:[_recordingTripCoords count]];
	NSEnumerator *enumerator = [_recordingTripCoords objectEnumerator];
	Coord *coord;
	
	// format date as a string
	NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
	[outputFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];

    NSLog(@"saving using protocol version 3");
	
	// create a tripDict entry for each coord
	while (coord = [enumerator nextObject])
	{
		NSMutableDictionary *coordsDict = [NSMutableDictionary dictionaryWithCapacity:7];
		[coordsDict setValue:coord.altitude  forKey:@"a"];  //altitude
		[coordsDict setValue:coord.latitude  forKey:@"l"];  //latitude
		[coordsDict setValue:coord.longitude forKey:@"n"];  //longitude
		[coordsDict setValue:coord.speed     forKey:@"s"];  //speed
		[coordsDict setValue:coord.hAccuracy forKey:@"h"];  //haccuracy
		[coordsDict setValue:coord.vAccuracy forKey:@"v"];  //vaccuracy
		
		NSString *newDateString = [outputFormatter stringFromDate:coord.recorded];
		[coordsDict setValue:newDateString forKey:@"r"];    //recorded timestamp
		[tripDict setValue:coordsDict forKey:newDateString];
	}
	
	
	// get trip purpose
	NSString *purpose;
	if ( _currentRecordingTrip.purpose )
		purpose = _currentRecordingTrip.purpose;
	else
		purpose = @"unknown";
	
	// get trip notes
	NSString *notes = @"";
	if ( _currentRecordingTrip.notes )
		notes = _currentRecordingTrip.notes;
	
	// get start date
	NSString *start = [outputFormatter stringFromDate:_currentRecordingTrip.start];
	NSLog(@"start: %@", start);

	// encode user data
	NSDictionary *userDict = [self encodeUserData];
    
    // JSON encode user data and trip data, return to strings
    NSError *writeError = nil;
    // JSON encode user data
    NSData *userJsonData = [NSJSONSerialization dataWithJSONObject:userDict options:0 error:&writeError];
    NSString *userJson = [[NSString alloc] initWithData:userJsonData encoding:NSUTF8StringEncoding];
    NSLog(@"user data %@", userJson);
    
    // JSON encode the trip data
    NSData *tripJsonData = [NSJSONSerialization dataWithJSONObject:tripDict options:0 error:&writeError];
    NSString *tripJson = [[NSString alloc] initWithData:tripJsonData encoding:NSUTF8StringEncoding];
    //NSLog(@"trip data %@", tripJson);

        
	// NOTE: device hash added by SaveRequest initWithPostVars
	NSDictionary *postVars = [NSDictionary dictionaryWithObjectsAndKeys:
							  tripJson, @"coords",
							  purpose, @"purpose",
							  notes, @"notes",
							  start, @"start",
							  userJson, @"user",
                              
							  [NSString stringWithFormat:@"%d", kSaveProtocolVersion], @"version",
							  nil];
	
	
	//TODO: Send this dict to network controller
	
	//TODO:  send notification to display Map VC for current recording trip ie displayUploadedTripMap
	
	[[NSNotificationCenter defaultCenter] postNotificationName:HCSDISPLAYTRIPMAP object:nil];
}


#pragma mark NSURLConnection delegate methods


- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten 
 totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
	NSLog(@"%d bytesWritten, %d totalBytesWritten, %d totalBytesExpectedToWrite",
		  bytesWritten, totalBytesWritten, totalBytesExpectedToWrite );
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	
	/*
	// this method is called when the server has determined that it
    // has enough information to create the NSURLResponse
	NSLog(@"didReceiveResponse: %@", response);
	
	NSHTTPURLResponse *httpResponse = nil;
	if ( [response isKindOfClass:[NSHTTPURLResponse class]] &&
		( httpResponse = (NSHTTPURLResponse*)response ) )
	{
		BOOL success = NO;
		NSString *title   = nil;
		NSString *message = nil;
		switch ( [httpResponse statusCode] )
		{
			case 200:
			case 201:
				success = YES;
				title	= kSuccessTitle;
				message = kSaveSuccess;
				break;
			case 202:
				success = YES;
				title	= kSuccessTitle;
				message = kSaveAccepted;
				break;
			case 500:
			default:
				title = @"Internal Server Error";
				//message = [NSString stringWithFormat:@"%d", [httpResponse statusCode]];
				message = kServerError;
		}
		
		NSLog(@"%@: %@", title, message);
        
        //
        // DEBUG
        NSLog(@"+++++++DEBUG didReceiveResponse %@: %@", [response URL],[(NSHTTPURLResponse*)response allHeaderFields]);
        //
        //
		
		// update trip.uploaded 
		if ( success )
		{
			[trip setUploaded:[NSDate date]];
			
			NSError *error;
			if (![managedObjectContext save:&error]) {
				// Handle the error.
				NSLog(@"TripManager setUploaded error %@, %@", error, [error localizedDescription]);
			}
            
            [uploadingView loadingComplete:kSuccessTitle delayInterval:.7];
		} else {

            [uploadingView loadingComplete:kServerError delayInterval:1.5];
        }
        
	}
	
    // it can be called multiple times, for example in the case of a
	// redirect, so each time we reset the data.
	
    // receivedData is declared as a method instance elsewhere
    [receivedData setLength:0];
	 
	 */
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{	
//    // append the new data to the receivedData	
//    // receivedData is declared as a method instance elsewhere
//	[receivedData appendData:data];	
////	[activityDelegate startAnimating];
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
    
//    // TODO: is this really adequate...?
//    [uploadingView loadingComplete:kConnectionError delayInterval:1.5];
//    
//    // inform the user
//    NSLog(@"Connection failed! Error - %@ %@",
//          [error localizedDescription],
//          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	// do something with the data
//    NSLog(@"+++++++DEBUG: Received %d bytes of data", [receivedData length]);
//	NSLog(@"%@", [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding] );
	
}


- (NSInteger)getPurposeIndex
{
	//NSLog(@"%d", purposeIndex);
	return 0;
}


#pragma mark TripPurposeDelegate methods


- (NSString *)getPurposeString:(unsigned int)index
{
	return [TripPurpose getPurposeString:index];
}


- (NSString *)setPurpose:(unsigned int)index
{
	NSString *purpose = [self getPurposeString:index];
	NSLog(@"setPurpose: %@", purpose);
	
	if ( _currentRecordingTrip )
	{
		[_currentRecordingTrip setPurpose:purpose];
		
		[[CoreDataStore mainStore]save];
	}
	else
		[self createTrip:index];

	return purpose;
}





// DEPRECATED?
- (void)createTrip:(unsigned int)index
{
	NSString *purpose = [self getPurposeString:index];
	NSLog(@"createTrip: %@", purpose);
	
	
	self.currentRecordingTrip=(Trip*)[[CoreDataStore mainStore] createNewEntityByName:@"Trip"];
	[_currentRecordingTrip setPurpose:purpose];
	[_currentRecordingTrip setStart:[NSDate date]];
	
	[[CoreDataStore mainStore] save];
	
}


//- (void)promptForTripNotes
//{
//	tripNotes = [[UIAlertView alloc] initWithTitle:kTripNotesTitle
//										   message:@"\n\n\n"
//										  delegate:self
//								 cancelButtonTitle:@"Skip"
//								 otherButtonTitles:@"OK", nil];
//
//	[self createTripNotesText];
//	[tripNotes addSubview:tripNotesText];
//	[tripNotes show];
//    [self.tripNotesText becomeFirstResponder];
//	[tripNotes release];
//    NSLog(@"prompt for notes");
//}
//
//
//#pragma mark UIAlertViewDelegate methods
//
//
//- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
//{
//	// determine if we're processing tripNotes or saving alert
//	if ( alertView == tripNotes )
//	{
//		NSLog(@"tripNotes didDismissWithButtonIndex: %d", buttonIndex);
//		
//		// save trip notes
//		if ( buttonIndex == 1 )
//		{
//			if ( [tripNotesText.text compare:kTripNotesPlaceholder] != NSOrderedSame )
//			{
//				NSLog(@"saving trip notes: %@", tripNotesText.text);
//				[self saveNotes:tripNotesText.text];
//			}
//		}
//		
//		// save / upload trip
//        [self saveTrip];
//
//	}
//	
//	/*
//	else // alertView == saving
//	{
//		NSLog(@"saving didDismissWithButtonIndex: %d", buttonIndex);
//		
//		// reset button states
//		startButton.enabled = NO;
//		saveButton.enabled = NO;
//		lockButton.hidden = YES;
//		
//		// reset trip, reminder managers
//		NSManagedObjectContext *context = tripManager.managedObjectContext;
//		Trip *trip = tripManager.trip;
//		[self initTripManager:[[TripManager alloc] initWithManagedObjectContext:context]];
//		tripManager.dirty = YES;
//		
//		if ( reminderManager )
//		{
//			[reminderManager release];
//			reminderManager = nil;
//		}
//		
//		[self resetCounter];
//		[self resetPurpose];
//		
//		// load map view of saved trip
//		MapViewController *mvc = [[MapViewController alloc] initWithTrip:trip];
//		[[self navigationController] pushViewController:mvc animated:YES];
//		[mvc release];
//	}
//	 */
//}


#pragma mark ActivityIndicatorDelegate methods


- (void)dismissSaving
{
	if ( _saving )
		[_saving dismissWithClickedButtonIndex:0 animated:YES];
}


- (void)startAnimating {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)stopAnimating {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}


- (void)updateBytesWritten:(NSInteger)totalBytesWritten
 totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
	if ( _saving )
		_saving.message = [NSString stringWithFormat:@"Sent %d of %d bytes", totalBytesWritten, totalBytesExpectedToWrite];
}


- (void)updateSavingMessage:(NSString *)message
{
	if ( _saving )
		_saving.message = message;
}


#pragma mark methods to allow continuing a previously interrupted recording


// count trips that have not yet been saved
- (int)countUnSavedTrips{
	
	NSArray *trips=[Trip allForPredicate:[NSPredicate predicateWithFormat:@"saved = nil"] orderBy:@"start" ascending:NO];
	
	return trips.count;
}

// count trips that have been saved but not uploaded
- (int)countUnSyncedTrips{
	
	NSArray *trips=[Trip allForPredicate:[NSPredicate predicateWithFormat:@"saved != nil AND uploaded = nil"] orderBy:@"start" ascending:NO];
	
	return trips.count;
}

// count trips that have been saved but have zero distance
- (int)countZeroDistanceTrips{
	
	NSArray *trips=[Trip allForPredicate:[NSPredicate predicateWithFormat:@"saved != nil AND distance < 0.1"] orderBy:@"start" ascending:NO];
	
	return trips.count;
}

- (void)loadMostRecetUnSavedTrip
{
	
	NSArray *trips=[Trip allForPredicate:[NSPredicate predicateWithFormat:@"saved = nil"] orderBy:@"start" ascending:NO];
	
	if(trips.count==0){
		
		NSLog(@"no UNSAVED trips");
		
	}else{
		
		// weird shit with loading a trip my self
		// [self loadTrip:[mutableFetchResults objectAtIndex:0]]
		
	}
	
}



#pragma mark Trip helper methods

// Create and configure a new instance of the Coord entity
- (CLLocationDistance)addCoord:(CLLocation *)location {
	
	BetterLog(@"");
	
	Coord *coord=[Coord create];
	
	[coord setAltitude:[NSNumber numberWithDouble:location.altitude]];
	[coord setLatitude:[NSNumber numberWithDouble:location.coordinate.latitude]];
	[coord setLongitude:[NSNumber numberWithDouble:location.coordinate.longitude]];
	
	// NOTE: location.timestamp is a constant value on Simulator
	[coord setRecorded:location.timestamp];
	
	[coord setSpeed:[NSNumber numberWithDouble:location.speed]];
	[coord setHAccuracy:[NSNumber numberWithDouble:location.horizontalAccuracy]];
	[coord setVAccuracy:[NSNumber numberWithDouble:location.verticalAccuracy]];
	
	[_currentRecordingTrip addCoordsObject:coord];
	
	CLLocationDistance distance = 0.0;
	
	// check to see if the coords array is empty
	if ( [_recordingTripCoords count] == 0 )
	{
		BetterLog(@"updated trip start time");
		// this is the first coord of a new trip => update start
		[_currentRecordingTrip setStart:[coord recorded]];
	}
	else
	{
		// update distance estimate by tabulating deltaDist with a low tolerance for noise
		Coord *prev  = [_recordingTripCoords objectAtIndex:0];
		distance	+= [self distanceFrom:prev to:coord realTime:YES];
		[_currentRecordingTrip setDistance:[NSNumber numberWithDouble:distance]];
		
		// update duration
		Coord *first	= [_recordingTripCoords lastObject];
		NSTimeInterval duration = [coord.recorded timeIntervalSinceDate:first.recorded];
		
		[_currentRecordingTrip setDuration:[NSNumber numberWithDouble:duration]];
			
	}
	
	[_recordingTripCoords insertObject:coord atIndex:0];
	
	[[CoreDataStore mainStore]save];
	
	return distance;
}




- (int)recalculateTripDistances{
	
	NSArray *trips=[Trip allForPredicate:[NSPredicate predicateWithFormat:@"saved != nil AND distance < 0.1"] orderBy:@"start" ascending:NO];
	
	if (trips == nil) {
		// Handle the error.
		NSLog(@"no trips with zero distance found");
	}
	
	int count = [trips count];
	NSLog(@"found %d trip(s) in need of distance recalcuation", count);

	for (Trip *trip in trips)
	{
		CLLocationDistance newDist = [self calculateTripDistance:trip];
		[trip setDistance:[NSNumber numberWithDouble:newDist]];

		[[CoreDataStore mainStore]save];
		
	}
	
	return count;
}



- (CLLocationDistance)calculateTripDistance:(Trip*)trip{
	
	CLLocationDistance newDist = 0.;
	
	// filter coords by hAccuracy
	NSPredicate *filterByAccuracy	= [NSPredicate predicateWithFormat:@"hAccuracy < 100.0"];
	NSArray		*filteredCoords		= [[trip.coords allObjects] filteredArrayUsingPredicate:filterByAccuracy];
	NSLog(@"count of filtered coords = %d", [filteredCoords count]);
	
	if ( [filteredCoords count] )
	{
		// sort filtered coords by recorded date
		NSSortDescriptor *sortByDate	= [[NSSortDescriptor alloc] initWithKey:@"recorded" ascending:YES];
		NSArray		*sortDescriptors	= [NSArray arrayWithObjects:sortByDate, nil];
		NSArray		*sortedCoords		= [filteredCoords sortedArrayUsingDescriptors:sortDescriptors];
		
		// step through each pair of neighboring coors and tally running distance estimate
		
		// NOTE: assumes ascending sort order by coord.recorded
		// NOTE: rewrite to work with DESC order to avoid re-sorting to recalc
		for (int i=1; i < [sortedCoords count]; i++)
		{
			Coord *prev	 = [sortedCoords objectAtIndex:(i - 1)];
			Coord *next	 = [sortedCoords objectAtIndex:i];
			newDist	+= [self distanceFrom:prev to:next realTime:NO];
		}
	}
	
	return newDist;
}


- (CLLocationDistance)distanceFrom:(Coord*)prev to:(Coord*)next realTime:(BOOL)realTime
{
	CLLocation *prevLoc = [[CLLocation alloc] initWithLatitude:[prev.latitude doubleValue]
													 longitude:[prev.longitude doubleValue]];
	CLLocation *nextLoc = [[CLLocation alloc] initWithLatitude:[next.latitude doubleValue]
													 longitude:[next.longitude doubleValue]];
	
	CLLocationDistance	deltaDist	= [nextLoc distanceFromLocation:prevLoc];
	NSTimeInterval		deltaTime	= [next.recorded timeIntervalSinceDate:prev.recorded];
	CLLocationDistance	newDist		= 0.;
	
	// sanity check accuracy
	if ( [prev.hAccuracy doubleValue] < kEpsilonAccuracy &&
		[next.hAccuracy doubleValue] < kEpsilonAccuracy )
	{
		// sanity check time interval
		if ( !realTime || deltaTime < kEpsilonTimeInterval )
		{
			// sanity check speed
			if ( !realTime || (deltaDist / deltaTime < kEpsilonSpeed) )
			{
				// consider distance delta as valid
				newDist += deltaDist;
				
			}
			else
				NSLog(@"WARNING speed exceeds epsilon: %f => throw out deltaDist: %f, deltaTime: %f",
					  deltaDist / deltaTime, deltaDist, deltaTime);
		}
		else
			NSLog(@"WARNING deltaTime exceeds epsilon: %f => throw out deltaDist: %f", deltaTime, deltaDist);
	}
	else
		NSLog(@"WARNING accuracy exceeds epsilon: %f => throw out deltaDist: %f",
			  MAX([prev.hAccuracy doubleValue], [next.hAccuracy doubleValue]) , deltaDist);
	
	return newDist;
}





@end


@implementation TripPurpose

+ (unsigned int)getPurposeIndex:(NSString*)string
{
	if ( [string isEqualToString:kTripPurposeCommuteString] )
		return kTripPurposeCommute;
	else if ( [string isEqualToString:kTripPurposeSchoolString] )
		return kTripPurposeSchool;
	else if ( [string isEqualToString:kTripPurposeWorkString] )
		return kTripPurposeWork;
	else if ( [string isEqualToString:kTripPurposeExerciseString] )
		return kTripPurposeExercise;
	else if ( [string isEqualToString:kTripPurposeSocialString] )
		return kTripPurposeSocial;
	else if ( [string isEqualToString:kTripPurposeShoppingString] )
		return kTripPurposeShopping;
	else if ( [string isEqualToString:kTripPurposeErrandString] )
		return kTripPurposeErrand;
	//	else if ( [string isEqualToString:kTripPurposeOtherString] )
	else
		return kTripPurposeOther;
}

+ (NSString *)getPurposeString:(unsigned int)index
{
	switch (index) {
		case kTripPurposeCommute:
			return @"Commute";
			break;
		case kTripPurposeSchool:
			return @"School";
			break;
		case kTripPurposeWork:
			return @"Work-related";
			break;
		case kTripPurposeExercise:
			return @"Exercise";
			break;
		case kTripPurposeSocial:
			return @"Social";
			break;
		case kTripPurposeShopping:
			return @"Shopping";
			break;
		case kTripPurposeErrand:
			return @"Errand";
			break;
		case kTripPurposeOther:
		default:
			return @"Other";
			break;
	}
}

@end

