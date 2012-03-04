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
#import "RMMapView.h"
#import "RMMarker.h"
#import "RMMapContents.h"
#import <CoreLocation/CoreLocation.h>

#define MAXWIZARDVIEWS 7

enum  {
    PhotoWizardViewStateNone=0,
	PhotoWizardViewStatePhoto=1,
	PhotoWizardViewStateLocation=2,
	PhotoWizardViewStateCategory=3,
	PhotoWizardViewStateDescription=4,
	PhotoWizardViewStateUpload=5, 
	PhotoWizardViewStateResult=6
};
typedef int PhotoWizardViewState;

@interface PhotoWizardViewController : SuperViewController<UIPickerViewDelegate,UIPickerViewDataSource,
UIImagePickerControllerDelegate,RMMapViewDelegate,UIScrollViewDelegate,UINavigationControllerDelegate>{
    
    //main ui
    PhotoWizardViewState			viewState;
    UIScrollView                    *pageScrollView;
    UIPageControl                   *pageControl;
    LayoutBox                       *pageContainer;
	int								activePage; // page control index
	int								maxVisitedPage; // max page user has reached
    NSMutableArray                  *viewArray;
    
    IBOutlet    UILabel             *pageTitleLabel;
    IBOutlet    UILabel             *pageNumberLabel;
    
	
	UploadPhotoVO                   *uploadImage;
    
    
    IBOutlet UIView                 *infoView;
    IBOutlet UIButton				*continueButton;
	IBOutlet UIButton				*cancelViewButton;
    
    
    // photo picker
    IBOutlet    UIView              *photoPickerView;
	IBOutlet UIImageView			*imagePreview;
	IBOutlet UILabel				*photoSizeLabel;
	IBOutlet UIButton				*cameraButton;
	IBOutlet UIButton				*libraryButton;
	
	
	
	// photo location
	IBOutlet	UIView				*photoLocationView;
	IBOutlet RMMapView				*locationMapView;	//overlay GPS location
	RMMarker						*locationMarker;
	IBOutlet UILabel				*locationLabel;
	IBOutlet UIButton				*locationUpdateButton;
	IBOutlet UIButton				*locationResetButton;
	BOOL							avoidAccidentalTaps;
	BOOL							singleTapDidOccur;
	CGPoint							singleTapPoint;
	BOOL							locationManagerIsLocating;
	
	
    
    // category view
    IBOutlet    UIView              *categoryView;
    IBOutlet	UILabel				*categoryTypeLabel;
	IBOutlet	UILabel				*categoryDescLabel;
    IBOutlet    UIPickerView        *pickerView;
	// category model
    CategoryLoader                  *categoryLoader;
    NSInteger                       categoryIndex;
    NSInteger                       metacategoryIndex;
    
    
    // photo description and review
    IBOutlet    UIView              *photodescriptionView;
	IBOutlet	UIImageView			*descImagePreview;
    IBOutlet    UITextView          *photodescriptionField;
    
    
    
    // upload view
	IBOutlet    UIView              *photoUploadView;
	IBOutlet	UIButton			*uploadButton;
	IBOutlet	UIButton			*cancelButton;
	IBOutlet	UIProgressView		*uploadProgressView;
	IBOutlet	UILabel				*uploadLabel;
    
    
    // result view
    IBOutlet    UIView              *photoResultView;
	
	
	
}
@property (nonatomic, assign)	PhotoWizardViewState			viewState;
@property (nonatomic, retain)	UIScrollView			*pageScrollView;
@property (nonatomic, retain)	UIPageControl			*pageControl;
@property (nonatomic, retain)	LayoutBox			*pageContainer;
@property (nonatomic, assign)	int			activePage;
@property (nonatomic, assign)	int			maxVisitedPage;
@property (nonatomic, retain)	NSMutableArray			*viewArray;
@property (nonatomic, retain)	IBOutlet UILabel			*pageTitleLabel;
@property (nonatomic, retain)	IBOutlet UILabel			*pageNumberLabel;
@property (nonatomic, retain)	UploadPhotoVO			*uploadImage;
@property (nonatomic, retain)	IBOutlet UIView			*infoView;
@property (nonatomic, retain)	IBOutlet UIButton			*continueButton;
@property (nonatomic, retain)	IBOutlet UIButton			*cancelViewButton;
@property (nonatomic, retain)	IBOutlet UIView			*photoPickerView;
@property (nonatomic, retain)	IBOutlet UIImageView			*imagePreview;
@property (nonatomic, retain)	IBOutlet UILabel			*photoSizeLabel;
@property (nonatomic, retain)	IBOutlet UIButton			*cameraButton;
@property (nonatomic, retain)	IBOutlet UIButton			*libraryButton;
@property (nonatomic, retain)	IBOutlet UIView			*photoLocationView;
@property (nonatomic, retain)	IBOutlet RMMapView			*locationMapView;
@property (nonatomic, retain)	RMMarker			*locationMarker;
@property (nonatomic, retain)	IBOutlet UILabel			*locationLabel;
@property (nonatomic, retain)	IBOutlet UIButton			*locationUpdateButton;
@property (nonatomic, retain)	IBOutlet UIButton			*locationResetButton;
@property (nonatomic, assign)	BOOL			avoidAccidentalTaps;
@property (nonatomic, assign)	BOOL			singleTapDidOccur;
@property (nonatomic, assign)	CGPoint			singleTapPoint;
@property (nonatomic, assign)	BOOL			locationManagerIsLocating;
@property (nonatomic, retain)	IBOutlet UIView			*categoryView;
@property (nonatomic, retain)	IBOutlet UILabel			*categoryTypeLabel;
@property (nonatomic, retain)	IBOutlet UILabel			*categoryDescLabel;
@property (nonatomic, retain)	IBOutlet UIPickerView			*pickerView;
@property (nonatomic, retain)	CategoryLoader			*categoryLoader;
@property (nonatomic, assign)	NSInteger			categoryIndex;
@property (nonatomic, assign)	NSInteger			metacategoryIndex;
@property (nonatomic, retain)	IBOutlet UIView			*photodescriptionView;
@property (nonatomic, retain)	IBOutlet UIImageView			*descImagePreview;
@property (nonatomic, retain)	IBOutlet UITextView			*photodescriptionField;
@property (nonatomic, retain)	IBOutlet UIView			*photoUploadView;
@property (nonatomic, retain)	IBOutlet UIButton			*uploadButton;
@property (nonatomic, retain)	IBOutlet UIButton			*cancelButton;
@property (nonatomic, retain)	IBOutlet UIProgressView			*uploadProgressView;
@property (nonatomic, retain)	IBOutlet UILabel			*uploadLabel;
@property (nonatomic, retain)	IBOutlet UIView			*photoResultView;
@end
