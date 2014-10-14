//
//  SavedLocationsViewController.h
//  CycleStreets
//
//  Created by Neil Edwards on 14/10/2014.
//  Copyright (c) 2014 CycleStreets Ltd. All rights reserved.
//

#import "SuperViewController.h"

#import "CSOverlayTransitionAnimator.h"

@class SavedLocationVO;

@protocol SavedLocationsViewDelegate <NSObject>

@optional
-(void)didSelectSaveLocation:(SavedLocationVO*)location;

@end

typedef NS_ENUM(NSUInteger, SavedLocationsViewMode) {
	SavedLocationsViewModeDefault,
	SavedLocationsViewModeModal
	
};

@interface SavedLocationsViewController : SuperViewController<CSOverlayTransitionProtocol>

@property (nonatomic,assign)  SavedLocationsViewMode						viewMode;

@property (nonatomic,assign) id <SavedLocationsViewDelegate>				savedLocationdelegate;


-(void)didDismissWithTouch:(UITapGestureRecognizer*)gestureRecogniser;

-(CGSize)sizeToPresent;

@end
