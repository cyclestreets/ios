//
//  PhotoWizardViewController.h
//  CycleStreets
//
//  Created by neil on 28/02/2012.
//  Copyright (c) 2012 CycleStreets Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SuperViewController.h"
#import "LayoutBox.h"
#import "CategoryLoader.h"
#import "UploadPhotoVO.h"

enum  {
	PhotoWizardViewStatePhoto=0,
	PhotoWizardViewStateCategory=1,
	PhotoWizardViewStateDescription=2,
	PhotoWizardViewStateUpload=3, 
	PhotoWizardViewStateResult=4
};
typedef int PhotoWizardViewState;

@interface PhotoWizardViewController : SuperViewController<UIPickerViewDelegate,UIPickerViewDataSource,UIImagePickerControllerDelegate>{
    
    //main ui
    PhotoWizardViewState           viewState;
    UIScrollView                    *pageScrollView;
    UIPageControl                   *pageControl;
    LayoutBox                       *pageContainer;
    
    
    // photo picker
    IBOutlet    UIView              *photoPickerView;
    UploadPhotoVO                   *uploadImage;
    
    
    // category view
    IBOutlet    UIView              *categoryView;
    IBOutlet	UILabel				*categoryTypeLabel;
	IBOutlet	UILabel				*categoryDescLabel;
    IBOutlet    UIPickerView        *pickerView;
	// category model
    CategoryLoader                  *categoryLoader;
    NSInteger                       categoryIndex;
    NSInteger                       metacategoryIndex;
    
    
    // photo description
    IBOutlet    UIView              *photodescriptionView;
    IBOutlet    UITextView          *photodescriptionField;
    
    
    // photo review
    IBOutlet    UIView              *photoReviewView;
    
    // upload view
     IBOutlet    UIView              *photoUploadView;
    
    
    // result view
    IBOutlet    UIView              *photoResultView;
}

@end
