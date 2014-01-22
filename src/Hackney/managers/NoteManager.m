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
#import "SaveRequest.h"
#import "TripManager.h"
#import "User.h"
#import "Note.h"
#import "NoteManager.h"
#import "LoadingView.h"
#import "HCSTrackConfigViewController.h"
#import "AppDelegate.h"
#import "ImageResize.h"


#define kSaveNoteProtocolVersion	4

@implementation NoteManager

@synthesize note, managedObjectContext, receivedDataNoted;
@synthesize uploadingView, parent;
@synthesize deviceUniqueIdHash1;

// change initialization values

// change this function for note detail view

// change this function for note initialization

- (id)initWithManagedObjectContext:(NSManagedObjectContext*)context
{
    if ( self = [super init] )
	{
		self.managedObjectContext = context;
        self.activityDelegate = self;
        if (!note) {
            self.note = nil;
        }
        
    }
    return self;
}

- (void)createNote
{
	NSLog(@"createNote");
	
	// Create and configure a new instance of the Note entity
    self.note = (Note *)[NSEntityDescription insertNewObjectForEntityForName:@"Note" inManagedObjectContext:managedObjectContext];
    
    [note setRecorded:[NSDate date]];
    NSLog(@"Date: %@", note.recorded);
    
	NSError *error;
	if (![managedObjectContext save:&error]) {
		// Handle the error.
		NSLog(@"createNote error %@, %@", error, [error localizedDescription]);
	}
}


//called from RecordTripViewController
- (void)addLocation:(CLLocation *)locationNow
{
    NSLog(@"This is very very special!");
    
    if(!note){
        NSLog(@"Note nil");
    }
    
    [note setAltitude:[NSNumber numberWithDouble:locationNow.altitude]];
    NSLog(@"Altitude: %f", [note.altitude doubleValue]);
    
    [note setLatitude:[NSNumber numberWithDouble:locationNow.coordinate.latitude]];
    NSLog(@"Latitude: %f", [note.latitude doubleValue]);
    
    [note setLongitude:[NSNumber numberWithDouble:locationNow.coordinate.longitude]];
    NSLog(@"Longitude: %f", [note.longitude doubleValue]);
    
    [note setSpeed:[NSNumber numberWithDouble:locationNow.speed]];
    NSLog(@"Speed: %f", [note.speed doubleValue]);
    
    [note setHAccuracy:[NSNumber numberWithDouble:locationNow.horizontalAccuracy]];
    NSLog(@"HAccuracy: %f", [note.hAccuracy doubleValue]);
    
    [note setVAccuracy:[NSNumber numberWithDouble:locationNow.verticalAccuracy]];
    NSLog(@"VAccuracy: %f", [note.vAccuracy doubleValue]);
    
//    [note setRecorded:locationNow.timestamp];
//    NSLog(@"Date: %@", note.recorded);
	
	NSError *error;
	if (![managedObjectContext save:&error]) {
		// Handle the error.
		NSLog(@"Note addLocation error %@, %@", error, [error localizedDescription]);
	}
    
}

//called in DetailViewController once pressing skip or save
- (void)saveNote
{
    NSMutableDictionary *noteDict;
	
	// format date as a string
	NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
	[outputFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDateFormatter *outputFormatterURL = [[NSDateFormatter alloc] init];
	[outputFormatterURL setDateFormat:@"yyyy-MM-dd-HH-mm-ss"];
    
    NSLog(@"saving using protocol version 4");
	
    // create a noteDict for each note
    noteDict = [[NSMutableDictionary alloc] initWithCapacity:10];
    [noteDict setValue:note.altitude  forKey:@"a"];  //altitude
    [noteDict setValue:note.latitude  forKey:@"l"];  //latitude
    [noteDict setValue:note.longitude forKey:@"n"];  //longitude
    [noteDict setValue:note.speed     forKey:@"s"];  //speed
    [noteDict setValue:note.hAccuracy forKey:@"h"];  //haccuracy
    [noteDict setValue:note.vAccuracy forKey:@"v"];  //vaccuracy
    
    [noteDict setValue:note.note_type     forKey:@"t"];  //note_type
    [noteDict setValue:note.details forKey:@"d"];  //details
    
    NSString *newDateString = [outputFormatter stringFromDate:note.recorded];
    NSString *newDateStringURL = [outputFormatterURL stringFromDate:note.recorded];
    [noteDict setValue:newDateString forKey:@"r"];    //recorded timestamp
    
    self.deviceUniqueIdHash1 = [[UIDevice currentDevice]identifierForVendor];
    NSLog(@"deviceUniqueIdHash is %@", deviceUniqueIdHash1);
    
    //generated from userid, recordedtime and type
    
    if (note.image_data == nil) {
        note.image_url =@"";
    }
    else {
        note.image_url = [NSString stringWithFormat:@"%@-%@-type-%@",deviceUniqueIdHash1,newDateStringURL,note.note_type];
    }
    NSLog(@"img_url: %@", note.image_url);
    
    UIImage *castedImage = [[UIImage alloc] initWithData:note.image_data];
    
    CGSize size;
    if (castedImage.size.height > castedImage.size.width) {
        size.height = 640;
        size.width = 480;
    }
    else {
        size.height = 480;
        size.width = 640;
    }
    
    NSData *uploadData = [[NSData alloc] initWithData:UIImageJPEGRepresentation([ImageResize imageWithImage:castedImage scaledToSize:size], kJpegQuality)];
    
    NSLog(@"Size of Image(bytes):%d", [uploadData length]);
    
    [noteDict setValue:note.image_url forKey:@"i"];  //image_url
    //[noteDict setValue:note.image_data forKey:@"g"];  //image_data
        
    // JSON encode user data and trip data, return to strings
    NSError *writeError = nil;
    
    // JSON encode the Note data
    NSData *noteJsonData = [[NSData alloc] initWithData:[NSJSONSerialization dataWithJSONObject:noteDict options:0 error:&writeError]];
    
    NSString *noteJson = [[NSString alloc] initWithData:noteJsonData encoding:NSUTF8StringEncoding];
    
	// NOTE: device hash added by SaveRequest initWithPostVars
	NSDictionary *postVars = [NSDictionary dictionaryWithObjectsAndKeys: 
                              noteJson, @"note",
							  [NSString stringWithFormat:@"%d", kSaveNoteProtocolVersion], @"version",
//                              [NSData dataWithData:note.image_data], @"image_data",
							  nil];
	// create save request
	SaveRequest *saveRequest = [[SaveRequest alloc] initWithPostVars:postVars with:4 image:uploadData];
	
	// create the connection with the request and start loading the data
	NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:[saveRequest request] delegate:self];
	
    // create loading view to indicate trip is being uploaded
    self.uploadingView = [LoadingView loadingViewInView:parent.parentViewController.view messageString:kSavingNoteTitle];
    
    //switch to map w/ trip view
    
    NSInteger recording = [[NSUserDefaults standardUserDefaults] integerForKey:@"recording"];
    
    
    if (recording == 0) {
        [parent performSelector:@selector(displayUploadedNote) withObject:nil];
    }
    
    NSLog(@"note save and parent");
    
    if ( theConnection )
    {
        self.receivedDataNoted=[NSMutableData data];
    }
    else
    {
        // inform the user that the download could not be made
        
    }
    
    }


- (void)saveNote:(Note*)_note
{
    NSMutableDictionary *noteDict;
	
	// format date as a string
	NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
	[outputFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDateFormatter *outputFormatterURL = [[NSDateFormatter alloc] init];
	[outputFormatterURL setDateFormat:@"yyyy-MM-dd-HH-mm-ss"];
    
    NSLog(@"saving using protocol version 4");
	
    // create a noteDict for each note
    noteDict = [[NSMutableDictionary alloc] initWithCapacity:10];
    [noteDict setValue:_note.altitude  forKey:@"a"];  //altitude
    [noteDict setValue:_note.latitude  forKey:@"l"];  //latitude
    [noteDict setValue:_note.longitude forKey:@"n"];  //longitude
    [noteDict setValue:_note.speed     forKey:@"s"];  //speed
    [noteDict setValue:_note.hAccuracy forKey:@"h"];  //haccuracy
    [noteDict setValue:_note.vAccuracy forKey:@"v"];  //vaccuracy
    
    [noteDict setValue:_note.note_type     forKey:@"t"];  //note_type
    [noteDict setValue:_note.details forKey:@"d"];  //details
    
    NSString *newDateString = [outputFormatter stringFromDate:_note.recorded];
    NSString *newDateStringURL = [outputFormatterURL stringFromDate:_note.recorded];
    [noteDict setValue:newDateString forKey:@"r"];    //recorded timestamp
    
    self.deviceUniqueIdHash1 = [[UIDevice currentDevice]identifierForVendor];
    NSLog(@"deviceUniqueIdHash is %@", deviceUniqueIdHash1);
    
    //generated from userid, recordedtime and type
    
    if (_note.image_data == nil) {
        _note.image_url =@"";
    }
    else {
        _note.image_url = [NSString stringWithFormat:@"%@-%@-type-%@",deviceUniqueIdHash1,newDateStringURL,_note.note_type];
    }
    NSLog(@"note_type: %d", [_note.note_type intValue]);
    NSLog(@"img_url: %@", _note.image_url);
    NSLog(@"img_url: %@", _note.details);
    
    UIImage *castedImage = [[UIImage alloc] initWithData:_note.image_data];
    
    CGSize size;
    if (castedImage.size.height > castedImage.size.width) {
        size.height = 640;
        size.width = 480;
    }
    else {
        size.height = 480;
        size.width = 640;
    }
    
    NSData *uploadData = [[NSData alloc] initWithData:UIImageJPEGRepresentation([ImageResize imageWithImage:castedImage scaledToSize:size], kJpegQuality)];
    
    NSLog(@"Size of Image(bytes):%d", [uploadData length]);
    
    [noteDict setValue:_note.image_url forKey:@"i"];  //image_url
    //[noteDict setValue:note.image_data forKey:@"g"];  //image_data
    
    // JSON encode user data and trip data, return to strings
    NSError *writeError = nil;
    
    // JSON encode the Note data
    NSData *noteJsonData = [[NSData alloc] initWithData:[NSJSONSerialization dataWithJSONObject:noteDict options:0 error:&writeError]];
    
    NSString *noteJson = [[NSString alloc] initWithData:noteJsonData encoding:NSUTF8StringEncoding];
    
	// NOTE: device hash added by SaveRequest initWithPostVars
	NSDictionary *postVars = [NSDictionary dictionaryWithObjectsAndKeys:
                              noteJson, @"note",
							  [NSString stringWithFormat:@"%d", kSaveNoteProtocolVersion], @"version",
                              //                              [NSData dataWithData:note.image_data], @"image_data",
							  nil];
	// create save request
	SaveRequest *saveRequest = [[SaveRequest alloc] initWithPostVars:postVars with:4 image:uploadData];
	
	// create the connection with the request and start loading the data
	NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:[saveRequest request] delegate:self];
	
    // create loading view to indicate trip is being uploaded
    self.uploadingView = [LoadingView loadingViewInView:parent.parentViewController.view messageString:kSavingNoteTitle];
    
    //switch to map w/ trip view
    
    NSInteger recording = [[NSUserDefaults standardUserDefaults] integerForKey:@"recording"];
    
    
    if (recording == 0) {
        [parent performSelector:@selector(displayUploadedNote) withObject:nil];
    }
    
    NSLog(@"note save and parent");
    
    if ( theConnection )
    {
        self.receivedDataNoted=[NSMutableData data];
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
        
        if ( success )
		{
            [note setUploaded:[NSDate date]];
			
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
    [receivedDataNoted setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // append the new data to the receivedData
    // receivedData is declared as a method instance elsewhere
	[receivedDataNoted appendData:data];
    //	[activityDelegate startAnimating];
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
    // release the connecti
	
    
    // TODO: is this really adequate...?
    [uploadingView loadingComplete:kConnectionError delayInterval:1.5];
    
    // inform the user
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    
    
    //	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kConnectionError
    //													message:[error localizedDescription]
    //												   delegate:nil
    //										  cancelButtonTitle:@"OK"
    //										  otherButtonTitles:nil];
    //	[alert show];
    //	[alert release];
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	// do something with the data
    NSLog(@"+++++++DEBUG: Received %d bytes of data", [receivedDataNoted length]);
	//NSLog(@"%@", [[[NSString alloc] initWithData:receivedDataNoted encoding:NSUTF8StringEncoding] autorelease] );
    
}

- (id)initWithNote:(Note *)_note
{
    if ( self = [super init] )
	{
		self.activityDelegate = self;
		[self loadNote:_note];
    }
    return self;
}

- (BOOL)loadNote:(Note *)_note
{
    if ( _note )
	{
		self.note					= _note;
		self.managedObjectContext	= [_note managedObjectContext];
        
		// save updated duration to CoreData
		NSError *error;
		if (![self.managedObjectContext save:&error]) {
			// Handle the error.
			NSLog(@"loadNote error %@, %@", error, [error localizedDescription]);
            
		}
    }
    return YES;
}

- (void)dealloc {
    self.deviceUniqueIdHash1 = nil;
    self.activityDelegate = nil;
    self.alertDelegate = nil;
    self.activityIndicator = nil;
    self.uploadingView = nil;
    self.dirty = nil;
    self.note = nil;
    self.managedObjectContext = nil;
    self.receivedDataNoted = nil;
    
}


@end
