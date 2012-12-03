//
//  ItineraryViewController.h
//  CycleStreets
//
//  Created by Neil Edwards on 09/03/2011.
//  Copyright 2011 CycleStreets Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SuperViewController.h"
#import "MultiLabelLine.h"
#import "LayoutBox.h"
#import "RouteSegmentViewController.h"
#import "CopyLabel.h"
#import "BUIconActionSheet.h"
#import <MessageUI/MessageUI.h>
@class RouteVO;

@interface ItineraryViewController : SuperViewController <UITableViewDelegate,UITableViewDataSource,BUIconActionSheetDelegate,MFMailComposeViewControllerDelegate,MFMessageComposeViewControllerDelegate>{
	
	RouteVO                         *route;
	NSInteger                       routeId;
	UITextView                      *headerText;
	
	RouteSegmentViewController							*routeSegmentViewcontroller;
	
	
	IBOutlet	CopyLabel			*routeidLabel;
				MultiLabelLine		*readoutLineOne;
				MultiLabelLine		*readoutLineTwo;
	MultiLabelLine		*readoutLineThree;
	IBOutlet	LayoutBox			*readoutContainer;
	
	IBOutlet	UITableView			*tableView;
	NSMutableArray					*rowHeightsArray;
	
	

}
@property (nonatomic, strong) RouteVO		* route;
@property (nonatomic, assign) NSInteger		 routeId;
@property (nonatomic, strong) UITextView		* headerText;
@property (nonatomic, strong) RouteSegmentViewController		* routeSegmentViewcontroller;
@property (nonatomic, strong) IBOutlet CopyLabel		* routeidLabel;
@property (nonatomic, strong) MultiLabelLine		* readoutLineOne;
@property (nonatomic, strong) MultiLabelLine		* readoutLineTwo;
@property (nonatomic, strong) MultiLabelLine		* readoutLineThree;
@property (nonatomic, strong) IBOutlet LayoutBox		* readoutContainer;
@property (nonatomic, strong) IBOutlet UITableView		* tableView;
@property (nonatomic, strong) NSMutableArray		* rowHeightsArray;

-(void)createRowHeightsArray;
-(void)showNoActiveRouteView:(BOOL)show;
@end
