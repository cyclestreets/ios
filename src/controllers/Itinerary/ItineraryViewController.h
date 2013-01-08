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
	
	
}


-(void)createRowHeightsArray;
-(void)showNoActiveRouteView:(BOOL)show;
@end
