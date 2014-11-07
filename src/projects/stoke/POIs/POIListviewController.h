//
//  POIListviewController.h
//  CycleStreets
//
//  Created by Neil Edwards on 20/10/2011.
//  Copyright (c) 2011 CycleStreets Ltd. All rights reserved.
//

#import "SuperViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "CSOverlayTransitionAnimator.h"
#import "CSOverlayPushTransitionAnimator.h"

@class POICategoryVO;

typedef NS_ENUM(NSUInteger, POIListViewMode) {
	POIListViewMode_Map,
	POIListViewMode_Leisure
};


@protocol POIListViewDelegate <NSObject,SuperViewControllerDelegate>

@optional
-(void)didUpdateSelectedPOIs:(NSMutableArray*)poiArray;

@end


@interface POIListviewController : SuperViewController<UITableViewDelegate,UITableViewDataSource,CSOverlayTransitionProtocol,CSOverlayPushTransitionAnimatorProtocol>{
	
}

@property (nonatomic,assign)  POIListViewMode								viewMode;

@property (nonatomic, assign)	CLLocationCoordinate2D						nwCoordinate;
@property (nonatomic, assign)	CLLocationCoordinate2D						seCoordinate;

@property (nonatomic,assign)  id<POIListViewDelegate>						delegate;


@property (nonatomic,strong)  NSMutableArray								*selectedPOIArray;


@end
