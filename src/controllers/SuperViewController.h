//
//  SuperViewController.h
//  CycleStreets
//
//  Created by Neil Edwards on 07/12/2009.
//  Copyright 2009 CycleStreets.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomNavigtionBar.h"
#import "GradientView.h"
#import <CoreLocation/CoreLocation.h>

@protocol SuperViewControllerDelegate <NSObject> 

@optional
-(void)doNavigationPush:(NSString*)className;
-(void)doNavigationPush:(NSString*)className withDataProvider:(id)data;
-(void)doNavigationPush:(NSString*)className withDataProvider:(id)data andIndex:(int)index;
-(void)dataProviderRequestRefresh:(NSString*)source;
-(void)dataProviderDidRefresh:(NSNotification*)notification;
-(void)addActivityIndicator;
-(void)removeActivityIndicator;
-(void)updateEditButtonState:(BOOL)state;
-(void)handleRemoteRequestIndication:(BOOL)show;
-(void)deSelectRowForTableView:(UITableView*)table;
-(void)doCellButtonSelection:(NSString*)type withDataProvider:(id)data andIndex:(int)index;

-(void)UserDidUpdatePhotoLocation:(CLLocation*)location;

@end

enum  {
	kViewOverlayTypeNone=0,
	kViewOverlayTypeDataRequestFailed=1,
	kViewOverlayTypeConnectionFailed=2,
	kViewOverlayTypeServerDown=3,
	kViewOverlayTypeLoginRestriction=4,
	kViewOverlayTypeNoResults=5,
	kViewOverlayTypeRequestIndicator=6,
};
typedef int ViewOverlayType;

@interface SuperViewController : UIViewController <CustomNavigationBarDelegate,SuperViewControllerDelegate>{
	
	CustomNavigtionBar					*navigation;
	CGRect								frame;
	id<SuperViewControllerDelegate>		__unsafe_unretained delegate;
	BOOL								appearWasBackEvent;
	NSMutableArray						*notifications;
	NSString							*UIType;
	
	NSString							*GATag;
	
	BOOL								displaysConnectionErrors;
	
	ViewOverlayType						activeViewOverlayType;
	GradientView						*viewOverlayView;

}

@property (nonatomic, strong) CustomNavigtionBar		* navigation;
@property (nonatomic, assign) CGRect		 frame;
@property (nonatomic, unsafe_unretained) id<SuperViewControllerDelegate>		 delegate;
@property (nonatomic, assign) BOOL		 appearWasBackEvent;
@property (nonatomic, assign) BOOL		 displaysConnectionErrors;
@property (nonatomic, strong) NSMutableArray		* notifications;
@property (nonatomic, strong) NSString		* UIType;
@property (nonatomic, strong) NSString		* GATag;
@property (nonatomic, assign) ViewOverlayType		 activeViewOverlayType;
@property (nonatomic, strong) GradientView		* viewOverlayView;


//
-(void)createNavigationBarUI;
-(void)setInitialState;
-(void)createNonPersistentUI;
-(void)createPersistentUI;
-(void)listNotificationInterests;
-(void)didReceiveNotification:(NSNotification*)notification;
-(void)addNotifications;
-(void)initialise;
-(void)refreshUIFromDataProvider;
-(void)deSelectRowForTableView:(UITableView*)table;

-(void)showViewOverlayForType:(ViewOverlayType)type show:(BOOL)show withMessage:(NSString*)message;
-(IBAction)loginButtonSelected:(id)sender;
+ (NSString*)viewTypeToStringType:(ViewOverlayType)viewType;
+(UINavigationController*)createCustomNavigationControllerWithView:(SuperViewController*)viewController;


+ (NSString *)nibName;
+ (NSString *)className;
@end
