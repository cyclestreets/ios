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
#import "PhotoCategoryManager.h"
#import "UploadPhotoVO.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "AccountViewController.h"
#import "RMMapView.h"
#import "CopyLabel.h"
#import "WEPopoverController.h"
#import "PhotoWizardCategoryMenuViewController.h"

#define MAXWIZARDVIEWS 7

enum  {
    PhotoWizardViewStateInfo=0,
	PhotoWizardViewStatePhoto=1,
	PhotoWizardViewStateLocation=2,
	PhotoWizardViewStateCategory=3,
	PhotoWizardViewStateDescription=4,
	PhotoWizardViewStateUpload=5, 
	PhotoWizardViewStateResult=6
};
typedef int PhotoWizardViewState;

@interface PhotoWizardViewController : SuperViewController<UITextViewDelegate,
UIImagePickerControllerDelegate,UIScrollViewDelegate,UINavigationControllerDelegate,UIGestureRecognizerDelegate,RMMapViewDelegate,WEPopoverControllerDelegate>{
    
    //main ui
    PhotoWizardViewState			viewState;
    IBOutlet UIScrollView           *pageScrollView;
    IBOutlet UIPageControl          *pageControl;
    LayoutBox                       *pageContainer;
	int								activePage; // page control index
	int								maxVisitedPage; // max page user has reached
    NSMutableArray                  *viewArray;
	
	IBOutlet    UIBarButtonItem					*nextButton;
	IBOutlet    UIBarButtonItem					*prevButton;
    
    IBOutlet    UILabel             *pageTitleLabel;
    IBOutlet    UILabel             *pageNumberLabel;
	
	UIScrollView					*locationsc;
	UIPanGestureRecognizer			*locpangesture;
    
	
	UploadPhotoVO                   *uploadImage;
    
    
    IBOutlet UIView                 *infoView;
    IBOutlet UIButton				*continueButton;
    
    
    // photo picker
    IBOutlet    UIView              *photoPickerView;
	IBOutlet UIImageView			*imagePreview;
	IBOutlet UILabel				*photoSizeLabel;
	IBOutlet UILabel				*photolocationLabel;
	IBOutlet UILabel				*photodateLabel;
	IBOutlet UIButton				*cameraButton;
	IBOutlet UIButton				*libraryButton;
	
	
	
	// photo location
	IBOutlet	UIView				*photoLocationView;
	IBOutlet RMMapView				*locationMapView;	//overlay GPS location
	RMMapContents					*locationMapContents;
	RMMarker						*locationMapMarker;
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
	
	IBOutlet	UIButton			*categoryButton;
	IBOutlet	UIButton			*categoryFeaturebutton;
	
	
	
	PhotoWizardCategoryMenuViewController  *categoryMenuView;
    
    
    // photo description and review
    IBOutlet    UIView              *photodescriptionView;
	IBOutlet	UIView				*textViewAccessoryView;
	IBOutlet	UIImageView			*descImagePreview;
    IBOutlet    UITextView          *photodescriptionField;
    
    
    
    // upload view
	IBOutlet    UIView              *photoUploadView;
	IBOutlet	UIButton			*uploadButton;
	IBOutlet	UIButton			*cancelButton;
	IBOutlet	UIProgressView		*uploadProgressView;
	IBOutlet	ExpandedUILabel				*uploadLabel;
    AccountViewController           *loginView;
    
    
    // result view
    IBOutlet    UIView              *photoResultView;
    IBOutlet    CopyLabel             *photoResultURLLabel;
	IBOutlet    UIButton            *photoMapButton;
	
	
	// popover support
	WEPopoverController *categoryMenu;
	Class popoverClass;
	
}
@property (nonatomic, assign) PhotoWizardViewState		 viewState;
@property (nonatomic, strong) IBOutlet UIScrollView		* pageScrollView;
@property (nonatomic, strong) IBOutlet UIPageControl		* pageControl;
@property (nonatomic, strong) LayoutBox		* pageContainer;
@property (nonatomic, assign) int		 activePage;
@property (nonatomic, assign) int		 maxVisitedPage;
@property (nonatomic, strong) NSMutableArray		* viewArray;
@property (nonatomic, strong) IBOutlet UIBarButtonItem		* nextButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem		* prevButton;
@property (nonatomic, strong) IBOutlet UILabel		* pageTitleLabel;
@property (nonatomic, strong) IBOutlet UILabel		* pageNumberLabel;
@property (nonatomic, strong) UIScrollView		* locationsc;
@property (nonatomic, strong) UIPanGestureRecognizer		* locpangesture;
@property (nonatomic, strong) UploadPhotoVO		* uploadImage;
@property (nonatomic, strong) IBOutlet UIView		* infoView;
@property (nonatomic, strong) IBOutlet UIButton		* continueButton;
@property (nonatomic, strong) IBOutlet UIView		* photoPickerView;
@property (nonatomic, strong) IBOutlet UIImageView		* imagePreview;
@property (nonatomic, strong) IBOutlet UILabel		* photoSizeLabel;
@property (nonatomic, strong) IBOutlet UILabel		* photolocationLabel;
@property (nonatomic, strong) IBOutlet UILabel		* photodateLabel;
@property (nonatomic, strong) IBOutlet UIButton		* cameraButton;
@property (nonatomic, strong) IBOutlet UIButton		* libraryButton;
@property (nonatomic, strong) IBOutlet UIView		* photoLocationView;
@property (nonatomic, strong) IBOutlet RMMapView		* locationMapView;
@property (nonatomic, strong) RMMapContents		* locationMapContents;
@property (nonatomic, strong) RMMarker		* locationMapMarker;
@property (nonatomic, strong) IBOutlet UILabel		* locationLabel;
@property (nonatomic, strong) IBOutlet UIButton		* locationUpdateButton;
@property (nonatomic, strong) IBOutlet UIButton		* locationResetButton;
@property (nonatomic, assign) BOOL		 avoidAccidentalTaps;
@property (nonatomic, assign) BOOL		 singleTapDidOccur;
@property (nonatomic, assign) CGPoint		 singleTapPoint;
@property (nonatomic, assign) BOOL		 locationManagerIsLocating;
@property (nonatomic, strong) IBOutlet UIView		* categoryView;
@property (nonatomic, strong) IBOutlet UILabel		* categoryTypeLabel;
@property (nonatomic, strong) IBOutlet UILabel		* categoryDescLabel;
@property (nonatomic, strong) IBOutlet UIPickerView		* pickerView;
@property (nonatomic, strong) IBOutlet UIButton		* categoryButton;
@property (nonatomic, strong) IBOutlet UIButton		* categoryFeaturebutton;
@property (nonatomic, strong) PhotoWizardCategoryMenuViewController		* categoryMenuView;
@property (nonatomic, strong) IBOutlet UIView		* photodescriptionView;
@property (nonatomic, strong) IBOutlet UIView		* textViewAccessoryView;
@property (nonatomic, strong) IBOutlet UIImageView		* descImagePreview;
@property (nonatomic, strong) IBOutlet UITextView		* photodescriptionField;
@property (nonatomic, strong) IBOutlet UIView		* photoUploadView;
@property (nonatomic, strong) IBOutlet UIButton		* uploadButton;
@property (nonatomic, strong) IBOutlet UIButton		* cancelButton;
@property (nonatomic, strong) IBOutlet UIProgressView		* uploadProgressView;
@property (nonatomic, strong) IBOutlet ExpandedUILabel		* uploadLabel;
@property (nonatomic, strong) AccountViewController		* loginView;
@property (nonatomic, strong) IBOutlet UIView		* photoResultView;
@property (nonatomic, strong) IBOutlet CopyLabel		* photoResultURLLabel;
@property (nonatomic, strong) IBOutlet UIButton		* photoMapButton;
@property (nonatomic, strong) WEPopoverController		* categoryMenu;


-(IBAction)cameraButtonSelected:(id)sender;
-(IBAction)libraryButtonSelected:(id)sender;
-(IBAction)cancelUploadPhoto:(id)sender;
-(IBAction)closeWindowButtonSelected:(id)sender;
-(IBAction)textViewKeyboardShouldClear:(id)sender;

-(IBAction)navigateToPreviousView:(id)sender;
-(IBAction)navigateToNextView:(id)sender;

@end
