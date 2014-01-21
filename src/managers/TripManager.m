/** Cycle Atlanta, Copyright 2012, 2013 Georgia Institute of Technology
 *                                    Atlanta, GA. USA
 *
 *   @author Christopher Le Dantec <ledantec@gatech.edu>
 *   @author Anhong Guo <guoanhong@gatech.edu>
 *
 *   Updated/Modified for Atlanta's app deployment. Based on the
 *   CycleTracks codebase for SFCTA.
 *
 ** CycleTracks, Copyright 2009,2010 San Francisco County Transportation Authority
 *                                    San Francisco, CA, USA
 *
 *   @author Matt Paul <mattpaul@mopimp.com>
 *
 *   This file is part of CycleTracks.
 *
 *   CycleTracks is free software: you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as published by
 *   the Free Software Foundation, either version 3 of the License, or
 *   (at your option) any later version.
 *
 *   CycleTracks is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details.
 *
 *   You should have received a copy of the GNU General Public License
 *   along with CycleTracks.  If not, see <http://www.gnu.org/licenses/>.
 */

//
//  TripManager.m
//	CycleTracks
//
//  Copyright 2009-2010 SFCTA. All rights reserved.
//  Written by Matt Paul <mattpaul@mopimp.com> on 9/22/09.
//	For more information on the project, 
//	e-mail Billy Charlton at the SFCTA <billy.charlton@sfcta.org>


#import "constants.h"
#import "Coord.h"
#import "SaveRequest.h"
#import "Trip.h"
#import "TripManager.h"
#import "User.h"
#import "LoadingView.h"
#import "RecordTripViewController.h"

// use this epsilon for both real-time and post-processing distance calculations
#define kEpsilonAccuracy		100.0

// use these epsilons for real-time distance calculation only
#define kEpsilonTimeInterval	10.0
#define kEpsilonSpeed			30.0	// meters per sec = 67 mph

#define kSaveProtocolVersion_1	1
#define kSaveProtocolVersion_2	2
#define kSaveProtocolVersion_3	3

//#define kSaveProtocolVersion	kSaveProtocolVersion_1
//#define kSaveProtocolVersion	kSaveProtocolVersion_2
#define kSaveProtocolVersion	kSaveProtocolVersion_3

@implementation TripManager

@synthesize saving, tripNotes, tripNotesText;
@synthesize coords, dirty, trip, managedObjectContext, receivedData;
@synthesize uploadingView, parent;

- (id)initWithManagedObjectContext:(NSManagedObjectContext*)context
{
    if ( self = [super init] )
	{
		self.activityDelegate		= self;
		self.coords					= [[[NSMutableArray alloc] initWithCapacity:1000] autorelease];
		distance					= 0.0;
		self.managedObjectContext	= context;
		self.trip					= nil;
		purposeIndex				= -1;
    }
    return self;
}


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
		NSSortDescriptor *dateDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"recorded"
																		ascending:NO] autorelease];
		NSArray *sortDescriptors	= [NSArray arrayWithObjects:dateDescriptor, nil];
		self.coords					= [[[[_trip.coords allObjects] sortedArrayUsingDescriptors:sortDescriptors] mutableCopy] autorelease];
		
		//NSLog(@"loading %d coords completed.", [self.coords count]);

		// recalculate duration
		if ( coords && [coords count] > 1 )
		{
			Coord *last		= [coords objectAtIndex:0];
			Coord *first	= [coords lastObject];
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
        
		/*
		// recalculate trip distance
		CLLocationDistance newDist	= [self calculateTripDistance:_trip];
		
		NSLog(@"newDist: %f", newDist);
		NSLog(@"oldDist: %f", distance);
		*/
		
		// TODO: initialize purposeIndex from trip.purpose
		purposeIndex				= -1;
    }
    return YES;
}


- (id)initWithTrip:(Trip*)_trip
{
    if ( self = [super init] )
	{
		self.activityDelegate = self;
		[self loadTrip:_trip];
    }
    return self;
}


- (void)createTripNotesText
{
	tripNotesText = [[UITextView alloc] initWithFrame:CGRectMake( 12.0, 50.0, 260.0, 65.0 )];
	tripNotesText.delegate = self;
	tripNotesText.enablesReturnKeyAutomatically = NO;
	tripNotesText.font = [UIFont fontWithName:@"Arial" size:16];
	tripNotesText.keyboardAppearance = UIKeyboardAppearanceAlert;
	tripNotesText.keyboardType = UIKeyboardTypeDefault;
	tripNotesText.returnKeyType = UIReturnKeyDone;
	tripNotesText.text = kTripNotesPlaceholder;
	tripNotesText.textColor = [UIColor grayColor];
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


- (CLLocationDistance)distanceFrom:(Coord*)prev to:(Coord*)next realTime:(BOOL)realTime
{
	CLLocation *prevLoc = [[[CLLocation alloc] initWithLatitude:[prev.latitude doubleValue]
													 longitude:[prev.longitude doubleValue]] autorelease];
	CLLocation *nextLoc = [[[CLLocation alloc] initWithLatitude:[next.latitude doubleValue]
													 longitude:[next.longitude doubleValue]] autorelease];
	
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


- (CLLocationDistance)addCoord:(CLLocation *)location
{
	NSLog(@"addCoord");
	
	if ( !trip )
		[self createTrip];	

	// Create and configure a new instance of the Coord entity
	Coord *coord = (Coord *)[NSEntityDescription insertNewObjectForEntityForName:@"Coord" inManagedObjectContext:managedObjectContext];
	
	[coord setAltitude:[NSNumber numberWithDouble:location.altitude]];
	[coord setLatitude:[NSNumber numberWithDouble:location.coordinate.latitude]];
	[coord setLongitude:[NSNumber numberWithDouble:location.coordinate.longitude]];
	
	// NOTE: location.timestamp is a constant value on Simulator
	//[coord setRecorded:[NSDate date]];
	[coord setRecorded:location.timestamp];
	
	[coord setSpeed:[NSNumber numberWithDouble:location.speed]];
	[coord setHAccuracy:[NSNumber numberWithDouble:location.horizontalAccuracy]];
	[coord setVAccuracy:[NSNumber numberWithDouble:location.verticalAccuracy]];
	
	[trip addCoordsObject:coord];
	//[coord setTrip:trip];

	// check to see if the coords array is empty
	if ( [coords count] == 0 )
	{
		NSLog(@"updated trip start time");
		// this is the first coord of a new trip => update start
		[trip setStart:[coord recorded]];
		dirty = YES;
	}
	else
	{
		// update distance estimate by tabulating deltaDist with a low tolerance for noise
		Coord *prev  = [coords objectAtIndex:0];
		distance	+= [self distanceFrom:prev to:coord realTime:YES];
		[trip setDistance:[NSNumber numberWithDouble:distance]];
		
		// update duration
		Coord *first	= [coords lastObject];
		NSTimeInterval duration = [coord.recorded timeIntervalSinceDate:first.recorded];
		[trip setDuration:[NSNumber numberWithDouble:duration]];
		
	}
	
	NSError *error;
	if (![managedObjectContext save:&error]) {
		// Handle the error.
		NSLog(@"TripManager addCoord error %@, %@", error, [error localizedDescription]);
	}

	[coords insertObject:coord atIndex:0];
	//NSLog(@"# coords = %d", [coords count]);
	
	return distance;
}


- (CLLocationDistance)getDistanceEstimate
{
	return distance;
}


- (NSDictionary*)encodeUserData
{
	NSLog(@"encodeUserData");
	NSMutableDictionary *userDict = [NSMutableDictionary dictionaryWithCapacity:7];
	
	NSFetchRequest		*request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:managedObjectContext];
	[request setEntity:entity];
	
	NSError *error;
	NSInteger count = [managedObjectContext countForFetchRequest:request error:&error];
	//NSLog(@"saved user count  = %d", count);
	
	if ( count )
	{
		NSMutableArray *mutableFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
		if (mutableFetchResults == nil) {
			// Handle the error.
			NSLog(@"no saved user");
			if ( error != nil )
				NSLog(@"TripManager fetch saved user data error %@, %@", error, [error localizedDescription]);
		}
        
        NSString *appVersion = [NSString stringWithFormat:@"%@ (%@) on iOS %@",
                                [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"],
                                [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"],
                                [[UIDevice currentDevice] systemVersion]];
        
		User *user = [mutableFetchResults objectAtIndex:0];
		if ( user != nil )
		{
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
		}
		else
			NSLog(@"TripManager fetch user FAIL");
		
		[mutableFetchResults release];
	}
	else
		NSLog(@"TripManager WARNING no saved user data to encode");
	
	[request release];
    return userDict;
}


- (void)saveNotes:(NSString*)notes
{
	if ( trip && notes )
		[trip setNotes:notes];
}


- (void)saveTrip
{
	NSLog(@"about to save trip with %d coords...", [coords count]);
//	[activityDelegate updateSavingMessage:kPreparingData];
	//NSLog(@"%@", trip);

	// close out Trip record
	// NOTE: this code assumes we're saving the current recording in progress
	
	/* TODO: revise to work with following edge cases:
	 o coords unsorted
	 o break in recording => can't calc duration by comparing first & last timestamp,
	   incrementally tally delta time if < epsilon instead
	 o recalculate distance
	 */
	if ( trip && [coords count] )
	{
		CLLocationDistance newDist = [self calculateTripDistance:trip];
		NSLog(@"real-time distance = %.0fm", distance);
		NSLog(@"post-processing    = %.0fm", newDist);
		
		distance = newDist;
		[trip setDistance:[NSNumber numberWithDouble:distance]];
		
		Coord *last		= [coords objectAtIndex:0];
		Coord *first	= [coords lastObject];
		NSTimeInterval duration = [last.recorded timeIntervalSinceDate:first.recorded];
		NSLog(@"duration = %.0fs", duration);
		[trip setDuration:[NSNumber numberWithDouble:duration]];
	}
	
	[trip setSaved:[NSDate date]];
	
	NSError *error;
	if (![managedObjectContext save:&error])
	{
		// Handle the error.
		NSLog(@"TripManager setSaved error %@, %@", error, [error localizedDescription]);
	}
	else
		NSLog(@"Saved trip: %@ (%.0fm, %.0fs)", trip.purpose, [trip.distance doubleValue], [trip.duration doubleValue]);

	dirty = YES;
	
	// get array of coords
	NSMutableDictionary *tripDict = [NSMutableDictionary dictionaryWithCapacity:[coords count]];
	NSEnumerator *enumerator = [coords objectEnumerator];
	Coord *coord;
	
	// format date as a string
	NSDateFormatter *outputFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[outputFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];

#if kSaveProtocolVersion == kSaveProtocolVersion_3
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
#elif kSaveProtocolVersion == kSaveProtocolVersion_2
	NSLog(@"saving using protocol version 2");
	
	// create a tripDict entry for each coord
	while (coord = [enumerator nextObject])
	{
		NSMutableDictionary *coordsDict = [NSMutableDictionary dictionaryWithCapacity:7];
		[coordsDict setValue:coord.altitude  forKey:@"alt"];
		[coordsDict setValue:coord.latitude  forKey:@"lat"];
		[coordsDict setValue:coord.longitude forKey:@"lon"];
		[coordsDict setValue:coord.speed     forKey:@"spd"];
		[coordsDict setValue:coord.hAccuracy forKey:@"hac"];
		[coordsDict setValue:coord.vAccuracy forKey:@"vac"];
		
		NSString *newDateString = [outputFormatter stringFromDate:coord.recorded];
		[coordsDict setValue:newDateString forKey:@"rec"];
		[tripDict setValue:coordsDict forKey:newDateString];
	}
#else
	NSLog(@"saving using protocol version 1");
	
	// create a tripDict entry for each coord
	while (coord = [enumerator nextObject])
	{
		NSMutableDictionary *coordsDict = [NSMutableDictionary dictionaryWithCapacity:7];
		[coordsDict setValue:coord.altitude  forKey:@"altitude"];
		[coordsDict setValue:coord.latitude  forKey:@"latitude"];
		[coordsDict setValue:coord.longitude forKey:@"longitude"];
		[coordsDict setValue:coord.speed     forKey:@"speed"];
		[coordsDict setValue:coord.hAccuracy forKey:@"hAccuracy"];
		[coordsDict setValue:coord.vAccuracy forKey:@"vAccuracy"];
		
		NSString *newDateString = [outputFormatter stringFromDate:coord.recorded];
		[coordsDict setValue:newDateString forKey:@"recorded"];		
		[tripDict setValue:coordsDict forKey:newDateString];
	}    
#endif
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
	NSLog(@"start: %@", start);

	// encode user data
	NSDictionary *userDict = [self encodeUserData];
    
    // JSON encode user data and trip data, return to strings
    NSError *writeError = nil;
    // JSON encode user data
    NSData *userJsonData = [NSJSONSerialization dataWithJSONObject:userDict options:0 error:&writeError];
    NSString *userJson = [[[NSString alloc] initWithData:userJsonData encoding:NSUTF8StringEncoding] autorelease];
    NSLog(@"user data %@", userJson);
    
    // JSON encode the trip data
    NSData *tripJsonData = [NSJSONSerialization dataWithJSONObject:tripDict options:0 error:&writeError];
    NSString *tripJson = [[[NSString alloc] initWithData:tripJsonData encoding:NSUTF8StringEncoding] autorelease];
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
	// create save request
	SaveRequest *saveRequest = [[[SaveRequest alloc] initWithPostVars:postVars with:3 image:NULL] autorelease];
	
	// create the connection with the request and start loading the data
	NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:[saveRequest request] delegate:self];
	// create loading view to indicate trip is being uploaded
    uploadingView = [[LoadingView loadingViewInView:parent.parentViewController.view messageString:kSavingTitle] retain];

    //switch to map w/ trip view
    [parent displayUploadedTripMap];
    
    //TODO: get screenshot and store.

    if ( theConnection )
     {
         receivedData=[[NSMutableData data] retain];
     }
     else
     {
         // inform the user that the download could not be made
     
     }
    
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
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{	
    // append the new data to the receivedData	
    // receivedData is declared as a method instance elsewhere
	[receivedData appendData:data];	
//	[activityDelegate startAnimating];
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
    // release the connection, and the data object	
    [connection release];
	
    // receivedData is declared as a method instance elsewhere
    [receivedData release];
    
    // TODO: is this really adequate...?
    [uploadingView loadingComplete:kConnectionError delayInterval:1.5];
    
    // inform the user
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	// do something with the data
    NSLog(@"+++++++DEBUG: Received %d bytes of data", [receivedData length]);
	NSLog(@"%@", [[[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding] autorelease] );

    // release the connection, and the data object
    [connection release];
    [receivedData release];	
}


- (NSInteger)getPurposeIndex
{
	NSLog(@"%d", purposeIndex);
	return purposeIndex;
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
	purposeIndex = index;
	
	if ( trip )
	{
		[trip setPurpose:purpose];
		
		NSError *error;
		if (![managedObjectContext save:&error]) {
			// Handle the error.
			NSLog(@"setPurpose error %@, %@", error, [error localizedDescription]);
		}
	}
	else
		[self createTrip:index];

	dirty = YES;
	return purpose;
}


- (void)createTrip
{
	NSLog(@"createTrip");
	
	// Create and configure a new instance of the Trip entity
	trip = (Trip *)[[NSEntityDescription insertNewObjectForEntityForName:@"Trip" 
												  inManagedObjectContext:managedObjectContext] retain];
	[trip setStart:[NSDate date]];
	
	NSError *error;
	if (![managedObjectContext save:&error]) {
		// Handle the error.
		NSLog(@"createTrip error %@, %@", error, [error localizedDescription]);
	}
}


// DEPRECATED
- (void)createTrip:(unsigned int)index
{
	NSString *purpose = [self getPurposeString:index];
	NSLog(@"createTrip: %@", purpose);
	
	// Create and configure a new instance of the Trip entity
	trip = (Trip *)[[NSEntityDescription insertNewObjectForEntityForName:@"Trip" 
												  inManagedObjectContext:managedObjectContext] retain];
	
	[trip setPurpose:purpose];
	[trip setStart:[NSDate date]];
	
	NSError *error;
	if (![managedObjectContext save:&error]) {
		// Handle the error.
		NSLog(@"createTrip error %@, %@", error, [error localizedDescription]);
	}
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
	if ( saving )
		[saving dismissWithClickedButtonIndex:0 animated:YES];
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
	if ( saving )
		saving.message = [NSString stringWithFormat:@"Sent %d of %d bytes", totalBytesWritten, totalBytesExpectedToWrite];
}


- (void)updateSavingMessage:(NSString *)message
{
	if ( saving )
		saving.message = message;
}


#pragma mark methods to allow continuing a previously interrupted recording


// count trips that have not yet been saved
- (int)countUnSavedTrips
{
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Trip" inManagedObjectContext:managedObjectContext];
	[request setEntity:entity];
	
	// configure sort order
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"start" ascending:NO];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	[request setSortDescriptors:sortDescriptors];
	[sortDescriptors release];
	[sortDescriptor release];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"saved = nil"];
	[request setPredicate:predicate];
	
	NSError *error;
	NSInteger count = [managedObjectContext countForFetchRequest:request error:&error];
	NSLog(@"countUnSavedTrips = %d", count);
	
	[request release];
	return count;
}

// count trips that have been saved but not uploaded
- (int)countUnSyncedTrips
{
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Trip" inManagedObjectContext:managedObjectContext];
	[request setEntity:entity];
	
	// configure sort order
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"start" ascending:NO];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	[request setSortDescriptors:sortDescriptors];
	[sortDescriptors release];
	[sortDescriptor release];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"saved != nil AND uploaded = nil"];
	[request setPredicate:predicate];
	
	NSError *error;
	NSInteger count = [managedObjectContext countForFetchRequest:request error:&error];
	NSLog(@"countUnSyncedTrips = %d", count);
	
	[request release];
	return count;
}

// count trips that have been saved but have zero distance
- (int)countZeroDistanceTrips
{
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Trip" inManagedObjectContext:managedObjectContext];
	[request setEntity:entity];
	
	// configure sort order
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"start" ascending:NO];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	[request setSortDescriptors:sortDescriptors];
	[sortDescriptors release];
	[sortDescriptor release];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"saved != nil AND distance < 0.1"];
	[request setPredicate:predicate];
	
	NSError *error;
	NSInteger count = [managedObjectContext countForFetchRequest:request error:&error];
	NSLog(@"countZeroDistanceTrips = %d", count);
	
	[request release];
	return count;
}

- (BOOL)loadMostRecetUnSavedTrip
{
	BOOL success = NO;
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Trip" inManagedObjectContext:managedObjectContext];
	[request setEntity:entity];
	
	// configure sort order
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"start" ascending:NO];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	[request setSortDescriptors:sortDescriptors];
	[sortDescriptors release];
	[sortDescriptor release];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"saved = nil"];
	[request setPredicate:predicate];
	
	NSError *error;
	NSMutableArray *mutableFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
	if (mutableFetchResults == nil) {
		// Handle the error.
		NSLog(@"no UNSAVED trips");
		if ( error != nil )
			NSLog(@"Unresolved error2 %@, %@", error, [error userInfo]);
	}
	else if ( [mutableFetchResults count] )
	{
		NSLog(@"UNSAVED trip(s) found");

		// NOTE: this will sort the trip's coords and make it ready to continue recording
		success = [self loadTrip:[mutableFetchResults objectAtIndex:0]];
	}
	
	[mutableFetchResults release];
	[request release];
	return success;
}


// filter and sort all trip coords before calculating distance in post-processing
- (CLLocationDistance)calculateTripDistance:(Trip*)_trip
{
	NSLog(@"calculateTripDistance for trip started %@ having %d coords", _trip.start, [_trip.coords count]);
	
	CLLocationDistance newDist = 0.;

	if ( _trip != trip )
		[self loadTrip:_trip];
	
	// filter coords by hAccuracy
	NSPredicate *filterByAccuracy	= [NSPredicate predicateWithFormat:@"hAccuracy < 100.0"];
	NSArray		*filteredCoords		= [[_trip.coords allObjects] filteredArrayUsingPredicate:filterByAccuracy];
	NSLog(@"count of filtered coords = %d", [filteredCoords count]);
	
	if ( [filteredCoords count] )
	{
		// sort filtered coords by recorded date
		NSSortDescriptor *sortByDate	= [[[NSSortDescriptor alloc] initWithKey:@"recorded" ascending:YES] autorelease];
		NSArray		*sortDescriptors	= [NSArray arrayWithObjects:sortByDate, nil];
		NSArray		*sortedCoords		= [filteredCoords sortedArrayUsingDescriptors:sortDescriptors];
		
		// step through each pair of neighboring coors and tally running distance estimate
		
		// NOTE: assumes ascending sort order by coord.recorded
		// TODO: rewrite to work with DESC order to avoid re-sorting to recalc
		for (int i=1; i < [sortedCoords count]; i++)
		{
			Coord *prev	 = [sortedCoords objectAtIndex:(i - 1)];
			Coord *next	 = [sortedCoords objectAtIndex:i];
			newDist	+= [self distanceFrom:prev to:next realTime:NO];
		}
	}
	
	NSLog(@"oldDist: %f => newDist: %f", distance, newDist);	
	return newDist;
}


- (int)recalculateTripDistances
{
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Trip" inManagedObjectContext:managedObjectContext];
	[request setEntity:entity];
	
	// configure sort order
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"start" ascending:NO];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	[request setSortDescriptors:sortDescriptors];
	[sortDescriptors release];
	[sortDescriptor release];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"saved != nil AND distance < 0.1"];
	[request setPredicate:predicate];
	
	NSError *error;
	NSMutableArray *mutableFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
	if (mutableFetchResults == nil) {
		// Handle the error.
		NSLog(@"no trips with zero distance found");
		if ( error != nil )
			NSLog(@"Unresolved error2 %@, %@", error, [error userInfo]);
	}
	int count = [mutableFetchResults count];

	NSLog(@"found %d trip(s) in need of distance recalcuation", count);

	for (Trip *_trip in mutableFetchResults)
	{
		CLLocationDistance newDist = [self calculateTripDistance:_trip];
		[_trip setDistance:[NSNumber numberWithDouble:newDist]];

		NSError *error;
		if (![managedObjectContext save:&error]) {
			// Handle the error.
			NSLog(@"TripManager addCoord error %@, %@", error, [error localizedDescription]);
		}
		break;
	}
	
	[mutableFetchResults release];
	[request release];
	
	return count;
}

-(void)dealloc
{
    self.activityDelegate = nil;
    self.alertDelegate = nil;
    self.activityIndicator = nil;
    self.uploadingView = nil;
    self.parent = nil;
    self.saving = nil;
    self.tripNotes = nil;
    self.tripNotesText = nil;
    self.dirty = nil;
    self.trip = nil;
    self.coords = nil;
    self.managedObjectContext = nil;
    self.receivedData = nil;
    
    [saving release];
    [tripNotes release];
    [tripNotesText release];
    [trip release];
    [coords release];
    [managedObjectContext release];
    [receivedData release];
    [_activityDelegate release];
    [_alertDelegate release];
    [_activityIndicator release];
    [uploadingView release];
    [parent release];
    
    [unSavedTrips release];
    [unSyncedTrips release];
    [zeroDistanceTrips release];
    
    [super dealloc];
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

