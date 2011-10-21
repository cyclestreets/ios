//
//  SuperViewController.h
//  RacingUK
//
//  Created by Neil Edwards on 07/12/2009.
//  Copyright 2009 Chroma. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomNavigtionBar.h"

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

@end

@interface SuperViewController : UIViewController <CustomNavigationBarDelegate,SuperViewControllerDelegate>{
	
	CustomNavigtionBar					*navigation;
	CGRect								frame;
	id<SuperViewControllerDelegate>		delegate;
	BOOL								appearWasBackEvent;
	NSMutableArray						*notifications;
	NSString							*UIType;
	
	NSString							*GATag;

}

@property (nonatomic, retain) CustomNavigtionBar *navigation;
@property (nonatomic) CGRect frame;
@property (nonatomic, assign) id<SuperViewControllerDelegate> delegate;
@property (nonatomic) BOOL appearWasBackEvent;
@property (nonatomic, retain) NSMutableArray *notifications;
@property (nonatomic, retain) NSString *UIType;
@property (nonatomic, retain) NSString *GATag;


//
-(void)createNavigationBarUI;
-(void)setInitialState;
-(void)createNonPersistentUI;
-(void)createPersistentUI;
-(void)listNotificationInterests;
-(void)didReceiveNotification:(NSNotification*)notification;
-(void)addNotifications;
-(void)initialise;
-(void)handleRemoteRequestIndication:(BOOL)show;
-(void)refreshUIFromDataProvider;
-(void)showNoResultsView:(BOOL)show;
-(void)showConnectionErrorView:(BOOL)show;
-(void)showEventRestrictionView:(BOOL)show;
-(void)deSelectRowForTableView:(UITableView*)table;


+ (NSString *)nibName;
+ (NSString *)className;
@end
