//
//  HCSSavedTrackCellView.m
//  CycleStreets
//
//  Created by Neil Edwards on 23/01/2014.
//  Copyright (c) 2014 CycleStreets Ltd. All rights reserved.
//

#import "HCSSavedTrackCellView.h"
#import "GenericConstants.h"
#import "UIView+Additions.h"

#import "TripManager.h"
#import "Trip.h"

@interface HCSSavedTrackCellView()

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *purposeLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UILabel *calorieLabel;
@property (weak, nonatomic) IBOutlet UILabel *co2Label;
@property (weak, nonatomic) IBOutlet UIImageView *iconView;

@end


@implementation HCSSavedTrackCellView




-(void)initialise{
	
	
	
}



-(void)populate{
	
	
	_durationLabel.text=[_dataProvider durationString];
	
	_purposeLabel.text=_dataProvider.purpose;
	
	_co2Label.text=_dataProvider.co2SavedString;
	_calorieLabel.text=_dataProvider.caloriesUsedString;
	
	_dateLabel.text=_dataProvider.longdateString;
	
	[self configureIconView];
	
}


// if upload
-(void)configureIconView{
	
	UIImage	*image;
	
	if(_dataProvider.uploaded){
		
		int index = [TripPurpose getPurposeIndex:_dataProvider.purpose];
		
		
		// add purpose icon
		switch ( index ) {
			case kTripPurposeCommute:
				image = [UIImage imageNamed:kTripPurposeCommuteIcon];
				break;
			case kTripPurposeSchool:
				image = [UIImage imageNamed:kTripPurposeSchoolIcon];
				break;
			case kTripPurposeWork:
				image = [UIImage imageNamed:kTripPurposeWorkIcon];
				break;
			case kTripPurposeExercise:
				image = [UIImage imageNamed:kTripPurposeExerciseIcon];
				break;
			case kTripPurposeSocial:
				image = [UIImage imageNamed:kTripPurposeSocialIcon];
				break;
			case kTripPurposeShopping:
				image = [UIImage imageNamed:kTripPurposeShoppingIcon];
				break;
			case kTripPurposeErrand:
				image = [UIImage imageNamed:kTripPurposeErrandIcon];
				break;
			case kTripPurposeOther:
				image = [UIImage imageNamed:kTripPurposeOtherIcon];
				break;
			default:
				image = [UIImage imageNamed:@"GreenCheckMark2.png"];
		}
		
		
	}else if(_dataProvider.saved){
		
		image=[UIImage imageNamed:@"failedUpload.png"];
		
	}else{
		
		image=[UIImage imageNamed:@"failedUpload.png"];
		
	}
	
	
	_iconView.image=image;
	
}


+(int)rowHeight{
	return STANDARDCELLHEIGHT;
}







@end
