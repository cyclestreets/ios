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
//  TripManager.h
//  CycleTracks
//
//  Copyright 2009-2010 SFCTA. All rights reserved.
//  Written by Matt Paul <mattpaul@mopimp.com> on 9/22/09.
//	For more information on the project, 
//	e-mail Billy Charlton at the SFCTA <billy.charlton@sfcta.org>


#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>
#import "TripPurposeDelegate.h"
#import "LoadingView.h"

#import "SynthesizeSingleton.h"


@class Trip;


@interface TripManager : NSObject < TripPurposeDelegate,UIAlertViewDelegate,UITextViewDelegate>
{
	
}

SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(TripManager)

@property (nonatomic,strong)  Trip								*currentRecordingTrip;
@property (nonatomic,strong,readonly)  Trip						*selectedTrip;


@property (nonatomic, assign) BOOL								isRecording;



- (Trip*)createTrip;
-(void)resetTrip;
-(void)startTrip;
-(void)deleteTrip:(Trip*)trip;

-(void)removeCurrentRecordingTrip;


- (CLLocationDistance)addCoord:(CLLocation*)location;
- (void)saveNotes:(NSString*)notes;
- (void)saveTrip;



- (int)countUnSavedTrips;
- (int)countUnSyncedTrips;
- (int)countZeroDistanceTrips;


- (int)recalculateTripDistances;
- (CLLocationDistance)calculateTripDistance:(Trip*)_trip;


-(void)uploadSelectedTrip:(Trip*)trip;
-(void)uploadCurrentReording:(Trip*)trip;
-(void)uploadAllUnsyncedTrips;

@end


@interface TripPurpose : NSObject { }

+ (unsigned int)getPurposeIndex:(NSString*)string;
+ (NSString *)getPurposeString:(unsigned int)index;

@end


