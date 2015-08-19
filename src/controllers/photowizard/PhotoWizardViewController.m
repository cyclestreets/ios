//
//  PhotoWizardViewController.m
//  CycleStreets
//
//  Created by neil on 28/02/2012.
//  Copyright (c) 2012 CycleStreets Ltd. All rights reserved.
//

#import "PhotoWizardViewController.h"
#import "ImageUtilties.h"
#import "UploadPhotoVO.h"
#import "GlobalUtilities.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "UserLocationManager.h"
#import "CycleStreets.h"
#import "UIView+Additions.h"
#import "ButtonUtilities.h"
#import "StyleManager.h"
#import "PhotoWizardLocationViewController.h"
#import "UserAccount.h"
#import "PhotoManager.h"
#import "AppDelegate.h"
#import <ImageIO/ImageIO.h>
#import <MapKit/MapKit.h>
#import "CSPhotomapAnnotation.h"
#import "StringManager.h"
#import "MKMapView+Additions.h"
#import "CSPhotomapAnnotationView.h"
#import "AccountViewController.h"
#import "CSMapSource.h"
#import "CSMapTileService.h"
#import "UIImage+PDF.h"
#import "HudManager.h"

static NSString *const LOCATIONSUBSCRIBERID=@"PhotoWizard";



@interface PhotoWizardViewController()<UIPickerViewDataSource,UIPickerViewDelegate,UITextFieldDelegate,MKMapViewDelegate>




@property (nonatomic, assign) PhotoWizardViewState viewState;
@property (nonatomic, strong) IBOutlet UIScrollView *pageScrollView;
@property (nonatomic, strong) IBOutlet UIPageControl *pageControl;
@property (nonatomic, strong) IBOutlet UIView *headerView;
@property (nonatomic, strong) IBOutlet UIView *footerView;
@property (nonatomic, strong) LayoutBox *pageContainer;
@property (nonatomic, assign) NSInteger activePage;
@property (nonatomic, assign) NSInteger maxVisitedPage;
@property (nonatomic, strong) NSMutableArray *viewArray;
@property (nonatomic, strong) IBOutlet UIToolbar *modalToolBar;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *cancelViewButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *nextButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *prevButton;
@property (nonatomic, strong) IBOutlet UILabel *pageTitleLabel;
@property (nonatomic, strong) IBOutlet UILabel *pageNumberLabel;
@property (nonatomic, strong) IBOutlet UIScrollView *locationsc;
@property (nonatomic, strong) UIPanGestureRecognizer *locpangesture;
@property (nonatomic, strong) UploadPhotoVO *uploadImage;
@property (nonatomic, strong) IBOutlet UIView *infoView;
@property (nonatomic, strong) IBOutlet UIButton *continueButton;


@property (nonatomic, strong) IBOutlet UIView *photoPickerView;
@property (nonatomic, strong) IBOutlet UIImageView *imagePreview;
@property (nonatomic, strong) IBOutlet UILabel *photoSizeLabel;
@property (nonatomic, strong) IBOutlet UILabel *photolocationLabel;
@property (nonatomic, strong) IBOutlet UILabel *photodateLabel;
@property (nonatomic, strong) IBOutlet UIButton *cameraButton;
@property (nonatomic, strong) IBOutlet UIButton *libraryButton;
@property (nonatomic, strong) IBOutlet UIView *photoLocationView;


@property (nonatomic, strong) IBOutlet MKMapView *locationMapView;
@property (nonatomic,strong)  CSMapSource							* activeMapSource;
@property (nonatomic, strong) IBOutlet UILabel *locationLabel;
@property (nonatomic, strong) IBOutlet UIButton *locationUpdateButton;
@property (nonatomic, strong) IBOutlet UIButton *locationResetButton;
@property (nonatomic, assign, getter=isAvoidAccidentalTaps) BOOL avoidAccidentalTaps;
@property (nonatomic, assign, getter=isSingleTapDidOccur) BOOL singleTapDidOccur;
@property (nonatomic, assign) CGPoint singleTapPoint;
@property (nonatomic, assign, getter=isLocationManagerIsLocating) BOOL locationManagerIsLocating;


@property (nonatomic, strong) IBOutlet UIView *categoryView;
@property (nonatomic, strong) IBOutlet UILabel *categoryTypeLabel;
@property (nonatomic, strong) IBOutlet UILabel *categoryDescLabel;
@property (nonatomic, strong) IBOutlet UIPickerView *pickerView;
@property (nonatomic, strong) IBOutlet UITextField *categoryField;
@property (nonatomic, strong) IBOutlet UITextField *categoryFeatureField;
@property (nonatomic, strong) UIPickerView			*categoryPickerView;
@property (nonatomic, strong) UITextField			*currentCategoryField;
@property (nonatomic, strong) NSArray				*activePickerDataSource;
@property (nonatomic, strong) IBOutlet UIView		*pickerAccessoryView;
@property (weak, nonatomic) IBOutlet UIImageView    *categoryIconView;


@property (nonatomic, strong) IBOutlet UIView *photodescriptionView;
@property (nonatomic, strong) IBOutlet UIView *textViewAccessoryView;
@property (nonatomic, strong) IBOutlet UIImageView *descImagePreview;
@property (nonatomic, strong) IBOutlet UITextView *photodescriptionField;


@property (nonatomic, strong) IBOutlet UIView *photoUploadView;
@property (nonatomic, strong) IBOutlet UIButton *uploadButton;
@property (nonatomic, strong) IBOutlet UIButton *cancelButton;
@property (nonatomic, strong) IBOutlet UIProgressView *uploadProgressView;
@property (nonatomic, strong) IBOutlet ExpandedUILabel *uploadLabel;


@property (nonatomic, strong) IBOutlet UIView *photoResultView;
@property (nonatomic, strong) IBOutlet CopyLabel *photoResultURLLabel;
@property (nonatomic, strong) IBOutlet UIButton *photoMapButton;

@property (nonatomic,strong)  CSPhotomapAnnotation									*userLocationAnnotation;
@property (nonatomic,strong)  AccountViewController									*loginView;



-(void)resetPhotoWizard;

-(void)initialiseViewState:(PhotoWizardViewState)state;
-(void)navigateToViewState:(PhotoWizardViewState)state;
-(void)updateGlobalViewUIForState;
-(void)updateView;
-(IBAction)navigateToNextView:(id)sender;
-(void)resetToViewState:(PhotoWizardViewState)state;

-(void)initInfoView:(PhotoWizardViewState)state;
-(void)initPhotoView:(PhotoWizardViewState)state;
-(void)updatePhotoView;
-(void)initLocationView:(PhotoWizardViewState)state;
-(void)updateLocationView;
-(void)initCategoryView:(PhotoWizardViewState)state;
-(void)updateCategoryView;
-(void)resetCategoryView;
-(void)didSelectCategoryFromMenu:(NSInteger)index;

-(void)initDescriptionView:(PhotoWizardViewState)state;
-(void)updateDescriptionView;
-(void)resetDescriptionField;
-(void)resetDescriptionView;
-(void)initUploadView:(PhotoWizardViewState)state;
-(void)updateUploadView;
-(void)initCompleteView:(PhotoWizardViewState)state;
-(void)updateCompleteView;

-(void)addViewToPageContainer:(NSMutableDictionary*)viewDict;


-(IBAction)textViewKeyboardShouldHide:(id)sender;

-(void)updatePageControlExtents;

-(IBAction)pageControlValueChanged:(id)sender;

-(void)loadLocationFromPhoto;
-(void)displayDefaultLocation;
-(void)updateLocationMapViewForLocation:(CLLocation*)location;


-(void)didRecievePhotoImageUploadResponse:(NSDictionary*)dict;
-(void)didRecieveFileUploadResponse:(NSDictionary*)dict;

-(void)updateUploadUIState:(NSString*)state;

@end


@implementation PhotoWizardViewController



//
/***********************************************
 * @description		NOTIFICATIONS
 ***********************************************/
//

-(void)listNotificationInterests{
	
	[self initialise];
    
    [notifications addObject:UPLOADUSERPHOTORESPONSE];
	[notifications addObject:FILEUPLOADPROGRESS];
	[notifications addObject:GPSLOCATIONCOMPLETE];
	[notifications addObject:PHOTOWIZARDCATEGORYUPDATE];
	[notifications addObject:USERACCOUNTLOGINSUCCESS];
	[notifications addObject:USERACCOUNTREGISTERSUCCESS];
	[notifications addObject:CSMAPSTYLECHANGED];
	
	[notifications addObject:UIKeyboardWillShowNotification];
	[notifications addObject:UIKeyboardWillHideNotification];
	
	[super listNotificationInterests];
	
}

-(void)didReceiveNotification:(NSNotification*)notification{
	
	BetterLog(@"");
	
	[super didReceiveNotification:notification];
	
    if([notification.name isEqualToString:UPLOADUSERPHOTORESPONSE]){
        [self didRecievePhotoImageUploadResponse:notification.userInfo];
    }
	
	if([notification.name isEqualToString:FILEUPLOADPROGRESS]){
        [self didRecieveFileUploadResponse:notification.userInfo];
    }
	
	if([notification.name isEqualToString:GPSLOCATIONCOMPLETE]){
        [self UserDidUpdatePhotoLocation:notification.object];
    }
	
	
	if([notification.name isEqualToString:USERACCOUNTLOGINSUCCESS] || [notification.name isEqualToString:USERACCOUNTREGISTERSUCCESS]){
        [self autoUploadUserPhoto];
    }
	
	if([notification.name isEqualToString:CSMAPSTYLECHANGED]){
		[self didNotificationMapStyleChanged];
	}
}


- (void) didNotificationMapStyleChanged {
	
	
	NSArray *overlays=[_locationMapView overlaysInLevel:MKOverlayLevelAboveLabels];
	
	self.activeMapSource=[CycleStreets activeMapSource];
	
	[CSMapTileService updateMapStyleForMap:_locationMapView toMapStyle:_activeMapSource withOverlays:overlays];
	
	
}



-(void)didRecievePhotoImageUploadResponse:(NSDictionary*)dict{
    
    NSString *state=[dict objectForKey:STATE];
	
	if([state isEqualToString:SUCCESS]){
		
		[self initialiseViewState:PhotoWizardViewStateResult];
		[self navigateToViewState:PhotoWizardViewStateResult];
		
		
	}else {
		
		BetterLog(@"[ERROR] Upload Error was %@",[dict objectForKey:MESSAGE]);
		
		[self updateUploadUIState:@"error"];
		
	}
    
    
}

//
/***********************************************
 * @description			Notification from RFM of http upload progress
 ***********************************************/
//
-(void)didRecieveFileUploadResponse:(NSDictionary*)dict{
	
	BetterLog(@"uploaddict=%@",dict);
    
	float totalBytesWritten=[[dict objectForKey:@"totalBytesWritten"] floatValue];
	//Not used: int bytesWritten=[[dict objectForKey:@"bytesWritten"] intValue];
	float totalBytesExpectedToWrite=[[dict objectForKey:@"totalBytesExpectedToWrite"] floatValue];
	
	float percent=totalBytesWritten/totalBytesExpectedToWrite;
	
	BetterLog(@"percent=%f",percent);
	
    _uploadProgressView.progress=percent;
    
}

-(void)autoUploadUserPhoto{
	[self uploadPhoto:nil];
}


-(void)refreshUIFromDataProvider{
	
}


//
/***********************************************
 * @description			View Methods
 ***********************************************/
//


- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}


- (void)viewDidLoad {
	
	
    [super viewDidLoad];
    
	[self createPersistentUI];
	
	
}


-(void)createPersistentUI{
	
	
	
	_modalToolBar.clipsToBounds=YES;
	
	//[self didNotificationMapStyleChanged];
	
    _viewState=PhotoWizardViewStateInfo;
	_activePage=0;
	_maxVisitedPage=-1;
	
	// set up scroll view with layoutbox for sub items
	self.pageContainer=[[LayoutBox alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 10)];
	_pageContainer.layoutMode=BUHorizontalLayoutMode;
	
    
    self.viewArray=[NSMutableArray arrayWithObjects:
					[NSMutableDictionary dictionaryWithObjectsAndKeys:_infoView, @"view", @"Information",@"title",BOX_BOOL(NO),@"created",nil],
					[NSMutableDictionary dictionaryWithObjectsAndKeys:_photoPickerView, @"view",@"Photo Picker",@"title" ,BOX_BOOL(NO),@"created",nil],
					[NSMutableDictionary dictionaryWithObjectsAndKeys:_photoLocationView, @"view",@"Location",@"title" ,BOX_BOOL(NO),@"created",nil],
					[NSMutableDictionary dictionaryWithObjectsAndKeys:_categoryView, @"view",@"Photo Category",@"title" ,BOX_BOOL(NO),@"created",nil],
					[NSMutableDictionary dictionaryWithObjectsAndKeys:_photodescriptionView, @"view",@"Description",@"title" ,BOX_BOOL(NO),@"created",nil],
					[NSMutableDictionary dictionaryWithObjectsAndKeys:_photoUploadView, @"view",@"Upload",@"title",BOX_BOOL(NO),@"created",nil],
					[NSMutableDictionary dictionaryWithObjectsAndKeys:_photoResultView, @"view", @"Result",@"title",BOX_BOOL(NO),@"created",nil],nil ];
    
	[_pageScrollView addSubview:_pageContainer];
	 
	_pageScrollView.pagingEnabled=YES;
	_pageScrollView.backgroundColor=UIColorFromRGB(0xECE9E8);
	_pageScrollView.delegate=self;
	_pageControl.hidesForSinglePage=YES;
    _pageControl.numberOfPages=1;
	[_pageControl addTarget:self action:@selector(pageControlValueChanged:) forControlEvents:UIControlEventValueChanged];
	
	
}

-(void)viewDidLayoutSubviews{
	
	[self createNavigationBarUI];
	[self initialiseViewState:PhotoWizardViewStateInfo];
	
}


-(void)createNavigationBarUI{
	
	if(_isModal==NO){
		
		self.navigationItem.backBarButtonItem.tintColor=UIColorFromRGB(0xA71D1D);
		
		self.prevButton=[[UIBarButtonItem alloc]initWithTitle:@"Prev" style:UIBarButtonItemStylePlain target:self action:@selector(navigateToPreviousView:)];
		self.nextButton=[[UIBarButtonItem alloc]initWithTitle:@"Next" style:UIBarButtonItemStylePlain target:self action:@selector(navigateToNextView:)];
		
		[self.navigationItem setRightBarButtonItems:@[_nextButton,_prevButton]];
		
		_pageScrollView.y=20;
		_headerView.y=0;
		_pageControl.y=0;
		
		// NOTE: this shouldnt be necessary, but autoresizing mask fails wne not modal (might be something to do with the Toolbar)
		_pageScrollView.height=self.view.height-_headerView.height-_footerView.height;
		
	}else{
		
		
		
	}
	
	_modalToolBar.visible=_isModal;
	
}


-(void)viewWillAppear:(BOOL)animated{
	
	[self createNonPersistentUI];
	
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
	
    [super viewWillAppear:animated];
}


// intercept back event to reset pw if we are on Complete state
-(void) viewWillDisappear:(BOOL)animated {
	
	if(_viewState==PhotoWizardViewStateResult){
	
		if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
			[self resetPhotoWizard];
		}
		
	}
	
		
    [super viewWillDisappear:animated];
}


-(void)createNonPersistentUI{
    
	if(_uploadImage==nil)
		self.uploadImage=[[UploadPhotoVO alloc]init];
   
    
}




-(void)resetPhotoWizard{
	
	_viewState=PhotoWizardViewStateInfo;
	_activePage=0;
	_maxVisitedPage=-1;
	
	[_pageContainer removeAllSubViews];
	
	for(NSMutableDictionary *viewDict in _viewArray){
		
		[viewDict setObject:BOX_BOOL(NO) forKey:@"created"];
		
	}
	
	self.uploadImage=nil;
	
	
	
	[self initialiseViewState:PhotoWizardViewStateInfo];
	
}


#pragma mark - Navigation


//
/***********************************************
 * @description			initialises and adds view state to container (one off operation)
 ***********************************************/
//
-(void)initialiseViewState:(PhotoWizardViewState)state{
	
	BetterLog(@"");
	
	// if view is not initialised 
	// create and add
	// set max view state to this int
	// update pagecontrol so this view can be accessed
	
	NSMutableDictionary *viewdict=[_viewArray objectAtIndex:state];
	if([viewdict objectForKey:@"created"]==BOX_BOOL(NO)){
		
		[self addViewToPageContainer:viewdict];

		
		switch (state) {
                
            case PhotoWizardViewStateInfo:
                
				[self initInfoView:state];
				
				break;
				
			case PhotoWizardViewStatePhoto:
                
                [self initPhotoView:state];
				
				break;
				
			case PhotoWizardViewStateLocation:
                
                [self initLocationView:state];
				
				break;
				
			case PhotoWizardViewStateCategory:
				
				[self initCategoryView:state];
				
				break;
				
			case PhotoWizardViewStateDescription:
				
				[self initDescriptionView:state];
				
				break;
				
			case PhotoWizardViewStateUpload:
				
				[self initUploadView:state];
				
				break;
				
			case PhotoWizardViewStateResult:
				
				[self initCompleteView:state];
				
			break;
				
			default:
				break;
		}

	}
	
	
	if((int)state>_maxVisitedPage){
		_maxVisitedPage=state;
	}
	
	if (_maxVisitedPage==_activePage) {
		_nextButton.enabled=NO;
	}else {
		_nextButton.enabled=YES;
	}
	
	if (_activePage==0) {
		_prevButton.enabled=NO;
	}else {
		_prevButton.enabled=YES;
	}
	
	[self updatePageControlExtents];
	
}


-(void)removeViewState:(PhotoWizardViewState)state{
	
	BetterLog(@"");
    
    _maxVisitedPage=state-1;
	
	if (_maxVisitedPage==_activePage) {
		_nextButton.enabled=NO;
	}else {
		_nextButton.enabled=YES;
	}
    
	[self updatePageControlExtents];
}

-(void)resetToViewState:(PhotoWizardViewState)state{
	
	BetterLog(@"");
    
    _maxVisitedPage=state-1;
	_activePage=state;
	_viewState=state;
	_pageControl.currentPage=_viewState;
	
	if (_maxVisitedPage==_activePage) {
		_nextButton.enabled=NO;
	}else {
		_nextButton.enabled=YES;
	}
	
	CGPoint offset=CGPointMake(_viewState*SCREENWIDTH, 0);
	[_pageScrollView setContentOffset:offset animated:YES];
	
    
	[self updatePageControlExtents];
}


//
/***********************************************
 * @description			scroll To ViewState if initialised
 ***********************************************/
//
-(void)navigateToViewState:(PhotoWizardViewState)state{
	
	BetterLog(@"");
	
	if(state<=_maxVisitedPage){
		

		_viewState=state;
		_pageControl.currentPage=_viewState;
		_activePage=_viewState;
        
		CGPoint offset=CGPointMake(_viewState*SCREENWIDTH, 0);
		[_pageScrollView setContentOffset:offset animated:YES];
		
		[self updateGlobalViewUIForState];
		
		if(_currentCategoryField.isFirstResponder)
			[_currentCategoryField resignFirstResponder];
		
		if (_photodescriptionField.isFirstResponder)
			[_photodescriptionField resignFirstResponder];
		
		
    }
	
	
}


-(IBAction)navigateToNextView:(id)sender{
	
	if(_activePage<_maxVisitedPage){
		[self navigateToViewState:_activePage+1];
	}

}

-(IBAction)navigateToPreviousView:(id)sender{
	
	if(_activePage>0){
		[self navigateToViewState:_activePage-1];
	}
	
}


-(IBAction)closeWindowButtonSelected:(id)sender{
	
	[self dismissModalViewControllerAnimated:YES];
	
}


-(void)updateGlobalViewUIForState{
	
	BetterLog(@"");
	
	_pageTitleLabel.text=[[_viewArray objectAtIndex:_activePage] objectForKey:@"title"];
    _pageNumberLabel.text=[NSString stringWithFormat:@"%li of %lu",_activePage+1, (unsigned long)[_viewArray count]];
	
	[self updateView];
	
	if (_maxVisitedPage==_activePage) {
		_nextButton.enabled=NO;
	}else {
		_nextButton.enabled=YES;
	}
	
	if (_activePage==0) {
		_prevButton.enabled=NO;
	}else {
		_prevButton.enabled=YES;
	}
	
	if (_activePage==PhotoWizardViewStateResult) {
		_prevButton.enabled=NO;
		_nextButton.enabled=NO;
	}
	
}

-(void)updateView{
	
	
	switch (_viewState) {
			
		case PhotoWizardViewStateInfo:
		break;
			
		case PhotoWizardViewStatePhoto:
			[self updatePhotoView];
		break;
			
		case PhotoWizardViewStateLocation:			
			[self updateLocationView];
		break;
			
		case PhotoWizardViewStateCategory:
			[self updateCategoryView];
		break;
			
		case PhotoWizardViewStateDescription:
			[self updateDescriptionView];
		break;
			
		case PhotoWizardViewStateUpload:
			[self updateUploadView];
		break;
			
		case PhotoWizardViewStateResult:
			[self updateCompleteView];
		break;
			
		default:
		break;
	}
		
}



-(void)addViewToPageContainer:(NSMutableDictionary*)viewDict{
	
	[viewDict setObject:BOX_BOOL(YES) forKey:@"created"];
	UIScrollView *sc=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH, _pageScrollView.height)];
	UIView *stateview=[viewDict objectForKey:@"view"];
	
	[sc addSubview:stateview];
	[sc setContentSize:CGSizeMake(SCREENWIDTH, stateview.height)];
	[_pageContainer addSubview:sc];
		
	[_pageScrollView setContentSize:CGSizeMake(_pageContainer.width, _pageScrollView.height)];
	
}


#pragma mark - Paging
//
/***********************************************
 * @description			PAGE EVENTS
 ***********************************************/
//

-(void)scrollViewDidEndDecelerating:(UIScrollView *)sc{
	BetterLog(@"");
	CGPoint offset=_pageScrollView.contentOffset;
	_activePage=offset.x/SCREENWIDTH;
	_pageControl.currentPage=_activePage;
	_viewState=_activePage;
	[_pageControl updateCurrentPageDisplay];
	[self updateGlobalViewUIForState];
}


-(IBAction)pageControlValueChanged:(id)sender{
	BetterLog(@"");
	UIPageControl *pc=(UIPageControl*)sender;
    if(pc.currentPage<=_maxVisitedPage){
        CGPoint offset=CGPointMake(pc.currentPage*SCREENWIDTH, 0);
        [_pageScrollView setContentOffset:offset animated:YES];
		_activePage=pc.currentPage;
		
    }else{
        pc.currentPage=_activePage;
    }
	
}
-(void)scrollViewDidEndScrollingAnimation:(UIScrollView*)sc{
	BetterLog(@"");
	[self scrollViewDidEndDecelerating:_pageScrollView];
	[self updatePageControlExtents];
}


-(void)updatePageControlExtents{
	
	BetterLog(@"");
	
	_pageControl.numberOfPages=_maxVisitedPage+1;
	
	
	
}


//
/***********************************************
 * @description			View info methods
 ***********************************************/
//

-(void)initInfoView:(PhotoWizardViewState)state{
	
	[_continueButton addTarget:self action:@selector(continueUploadbuttonSelected:) forControlEvents:UIControlEventTouchUpInside];
	
	[self initialiseViewState:PhotoWizardViewStatePhoto];
	
}

-(IBAction)continueUploadbuttonSelected:(id)sender{
    
	[self navigateToViewState:PhotoWizardViewStatePhoto];
    
}




#pragma mark - Photo View
//
/***********************************************
 * @description			PhotoPicker methods
 ***********************************************/
//

-(void)initPhotoView:(PhotoWizardViewState)state{
	
	_imagePreview.image=nil;
	
	//[ButtonUtilities styleIBButton:_cameraButton type:@"green" text:@"Camera"];
	[_cameraButton addTarget:self action:@selector(cameraButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
	//[ButtonUtilities styleIBButton:_libraryButton type:@"green" text:@"Library"];
	[_libraryButton addTarget:self action:@selector(libraryButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
	
	[_cameraButton setEnabled:[UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]];
	[_libraryButton setEnabled:[UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]];
	
	[self initialiseViewState:PhotoWizardViewStateInfo];
	
}

-(void)updatePhotoView{
	
	if(_uploadImage!=nil){
        _imagePreview.image=_uploadImage.image;
        _photoSizeLabel.text=[NSString stringWithFormat:@"%i x %i",_uploadImage.width, _uploadImage.height];
		_photodateLabel.text=[NSString stringWithFormat:@"%@",_uploadImage.dateString];
    }else{
		_photoSizeLabel.text=EMPTYSTRING;
		_photolocationLabel.text=EMPTYSTRING;
		_photodateLabel.text=EMPTYSTRING;
    }
}

-(IBAction)cameraButtonSelected:(id)sender{
	
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
		UIImagePickerController *picker = [[UIImagePickerController alloc] init];
		
		picker.delegate = self;
		picker.sourceType = UIImagePickerControllerSourceTypeCamera;
		picker.allowsEditing = YES;
		[self presentViewController:picker animated:YES	completion:^{}];
		
	}else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error accessing camera" message:@"Device does not have a camera" 
													   delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
		[alert show];
	}
    
	
}


-(IBAction)libraryButtonSelected:(id)sender{
	
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
		UIImagePickerController *picker = [[UIImagePickerController alloc] init];
		picker.navigationBar.backgroundColor=UIColorFromRGBAndAlpha(0xFFFFFF,0);
		picker.delegate = self;
		picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
		picker.allowsEditing = NO;
		[self presentViewController:picker animated:YES	completion:^{}];
	}
	else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error accessing photo library" 
														message:@"Device does not support a photo library" 
													   delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
		[alert show];
	}
	
	
}

// force UIImagePickerController navcontroller to respect the application statusbar/nav bar style
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
	navigationController.navigationBar.translucent=NO;
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}


#pragma mark imagePickerController  Delegate methods -
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	
	
	UIImage *image=[info objectForKey:UIImagePickerControllerOriginalImage];
	_uploadImage.image=image;
	_imagePreview.image=_uploadImage.image;
	_photoSizeLabel.text=[NSString stringWithFormat:@"%i x %i",_uploadImage.width, _uploadImage.height];
	
	
	NSURL *referenceURL = [info objectForKey:UIImagePickerControllerReferenceURL];
	ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
	
	[library assetForURL:referenceURL resultBlock:^(ALAsset *asset){
		
		ALAssetRepresentation *rep = [asset defaultRepresentation];
        NSDictionary *metadata = rep.metadata;
		NSDictionary *gpsDict = [metadata objectForKey:(NSString *)kCGImagePropertyGPSDictionary];
        
		if(gpsDict!=nil){
			_uploadImage.bearing=[[gpsDict objectForKey:@"ImgDirection"] intValue];
		}
		
		CLLocation *location = (CLLocation *)[asset valueForProperty:ALAssetPropertyLocation];
		_uploadImage.location=location;
		
		NSDate		*assetdate=(NSDate*)[asset valueForProperty:ALAssetPropertyDate];
		_uploadImage.date=assetdate;
		
		_photolocationLabel.text=[[GlobalUtilities convertBooleanToType:@"string" :location!=nil] capitalizedString];
		_photodateLabel.text=[NSString stringWithFormat:@"%@",_uploadImage.dateString];
		
		if(location!=nil)
			BetterLog(@"location=%f %f",location.coordinate.latitude, location.coordinate.longitude);
		
		
	} failureBlock:^(NSError *error) {
		 BetterLog(@"error retrieving image from  - %@",[error localizedDescription]);
	 }];
	
	
	[self dismissViewControllerAnimated:YES completion:^{}];
	
    
	// ensure further screens are reset
	[self initialiseViewState:PhotoWizardViewStateLocation];
	
	 
	 NSMutableDictionary *viewdict=[_viewArray objectAtIndex:PhotoWizardViewStateCategory];
	 if([viewdict objectForKey:@"created"]==BOX_BOOL(YES)){
		 
		 _maxVisitedPage=PhotoWizardViewStateLocation;
	
		 [self resetCategoryView];
		 [self resetDescriptionView];
		 
		 [self updateGlobalViewUIForState];
		 
		 [self updatePageControlExtents];
	 
	 }
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	[self dismissViewControllerAnimated:YES completion:^{}];
}


#pragma mark - Location View
//
/***********************************************
 * @description			LOCATION METHODS
 ***********************************************/
//

// Uses normal map logic

-(void)initLocationView:(PhotoWizardViewState)state{
	
	BetterLog(@"");
	
	[_locationUpdateButton addTarget:self action:@selector(locationButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
	
	_locationMapView.userInteractionEnabled=NO;
	_locationMapView.delegate=self;
	
	 self.userLocationAnnotation=[[CSPhotomapAnnotation alloc]init];
	 _userLocationAnnotation.coordinate=CLLocationCoordinate2DMake(0,0);
	_userLocationAnnotation.isUserPhoto=YES;
	 [_locationMapView addAnnotation:_userLocationAnnotation];
	
	[self didNotificationMapStyleChanged];
		
	[self loadLocationFromPhoto];
		
}




-(void)updateLocationView{
	
	BetterLog(@"");
	
	CLLocationCoordinate2D imageloc=_uploadImage.location.coordinate;
	CLLocationCoordinate2D zeroloc=CLLocationCoordinate2DMake(0,0);
	
	MKMapPoint p1 = MKMapPointForCoordinate(imageloc);
	MKMapPoint p2 = MKMapPointForCoordinate(zeroloc);
	
	//Calculate distance in meters
	CLLocationDistance dist = MKMetersBetweenMapPoints(p1, p2);
	
    if(_uploadImage.location==nil || dist==0.0){
		
		
		if(_uploadImage.userLocation!=nil){
			
			
			[self updateLocationMapViewForLocation:_uploadImage.userLocation];
			
		}else{
			
			if([UserLocationManager sharedInstance].doesDeviceAllowLocation==NO){
				
				[self displayDefaultLocation];
				
			}else {
				_locationMapView.showsUserLocation=YES;
			}
			
		}
		
		
		
	}else{
		if(_uploadImage.userLocation==nil)
			[self loadLocationFromPhoto];
		
		[self initialiseViewState:PhotoWizardViewStateCategory];
		
    }
	
	
}


- (IBAction) locationButtonSelected:(id)sender {
	
    PhotoWizardLocationViewController *lv=[[PhotoWizardLocationViewController alloc]initWithNibName:[PhotoWizardLocationViewController nibName] bundle:nil];
	lv.delegate=self;
	lv.userlocation=_uploadImage.userLocation;
	lv.photolocation=_uploadImage.location;
	
	[self presentModalViewController:lv animated:YES];
    
}
-(IBAction)resetButtonSelected:(id)sender{
    
    if(_uploadImage.userLocation!=nil){
		_uploadImage.userLocation=nil;
	}
    
	if(_uploadImage.location!=nil){
		[self updateLocationMapViewForLocation:_uploadImage.location];
	}
}


-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
	
	[self UserDidUpdatePhotoLocation:userLocation.location];
}

//
/***********************************************
 * @description			delegate method
 ***********************************************/
//
-(void)UserDidUpdatePhotoLocation:(CLLocation*)location{
    
    if(location!=nil){
		
		_uploadImage.userLocation=location;
    
		[self updateLocationMapViewForLocation:_uploadImage.userLocation];
        
        [self initialiseViewState:PhotoWizardViewStateCategory];
    }
    
}


-(void)loadLocationFromPhoto{
	
	if(_uploadImage.location!=nil){
		
		[self updateLocationMapViewForLocation:_uploadImage.location];
		
	}
}

-(void)displayDefaultLocation{
	
	CLLocationCoordinate2D coordinate=[UserLocationManager defaultCoordinate];
	
	_locationLabel.text=[NSString stringWithFormat:@"%f, %f",coordinate.latitude,coordinate.longitude];

	[self.locationMapView setCenterCoordinate:coordinate];
	
	_userLocationAnnotation.coordinate=coordinate;
	
	[_locationMapView setCenterCoordinate:coordinate zoomLevel:16 animated:NO];
		
}

-(void)updateLocationMapViewForLocation:(CLLocation*)location{
	
	_locationLabel.text=[NSString stringWithFormat:@"%f, %f",location.coordinate.latitude,location.coordinate.longitude];
	
	[_locationMapView setCenterCoordinate:location.coordinate zoomLevel:14 animated:NO];
	
	_userLocationAnnotation.coordinate=location.coordinate;
	
}

#pragma mark - MKMap Annotations



- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
	
	if ([annotation isKindOfClass:[MKUserLocation class]])
		return nil;
	
	
	static NSString *reuseId = @"CSPhotomapAnnotation";
	CSPhotomapAnnotationView *annotationView = (CSPhotomapAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:reuseId];
	
	if (annotationView == nil){
		annotationView = [[CSPhotomapAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseId];
		annotationView.enabled=NO;
		
	} else {
		annotationView.annotation = annotation;
	}
	
	return annotationView;
}

//------------------------------------------------------------------------------------
#pragma mark - MapKit Overlays
//------------------------------------------------------------------------------------

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id <MKOverlay>)overlay{
	
	
	if ([overlay isKindOfClass:[MKTileOverlay class]]) {
		return [[MKTileOverlayRenderer alloc] initWithTileOverlay:overlay];
		
	}
	
	return nil;
}



#pragma mark - Category View
//
/***********************************************
 * @description			Category Methods
 ***********************************************/
//

-(void)initCategoryView:(PhotoWizardViewState)state{
	
	[PhotoCategoryManager sharedInstance];
	
	if(_categoryPickerView==nil)
		self.categoryPickerView=[[UIPickerView alloc]init];
	
	_categoryPickerView.backgroundColor=[UIColor whiteColor];
	_categoryPickerView.tintColor=UIColorFromRGB(0xFFFFFF);
	
	_categoryPickerView.dataSource = self;
    _categoryPickerView.delegate = self;
    _categoryField.inputView = _categoryPickerView;
	_categoryFeatureField.inputView= _categoryPickerView;
	
	
}


-(void)updateCategoryView{
	
}

-(void)resetCategoryView{
	
	_uploadImage.category=nil;
	_uploadImage.feature=nil;
	
}

-(IBAction)didDismissPickerFromToolBar:(id)sender{
	
	[self didSelectCategoryFromMenu:[_categoryPickerView selectedRowInComponent:0]];
	
    [_currentCategoryField resignFirstResponder];
}


#pragma mark - UIPicker methods

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return _activePickerDataSource.count;
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return  1;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	
	PhotoCategoryVO *vo=_activePickerDataSource[row];
	
    return vo.name;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
	
	[self didSelectCategoryFromMenu:row];
	
    [_currentCategoryField resignFirstResponder];
}


-(void)selectCategoryDataForDataType:(PhotoCategoryType)dataType{

	switch(dataType){
		
		case PhotoCategoryTypeFeature:
			self.activePickerDataSource=[[PhotoCategoryManager sharedInstance].dataProvider objectForKey:@"feature"];
		break;
		
		case PhotoCategoryTypeCategory:
			self.activePickerDataSource=[[PhotoCategoryManager sharedInstance].dataProvider objectForKey:@"category"];
		break;
	}

}


-(void)didSelectCategoryFromMenu:(NSInteger)index{
	
	PhotoCategoryVO *vo=_activePickerDataSource[index];
	
	switch(vo.categoryType){
			
		case PhotoCategoryTypeFeature:
			_uploadImage.feature=vo;
			_currentCategoryField.text=vo.name;
		break;
			
		case PhotoCategoryTypeCategory:
			_uploadImage.category=vo;
			_currentCategoryField.text=vo.name;
		break;
	}
	
	
	if(_uploadImage.feature!=nil && _uploadImage.category!=nil){
		
        [self initialiseViewState:PhotoWizardViewStateDescription];
		
		NSArray *neutralStrs=@[@"other",@"any",@"event"];
		NSString *metasuffix=_uploadImage.category.tag;
		
		if([neutralStrs indexOfObject:_uploadImage.category.tag]!=NSNotFound){
			metasuffix=@"neutral";
		}
		
		UIImage *iconimage=[UIImage imageWithPDFNamed:[NSString stringWithFormat:@"%@_%@.pdf",_uploadImage.feature.tag,metasuffix] atWidth:_categoryIconView.width];
		_categoryIconView.image=iconimage;
		
    }
	
}


#pragma mark - Description View
//
/***********************************************
 * @description			Description Methods
 ***********************************************/
//


-(void)initDescriptionView:(PhotoWizardViewState)state{

	_photodescriptionField.delegate=self;
	[self resetDescriptionField];
	
	[self initialiseViewState:PhotoWizardViewStateUpload];

}

-(void)resetDescriptionView{
	
	_photodescriptionField.text=[[StringManager sharedInstance] stringForSection:@"photowizard" andType:@"descriptionprompt"];
	_photodescriptionField.textColor=UIColorFromRGB(0x999999);
	
}


-(void)resetDescriptionField{
	
	[self resetDescriptionView];
	
	//[self removeViewState:PhotoWizardViewStateUpload];
}

-(void)updateDescriptionView{
	
	_descImagePreview.image=_uploadImage.image;
	
	if(_uploadImage.caption!=nil)
		_photodescriptionField.text=_uploadImage.caption;
    
}


#pragma mark - UITextField/View delegates

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
	
	
	switch (_viewState) {
					
		case PhotoWizardViewStateCategory:
		{
			
			if(textField.inputView!=nil){
				
				if (textField.inputAccessoryView == nil) {
					[[NSBundle mainBundle] loadNibNamed:@"UIPickerAccessoryView" owner:self options:nil];
					textField.inputAccessoryView = _pickerAccessoryView;
					self.pickerAccessoryView = nil;
				}
				
			}
			
		}
		break;
			
			
		default:
		break;
	}
	
    
    return YES;
	
}


- (void)textFieldDidBeginEditing:(UITextField *)textField{
	
	self.currentCategoryField=textField;
	
	if(_currentCategoryField ==_categoryField){
		[self selectCategoryDataForDataType:PhotoCategoryTypeCategory];
	}else if (_currentCategoryField==_categoryFeatureField){
		[self selectCategoryDataForDataType:PhotoCategoryTypeFeature];
	}
	
	[_categoryPickerView reloadAllComponents];
	
}



- (BOOL)textViewShouldBeginEditing:(UITextView *)aTextView {
	
	switch (_viewState) {
		case PhotoWizardViewStateDescription:
		{
			if (_photodescriptionField.inputAccessoryView == nil) {
				[[NSBundle mainBundle] loadNibNamed:@"UITextViewAccessoryView" owner:self options:nil];
				_photodescriptionField.inputAccessoryView = _textViewAccessoryView;
				self.textViewAccessoryView = nil;
			}
			
			if([_photodescriptionField.text isEqualToString:[[StringManager sharedInstance] stringForSection:@"photowizard" andType:@"descriptionprompt"]]){
				_photodescriptionField.text=@"";
				_photodescriptionField.textColor=UIColorFromRGB(0x555555);
			}
			
			
		}
		break;
			
		case PhotoWizardViewStateCategory:
			
			
			
			
		break;
		
			
		default:
			break;
	}
   
    
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
	
	if(textView.text.length==0){
		[self resetDescriptionField];
	}
	
}

-(IBAction)textViewKeyboardShouldClear:(id)sender{
	
	[self resetDescriptionField];
	
}

-(IBAction)textViewKeyboardShouldHide:(id)sender{
	
	if(![_photodescriptionField.text isEqualToString:[[StringManager sharedInstance] stringForSection:@"photowizard" andType:@"descriptionprompt"]]){
        [self initialiseViewState:PhotoWizardViewStateUpload];
		_uploadImage.caption=_photodescriptionField.text;
    }
	
	[_photodescriptionField resignFirstResponder];
	
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
	
	switch (_viewState) {
		case PhotoWizardViewStateDescription:
		{
			if([text isEqualToString:EMPTYSTRING] && range.length > 0){
				
				NSString *prompttext=[[StringManager sharedInstance] stringForSection:@"photowizard" andType:@"descriptionprompt"];
				if([_photodescriptionField.text containsString:prompttext]){
					_photodescriptionField.text=[_photodescriptionField.text stringByReplacingOccurrencesOfString:prompttext withString:EMPTYSTRING];;
					_photodescriptionField.textColor=UIColorFromRGB(0x555555);
					return YES;
				}
				
			}
			
		}
			break;
			
		default:
			return YES;
			break;
			
	}
	
	return YES;
}

- (void)textViewDidChange:(UITextView *)textView{
	
	switch (_viewState) {
		case PhotoWizardViewStateDescription:
		{
			NSString *prompttext=[[StringManager sharedInstance] stringForSection:@"photowizard" andType:@"descriptionprompt"];
			if([_photodescriptionField.text containsString:prompttext]){
			_photodescriptionField.text=[_photodescriptionField.text stringByReplacingOccurrencesOfString:prompttext withString:EMPTYSTRING];;
			_photodescriptionField.textColor=UIColorFromRGB(0x555555);
			return;
			}
			
			if(_photodescriptionField.text.length==0){
				[self resetDescriptionField];
				return;
			}
			
			_photodescriptionField.textColor=UIColorFromRGB(0x555555);
			
			_uploadImage.caption=textView.text;
			
		}
		break;
			
		default:
			
			break;
			
	}
	
    
}


#pragma mark - Upload View
//
/***********************************************
 * @description			Upload Methods
 ***********************************************/
//


-(void)initUploadView:(PhotoWizardViewState)state{
	
	[self updateUploadUIState:@"waiting"];
	
	[ButtonUtilities stylePixateIBButton:_uploadButton styleId:@"OrangeButton" type:@"orange" text:@"Upload Photo"];
	[_uploadButton addTarget:self action:@selector(uploadPhoto:) forControlEvents:UIControlEventTouchUpInside];
	
}

-(void)updateUploadView{
	_uploadProgressView.progress=0;
}


-(IBAction)uploadPhoto:(id)sender{
	
	
	if(_uploadImage.image==nil){
		[[HudManager sharedInstance]showHudWithType:HUDWindowTypeError withTitle:@"Image missing" andMessage:@"You haven't selected an image to upload, please check and try again." andDelay:3 andAllowTouch:NO];
		return;
	}

	
    if ([UserAccount sharedInstance].isLoggedIn==NO) {
		
		if([UserAccount sharedInstance].accountMode==kUserAccountCredentialsExist){
			
			BetterLog(@"kUserAccountCredentialsExist");
			
			[[PhotoManager sharedInstance] UserPhotoUploadRequest:_uploadImage];
			
			[self updateUploadUIState:@"loading"];
			
		}else {
			
			BetterLog(@"kUserAccountNotLoggedIn");
			
			
			if (self.loginView == nil) {
				self.loginView = [[AccountViewController alloc] initWithNibName:@"AccountView" bundle:nil];
			}
			self.loginView.isModal=YES;
			self.loginView.shouldAutoClose=YES;
			UINavigationController *nav=[[UINavigationController alloc]initWithRootViewController:self.loginView];
			[self presentModalViewController:nav animated:YES];
			 
		}
        
		
		
	} else {
		
		BetterLog(@"kUserAccountLoggedIn");
		
		[[PhotoManager sharedInstance] UserPhotoUploadRequest:_uploadImage];
		
		[self updateUploadUIState:@"loading"];
	}
	
	
	
}


-(void)updateUploadUIState:(NSString*)state{
	
	
	if([state isEqualToString:@"loading"]){
		
		_uploadLabel.textColor=[UIColor darkGrayColor];
		_uploadLabel.text=@"Uploading...";
		_uploadButton.enabled=NO;
		
	}else if([state isEqualToString:@"error"]){
		
		_uploadLabel.textColor=UIColorFromRGB(0xC20000);
		_uploadLabel.text=@"An error occured while uploading your image, please try again.";
		_uploadButton.enabled=YES;
		_uploadProgressView.progress=0;
		
	}else {
		
		_uploadLabel.textColor=[UIColor darkGrayColor];
		_uploadLabel.text=@"Ready to upload";
		_uploadButton.enabled=YES;
	}
	
	
	
}



-(IBAction)cancelUploadPhoto:(id)sender{
	
    _uploadProgressView.progress=0;
	
}



//
/***********************************************
 * @description			Complete View
 ***********************************************/
//

-(void)initCompleteView:(PhotoWizardViewState)state{
	
	BetterLog(@"");
	
	self.cancelButton.titleLabel.text=@"Done";
	self.cancelViewButton.title=@"Close";
	
	
	[_photoMapButton addTarget:self action:@selector(photoMapButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
	
    _photoResultURLLabel.text=[_uploadImage.responseDict objectForKey:@"url"];
	
	
}

-(void)updateCompleteView{
	
	BetterLog(@"");
	
	_pageControl.numberOfPages=1;
	[_pageControl updateCurrentPageDisplay];
	_maxVisitedPage=0;
	_pageScrollView.scrollEnabled=NO;
	
	
}




-(IBAction)photoMapButtonSelected:(id)sender{
	
	
	[PhotoManager sharedInstance].autoLoadLocation=_uploadImage.activeLocation;
	
	if(_isModal==YES){
	
		[self closeWindowButtonSelected:nil];
		
	}else{
		
		
		AppDelegate *appDelegate=(AppDelegate*)[[UIApplication sharedApplication] delegate];
		[appDelegate showTabBarViewControllerByName:TABBAR_REPORT];
		
		[self resetPhotoWizard];
		
	}
	
	
}



#pragma mark Generic
//
/***********************************************
 * @description			generic
 ***********************************************/
//



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end
