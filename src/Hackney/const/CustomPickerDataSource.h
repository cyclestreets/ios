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
//  CustomPickerDataSource.h
//  CycleTracks
//
//  Copyright 2009-2010 SFCTA. All rights reserved.
//  Written by Matt Paul <mattpaul@mopimp.com> on 9/22/09.
//	For more information on the project, 
//	e-mail Billy Charlton at the SFCTA <billy.charlton@sfcta.org>

// Trip Purpose descriptions
#define kDescCommute	@"The primary reason for this bike trip is to get between home and your primary work location."
#define kDescSchool		@"The primary reason for this bike trip is to go to or from school or college."
#define kDescWork		@"The primary reason for this bike trip is to go to or from business-related meeting, function, or work-related errand for your job."
#define kDescExercise	@"The primary reason for this bike trip is exercise or biking for the sake of biking."
#define kDescSocial		@"The primary reason for this bike trip is going to or from a social activity (e.g. at a friend's house, the park, a restaurant, the movies)."
#define kDescShopping	@"The primary reason for this bike trip is to purchase or bring home goods or groceries."
#define kDescErrand		@"The primary reason for this bike trip is to attend to personal business such as banking, doctor visit, going to the gym, etc."
#define kDescOther		@"If none of the other reasons apply to this trip, you can enter trip comments after saving your trip to tell us more."

// Issue descriptions
#define kIssueDescPavementIssue  @"Here’s a spot where the road needs to be repaired (pothole, rough concrete, gravel in the road, manhole cover, sewer grate)."
#define kIssueDescTrafficSignal  @"Here’s a signal that you can’t activate with your bike."
#define kIssueDescEnforcement    @"The bike lane is always blocked here, cars disobey \"no right on red\"… anything where the cops can help make cycling safer."
#define kIssueDescNeedParking    @"You need a bike rack to secure your bike here."
#define kIssueDescBikeLaneIssue  @"Where the bike lane ends (abruptly) or is too narrow (pesky parked cars)."
#define kIssueDescNoteThisSpot   @"Anything else ripe for improvement: want a sharrow, a sign, a bike lane? Share the details."

#define kDescNoteThis   @"Anything about this spot?"

// Asset descriptions
#define kAssetDescBikeParking   @"Park them here and remember to secure your bike well! Please only include racks or other objects intended for bikes."
#define kAssetDescBikeShops @"Have a flat, a broken chain, or spongy brakes? Or do you need a bike to jump into this world of cycling in the first place? Here's a shop ready to help."
#define kAssetDescPublicRestrooms   @"Help us make cycling mainstream… here’s a place to refresh yourself before you re-enter the fashionable world of Atlanta."
#define kAssetDescSecretPassage @"Here's an access point under the tracks, through the park, onto a trail, or over a ravine."
#define kAssetDescWaterFountains    @"Here’s a spot to fill your bottle on those hot summer days… stay hydrated, people. We need you."
#define kAssetDescNoteThisSpot  @"Anything else we should map to help your fellow cyclists? Share the details."


@interface CustomPickerDataSource : NSObject <UIPickerViewDataSource, UIPickerViewDelegate>
{
	NSArray	*customPickerArray;
	id<UIPickerViewDelegate> parent;
    NSInteger pickerCategory;
}

@property (nonatomic, retain) NSArray *customPickerArray;
@property (nonatomic, retain) id<UIPickerViewDelegate> parent;

@end
