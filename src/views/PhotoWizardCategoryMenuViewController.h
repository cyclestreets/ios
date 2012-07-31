//
//  PhotoWizardCategoryMenuViewController.h
//  CycleStreets
//
//  Created by neil on 03/07/2012.
//  Copyright (c) 2012 CycleStreets Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoCategoryVO.h"
#import "UploadPhotoVO.h"



@interface PhotoWizardCategoryMenuViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>{
	
	PhotoCategoryType						dataType;
	
	IBOutlet			UITableView			*tableView;
	
	NSMutableArray							*dataProvider;
	
	NSIndexPath								*selectedIndexPath;
	
	PhotoCategoryVO							*selectedItem;
	
	UploadPhotoVO							*uploadImage;
	
}
@property (nonatomic, assign)	PhotoCategoryType			dataType;
@property (nonatomic, strong)	IBOutlet UITableView			*tableView;
@property (nonatomic, strong)	NSMutableArray			*dataProvider;
@property (nonatomic, strong)	NSIndexPath			*selectedIndexPath;
@property (nonatomic, strong)	PhotoCategoryVO			*selectedItem;
@property (nonatomic, strong)	UploadPhotoVO			*uploadImage;
@end
