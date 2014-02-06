

#import "constants.h"
#import "Coord.h"
#import "SaveRequest.h"
#import "Trip.h"
#import "TripManager.h"
#import "User.h"
#import "LoadingView.h"
#import "HCSTrackConfigViewController.h"
#import "CycleStreets.h"
#import "AppConstants.h"
#import "GlobalUtilities.h"
#import <AFNetworking.h>
#import "CoreDataStore.h"
#import "ApplicationJSONParser.h"
#import "HudManager.h"
#import "CJSONOrderedSerializer.h"
#import "DataSourceManager.h"

// use this epsilon for both real-time and post-processing distance calculations
#define kEpsilonAccuracy		100.0

// use these epsilons for real-time distance calculation only
#define kEpsilonTimeInterval	10.0
#define kEpsilonSpeed			30.0	// meters per sec = 67 mph

#define kSaveProtocolVersion_1	1

#define kSaveProtocolVersion	kSaveProtocolVersion_1


@interface TripManager()

@property (nonatomic,strong,readwrite)  Trip									*selectedTrip;

@property (nonatomic,assign) CLLocationDistance									recordedDistance;

@property (nonatomic,strong)  NSNumberFormatter									*coordDecimalPlaceFormatter;


@end



@implementation TripManager
SYNTHESIZE_SINGLETON_FOR_CLASS(TripManager);




- (instancetype)init
{
	
    if (self = [super init]){
		
		_isRecording					= NO;
		
		
		self.coordDecimalPlaceFormatter = [[NSNumberFormatter alloc] init];
		[_coordDecimalPlaceFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
		[_coordDecimalPlaceFormatter setMaximumFractionDigits:5];
	}
	return self;

}


#pragma maek - Trip creation and deletetion

- (Trip*)createTrip
{
	NSLog(@"createTrip");
	
	if(_currentRecordingTrip==nil){
		
		// Create and configure a new instance of the Trip entity
		self.currentRecordingTrip=[Trip create];
		[_currentRecordingTrip setStart:[NSDate date]];
		
		self.recordedDistance=0.0;
		
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


-(void)removeCurrentRecordingTrip{
	
	[self resetTrip];
	self.currentRecordingTrip=nil;
	
}


-(void)deleteTrip:(Trip*)trip{
	
	[[CoreDataStore mainStore] removeEntity:trip];
	
}






#pragma mark - Trip note saving

// called if user adds note and press save in survey views
- (void)saveNotes:(NSString*)notes{
	if ( _currentRecordingTrip && notes )
		[_currentRecordingTrip setNotes:notes];
}


#pragma mark - Trip saving


-(void)completeTripAutomatically{
	
	[self saveTrip:YES];
	
}






// Saves current Recording Trip to CD
- (void)saveTrip:(BOOL)isBackgroundEvent{
	
	
	[self optimiseTrip:_currentRecordingTrip];
	
	if ( _currentRecordingTrip && [_currentRecordingTrip.coords count]>0 ){
		
		CLLocationDistance newDist = [self calculateTripDistance:_currentRecordingTrip];
		[_currentRecordingTrip setDistance:[NSNumber numberWithDouble:newDist]];
		
		Coord *last		= [_currentRecordingTrip.coords lastObject];
		Coord *first	= [_currentRecordingTrip.coords firstObject];
		NSTimeInterval duration = [last.recorded timeIntervalSinceDate:first.recorded];
		NSLog(@"duration = %.0fs", duration);
		[_currentRecordingTrip setDuration:[NSNumber numberWithDouble:duration]];
		
	}else{
		[_currentRecordingTrip setDuration:[NSNumber numberWithInt:0]];
		[_currentRecordingTrip setDistance:[NSNumber numberWithInt:0]];

	}
	
	[_currentRecordingTrip setSaved:[NSDate date]];
	
	[[CoreDataStore mainStore]save];
	
	if(isBackgroundEvent==NO){
		
		[self uploadSelectedTrip:_currentRecordingTrip];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:HCS_TRIPCOMPLETE object:nil];
		
	}else{
		
		[self removeCurrentRecordingTrip];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:HCS_TRIPCOMPLETE object:nil];
		
	}
	
}


// optimises the trip data, removes duplicates within range and removes low accuracy coords, as on the mapview
// by doin gthis here we ensure uplodaed and saved data match
// also it means when drawing the map, we don tneed to preprocess the points.
// One cavaet is that during dev, we can tweak map filtering as the points will have been culled.
-(void)optimiseTrip:(Trip*)trip{
	
	BetterLog(@"Pre optimisation %d coords...", [trip.coords count]);
	
	// remove inaccurate coords
	NSPredicate *filterByAccuracy	= [NSPredicate predicateWithFormat:@"hAccuracy < 50"];
	NSOrderedSet *filteredCoords		= [trip.coords filteredOrderedSetUsingPredicate:filterByAccuracy];
	
	BetterLog(@"filteredCoords %d coords...", [filteredCoords count]);
	
	Coord *previousCoord = nil;
	NSMutableArray *optimisedCoords = [[NSMutableArray alloc]init];
	
	// de-dupe coordinates
	// if there are only 2 use as is
	
	if(filteredCoords.count==2){
		
		for ( Coord *coord in filteredCoords )
				[optimisedCoords addObject:coord];
		
	}else{
		
		for ( Coord *coord in filteredCoords ){
		
			BOOL canPlotCoord=NO;
			if (previousCoord==nil){
				canPlotCoord=YES;
			}else{
				
				if(![coord.latitude  isEqualToNumber:previousCoord.latitude] && ![coord.longitude isEqualToNumber:previousCoord.longitude]){
					
					canPlotCoord=YES;
					
				}
				
			}
			
			if(canPlotCoord==YES){
				
				[optimisedCoords addObject:coord];
				
			}
			
		}
		
	}
	
	BetterLog(@"fully optimised %d coords...", [optimisedCoords count]);
	
	
	NSOrderedSet *newSet=[NSOrderedSet orderedSetWithArray:optimisedCoords];
	
	[trip addCoords:newSet];
	
	[[CoreDataStore mainStore] save];
	
}



#pragma mar - Trip uploading


-(void)uploadAllUnsyncedTrips{
	
	NSArray *unsyncedTrips=[self arrayofAllUnsyncedTrips];
	
	if(unsyncedTrips.count>0) {
		
		
		[[HudManager sharedInstance] showHudWithType:HUDWindowTypeDeterminateProgress withTitle:@"Uploading" andMessage:nil];
		
		int __block unsyncedCount=unsyncedTrips.count;
		int __block completeCount=0;
		for(Trip *trip in unsyncedTrips){
			
			[self uploadSelectedTrip:trip completion:^(BOOL result) {
				
				if(result==YES){
					completeCount--;
					
					[[HudManager sharedInstance] updateDeterminateHUD:completeCount/unsyncedCount];
				}
				
				if(completeCount==unsyncedCount){
					[[HudManager sharedInstance] showHudWithType:HUDWindowTypeSuccess withTitle:@"Complete" andMessage:nil];
					
					[[NSNotificationCenter defaultCenter] postNotificationName:RESPONSE_GPSUPLOADMULTI object:@{STATE: SUCCESS}];
				}
				
			}];
			
		}
		
	}
	
}


-(void)uploadSelectedTrip:(Trip*)trip completion:(CompletionBlock)completionBlock{
	
	
	// get array of coords
	NSMutableDictionary *tripDict = [NSMutableDictionary dictionaryWithCapacity:[trip.coords count]];
	NSEnumerator *enumerator = [trip.coords objectEnumerator];
	Coord *coord;
	
	// format date as a string
	NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
	[outputFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	
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
		
		//NSString *newDateString = [outputFormatter stringFromDate:coord.recorded];
		NSString *newDateString=[NSString stringWithFormat:@"%ld", (long)[coord.recorded timeIntervalSince1970]];
		[coordsDict setValue:newDateString forKey:@"r"];    //recorded timestamp
		[tripDict setValue:coordsDict forKey:newDateString];
	}
	
	
	// get trip purpose
	NSString *purpose;
	if ( trip.purpose )
		purpose = trip.purpose;
	else
		purpose = @"unknown";
	
	// get trip notes
	NSString *notes = @"";
	if ( trip.notes )
		notes = trip.notes;
	
	// get start date
	NSString *start = [outputFormatter stringFromDate:trip.start];
	
	
	// encode user data
	NSDictionary *userDict = [self encodeUserData];
    
    // JSON encode user data and trip data, return to strings
    NSError *writeError = nil;
    // JSON encode user data
    NSData *userJsonData = [NSJSONSerialization dataWithJSONObject:userDict options:0 error:&writeError];
    NSString *userJson = [[NSString alloc] initWithData:userJsonData encoding:NSUTF8StringEncoding];
	
    
    // JSON encode the trip data
    NSData *tripJsonData = [[CJSONOrderedSerializer serializer] serializeObject:tripDict error:&writeError];
    NSString *tripJson = [[NSString alloc] initWithData:tripJsonData encoding:NSUTF8StringEncoding];
    
	
	//@"userAge":user.age,
	//@"userGender":user.gender,
	
	// NOTE: device hash added by SaveRequest initWithPostVars
	NSDictionary *postVars = @{@"coords":tripJson,
							   @"purpose":purpose,
							   @"notes":notes,
							   @"start":start,
							   @"user":userJson,
							   @"username":EMPTYSTRING,
							   @"password":EMPTYSTRING,
							   @"device":[[[UIDevice currentDevice] identifierForVendor] UUIDString]};
	
	BetterLog(@"%@",postVars);
	
	
	AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
	NSDictionary *serviceDict=[[DataSourceManager sharedInstance] getServiceForType:HACKNEYTRIPUPLOAD];
	NSString *fullURL=[NSString stringWithFormat:@"%@?key=%@",serviceDict[REMOTEURL],[[CycleStreets sharedInstance] APIKey]];
	
    [manager POST:fullURL parameters:postVars success:^(AFHTTPRequestOperation *operation, id responseObject) {
		
        
        [[ApplicationJSONParser sharedInstance] parseDataForResponseData:(NSMutableData *)responseObject forRequestType:GPSUPLOAD success:^(NetResponse *result) {
            
			//TODO: awaiting fix server side
			NSDictionary *responseDict=result.dataProvider;
			BOOL responseState=NO;
			NSString *errorMessage=nil;
			
			if(responseDict[[RESULT lowercaseString]]!=nil){
				responseState=[responseDict[[RESULT lowercaseString]] boolValue];
			}else if(responseDict[ERROR]!=nil){
				errorMessage=responseDict[ERROR];
			}
			
			
			switch (responseState) {
				case YES:
				{
					trip.uploaded=[NSDate date];
					
					[[CoreDataStore mainStore]save];
					
					[[NSNotificationCenter defaultCenter] postNotificationName:RESPONSE_GPSUPLOAD object:@{STATE: SUCCESS}];
				}
					break;
					
				default:
				{
					
					[[NSNotificationCenter defaultCenter] postNotificationName:RESPONSE_GPSUPLOAD object:@{STATE: ERROR,MESSAGE:errorMessage}];
					
				}
					
				break;
			}
			
			completionBlock(responseState);
            
        } failure:^(NetResponse *result, NSError *error) {
			
			BetterLog(@"%@",error.description);
            
			[[NSNotificationCenter defaultCenter] postNotificationName:RESPONSE_GPSUPLOAD object:@{STATE: ERROR}];
			
			completionBlock(NO);
            
        }];
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
		
        BetterLog(@"%@",error.debugDescription);
		
		completionBlock(NO);
        
    }];
	
	
}


-(void)uploadSelectedTrip:(Trip*)trip{
	
	[[HudManager sharedInstance] showHudWithType:HUDWindowTypeProgress withTitle:@"Uploading" andMessage:nil];
	
	[self uploadSelectedTrip:trip completion:^(BOOL result) {
		
		if(result==YES){
			[[HudManager sharedInstance]showHudWithType:HUDWindowTypeSuccess withTitle:@"Uploaded" andMessage:nil];
		}else{
			[[HudManager sharedInstance]showHudWithType:HUDWindowTypeError withTitle:@"Failed Upload" andMessage:@"Try later"];
		}
		
	}];
	
}

-(void)uploadCurrentReording:(Trip*)trip{
	
	[self uploadSelectedTrip:trip completion:^(BOOL result) {
		
		BetterLog(@"Background trip upload result: %i",result);
			
	}];
	
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
			[userDict setValue:user.gender          forKey:@"gender"];
			
			[userDict setValue:appVersion           forKey:@"app_version"];
			
		}else{
			NSLog(@"TripManager fetch user FAIL");
		}
		
		
	}else{
		NSLog(@"TripManager WARNING no saved user data to encode");
	}
	
	
    return userDict;
}




#pragma mark - TripPurposeDelegate methods


- (NSString *)getPurposeString:(unsigned int)index
{
	return [TripPurpose getPurposeString:index];
}


- (NSString *)setPurpose:(unsigned int)index
{
	NSString *purpose = [self getPurposeString:index];
	NSLog(@"setPurpose: %@", purpose);
	
	if ( _currentRecordingTrip ){
		
		[_currentRecordingTrip setPurpose:purpose];
		
		[[CoreDataStore mainStore]save];
	}
	

	return purpose;
}









#pragma mark - Trip predicate methods

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

// array of un uploaded trips
- (NSArray*)arrayofAllUnsyncedTrips{
	
	NSArray *trips=[Trip allForPredicate:[NSPredicate predicateWithFormat:@"saved != nil AND uploaded = nil"] orderBy:@"start" ascending:NO];
	
	return trips;
}




#pragma mark - Trip recording methods

// Create and configure a new instance of the Coord entity
- (CLLocationDistance)addCoord:(CLLocation *)location {
	
	BetterLog(@"");
	
	
	// reduce the fp of these numbers so route drawing can be filtered
	NSNumber *latNumber=[NSNumber numberWithDouble:location.coordinate.latitude];
	NSNumber *longNumber=[NSNumber numberWithDouble:location.coordinate.longitude];
	
	NSNumber *newlat=[NSNumber numberWithDouble:[[_coordDecimalPlaceFormatter stringFromNumber:latNumber] doubleValue]];
	NSNumber *newlongt=[NSNumber numberWithDouble:[[_coordDecimalPlaceFormatter stringFromNumber:longNumber] doubleValue]];
	//
	
	Coord *coord=[Coord create];
	
	[coord setAltitude:[NSNumber numberWithDouble:location.altitude]];
	[coord setLatitude:newlat];
	[coord setLongitude:newlongt];
	
	// NOTE: location.timestamp is a constant value on Simulator
	[coord setRecorded:location.timestamp];
	
	[coord setSpeed:[NSNumber numberWithDouble:location.speed]];
	[coord setHAccuracy:[NSNumber numberWithDouble:location.horizontalAccuracy]];
	[coord setVAccuracy:[NSNumber numberWithDouble:location.verticalAccuracy]];
	
	[_currentRecordingTrip addCoordsObject:coord];
	
	NSOrderedSet *recordingTripCoords=_currentRecordingTrip.coords;
	
	if ( [recordingTripCoords count] == 0 ){
		
		BetterLog(@"updated trip start time");
		// this is the first coord of a new trip => update start
		[_currentRecordingTrip setStart:[coord recorded]];
		
	}else{
		
		
		Coord *prev  = [recordingTripCoords objectAtIndex:[recordingTripCoords count]-1];
		_recordedDistance	+= [self distanceFrom:prev to:coord realTime:YES];
		[_currentRecordingTrip setDistance:[NSNumber numberWithDouble:_recordedDistance]];
		
		// update duration
		Coord *first	= [recordingTripCoords firstObject];
		NSTimeInterval duration = [coord.recorded timeIntervalSinceDate:first.recorded];
		
		[_currentRecordingTrip setDuration:[NSNumber numberWithDouble:duration]];
			
	}
	
	
	[[CoreDataStore mainStore]save];
	
	return _recordedDistance;
}




- (int)recalculateTripDistances{
	
	NSArray *trips=[Trip allForPredicate:[NSPredicate predicateWithFormat:@"saved != nil AND distance < 0.1"] orderBy:@"start" ascending:NO];
	
	if (trips == nil) {
		// Handle the error.
		NSLog(@"no trips with zero distance found");
	}
	
	int count = [trips count];
	NSLog(@"found %d trip(s) in need of distance recalcuation", count);

	for (Trip *trip in trips){
		
		CLLocationDistance newDist = [self calculateTripDistance:trip];
		[trip setDistance:[NSNumber numberWithDouble:newDist]];

		[[CoreDataStore mainStore]save];
		
	}
	
	return count;
}



- (CLLocationDistance)calculateTripDistance:(Trip*)trip{
	
	CLLocationDistance newDist = 0.;
	
	
	for (int i=1; i < [trip.coords count]; i++){
		
		Coord *prev	 = [trip.coords objectAtIndex:(i - 1)];
		Coord *next	 = [trip.coords objectAtIndex:i];
		newDist	+= [self distanceFrom:prev to:next realTime:NO];
		
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
	if ( [prev.hAccuracy doubleValue] < kEpsilonAccuracy && [next.hAccuracy doubleValue] < kEpsilonAccuracy ){
		
		// sanity check time interval
		if ( !realTime || deltaTime < kEpsilonTimeInterval ){
			
			// sanity check speed
			if ( !realTime || (deltaDist / deltaTime < kEpsilonSpeed) ){
				// consider distance delta as valid
				newDist += deltaDist;
				
			}else{
				
				NSLog(@"WARNING speed exceeds limit: %f => throw out deltaDist: %f, deltaTime: %f",  deltaDist / deltaTime, deltaDist, deltaTime);
				
			}
			
		}else{
			
			NSLog(@"WARNING deltaTime exceeds limit: %f => throw out deltaDist: %f", deltaTime, deltaDist);
		}
		
	}else{
		
		NSLog(@"WARNING accuracy exceeds limit: %f => throw out deltaDist: %f", MAX([prev.hAccuracy doubleValue], [next.hAccuracy doubleValue]) , deltaDist);
		
	}
	
	return newDist;
}






@end


#pragma mark - TripPurpose


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

