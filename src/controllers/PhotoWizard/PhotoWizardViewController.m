//
//  PhotoWizardViewController.m
//  CycleStreets
//
//  Created by neil on 28/02/2012.
//  Copyright (c) 2012 CycleStreets Ltd. All rights reserved.
//

#import "PhotoWizardViewController.h"
#import "ImageManipulator.h"
#import "UploadPhotoVO.h"
#import "GlobalUtilities.h"
#import "RMMarkerManager.h"
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
#import "Markers.h"
#import <ImageIO/ImageIO.h>

static NSString *const LOCATIONSUBSCRIBERID=@"PhotoWizard";



@interface PhotoWizardViewController()




@property (nonatomic, assign) PhotoWizardViewState viewState;
@property (nonatomic, strong) IBOutlet UIScrollView *pageScrollView;
@property (nonatomic, strong) IBOutlet UIPageControl *pageControl;
@property (nonatomic, strong) IBOutlet UIView *headerView;
@property (nonatomic, strong) IBOutlet UIView *footerView;
@property (nonatomic, strong) LayoutBox *pageContainer;
@property (nonatomic, assign) int activePage;
@property (nonatomic, assign) int maxVisitedPage;
@property (nonatomic, strong) NSMutableArray *viewArray;
@property (nonatomic, strong) IBOutlet UIToolbar *modalToolBar;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *cancelViewButton;
@property (nonatomic, strong) IBOutlet UIButton *nextButton;
@property (nonatomic, strong) IBOutlet UIButton *prevButton;
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
@property (nonatomic, strong) IBOutlet RMMapView *locationMapView;
@property (nonatomic, strong) RMMapContents *locationMapContents;
@property (nonatomic, strong) RMMarker *locationMapMarker;
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
@property (nonatomic, strong) IBOutlet UIButton *categoryButton;
@property (nonatomic, strong) IBOutlet UIButton *categoryFeaturebutton;
@property (nonatomic, strong) PhotoWizardCategoryMenuViewController *categoryMenuView;
@property (nonatomic, strong) IBOutlet UIView *photodescriptionView;
@property (nonatomic, strong) IBOutlet UIView *textViewAccessoryView;
@property (nonatomic, strong) IBOutlet UIImageView *descImagePreview;
@property (nonatomic, strong) IBOutlet UITextView *photodescriptionField;
@property (nonatomic, strong) IBOutlet UIView *photoUploadView;
@property (nonatomic, strong) IBOutlet UIButton *uploadButton;
@property (nonatomic, strong) IBOutlet UIButton *cancelButton;
@property (nonatomic, strong) IBOutlet UIProgressView *uploadProgressView;
@property (nonatomic, strong) IBOutlet ExpandedUILabel *uploadLabel;
//@property (nonatomic, strong) AccountViewController *loginView;
@property (nonatomic, strong) IBOutlet UIView *photoResultView;
@property (nonatomic, strong) IBOutlet CopyLabel *photoResultURLLabel;
@property (nonatomic, strong) IBOutlet UIButton *photoMapButton;
@property (nonatomic, strong) WEPopoverController *categoryMenu;



-(RMMarker*)retrieveLocationMapMarker;

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
-(IBAction)showCategoryMenu:(id)sender;
-(void)didSelectCategoryFromMenu:(NSNotification*)notification;

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
- (void)startlocationManagerIsLocating;
- (void)stoplocationManagerIsLocating;
- (void)PanGestureCaptured:(UIPanGestureRecognizer *)gesture;

-(void)updateSelectionLabels;

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
	
	if([notification.name isEqualToString:PHOTOWIZARDCATEGORYUPDATE]){
        [self didSelectCategoryFromMenu:notification];
    }
	
	if([notification.name isEqualToString:USERACCOUNTLOGINSUCCESS]){
        [self autoUploadUserPhoto];
    }
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



- (void)viewDidLoad {
	
	
    [super viewDidLoad];
    
	[self createPersistentUI];
	
	
}


-(void)createPersistentUI{
    
    
	popoverClass = [WEPopoverController class];
	
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
	_pageScrollView.backgroundColor=UIColorFromRGB(0xDBD8D3);
	_pageScrollView.delegate=self;
	_pageControl.hidesForSinglePage=YES;
    _pageControl.numberOfPages=1;
	[_pageControl addTarget:self action:@selector(pageControlValueChanged:) forControlEvents:UIControlEventValueChanged];
	
	
	[self createNavigationBarUI];

	
	[self initialiseViewState:PhotoWizardViewStateInfo];
    
}


-(void)createNavigationBarUI{
	
	if(_isModal!=YES){
		
		self.navigationItem.backBarButtonItem.tintColor=UIColorFromRGB(0xA71D1D);
		
		
		self.prevButton=[ButtonUtilities UIButtonWithWidth:10 height:32 type:@"barbuttongreen" text:@"Previous"];
		[_prevButton addTarget:self action:@selector(navigateToPreviousView:) forControlEvents:UIControlEventTouchUpInside];
		self.nextButton=[ButtonUtilities UIButtonWithWidth:10 height:32 type:@"barbuttongreen" text:@"Next"];
		[_nextButton addTarget:self action:@selector(navigateToNextView:) forControlEvents:UIControlEventTouchUpInside];
		
		
		self.navigationItem.title=@"";
		
		LayoutBox *containerView=[[LayoutBox alloc] initWithFrame:CGRectMake(0, 0, 10, 32)];
		containerView.itemPadding=5;
		[containerView addSubview:_prevButton];
		[containerView addSubview:_nextButton];
			
		self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithCustomView:containerView];
			
		
		
		_pageScrollView.y=20;
		_headerView.y=0;
		_pageControl.y=0;
		
	}
	
	_modalToolBar.visible=_isModal;
	
}


-(void)viewWillAppear:(BOOL)animated{
	
   [self createNonPersistentUI];
	
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
	
	
	if(state>_maxVisitedPage){
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
    _pageNumberLabel.text=[NSString stringWithFormat:@"%i of %i",_activePage+1, [_viewArray count]];
	
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


#pragma mark Paging
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
	
	[ButtonUtilities styleIBButton:_continueButton type:@"green" text:@"Continue"];
	[_continueButton addTarget:self action:@selector(continueUploadbuttonSelected:) forControlEvents:UIControlEventTouchUpInside];
	
}

-(IBAction)continueUploadbuttonSelected:(id)sender{
    
	[self initialiseViewState:PhotoWizardViewStatePhoto];
	[self navigateToViewState:PhotoWizardViewStatePhoto];
    
}




#pragma mark Photo View
//
/***********************************************
 * @description			PhotoPicker methods
 ***********************************************/
//

-(void)initPhotoView:(PhotoWizardViewState)state{
	
	_imagePreview.image=nil;
	
	[ButtonUtilities styleIBButton:_cameraButton type:@"green" text:@"Camera"];
	[_cameraButton addTarget:self action:@selector(cameraButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
	[ButtonUtilities styleIBButton:_libraryButton type:@"green" text:@"Library"];
	[_libraryButton addTarget:self action:@selector(libraryButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
	
	[_cameraButton setEnabled:[UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]];
	[_libraryButton setEnabled:[UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]];
	
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
		[self presentModalViewController:picker animated:YES];
		
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
		[self presentModalViewController:picker animated:YES];
	}
	else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error accessing photo library" 
														message:@"Device does not support a photo library" 
													   delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
		[alert show];
	}
	
	
}


#pragma mark imagePickerController  Delegate methods -
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	
	// TODO: image should be sized, a) on screen & b) upload size
    // initial image should be max resolution possible for app
    // setttings.imageSize 
	UIImage *image=[info objectForKey:UIImagePickerControllerOriginalImage];
    self.uploadImage=[[UploadPhotoVO alloc]initWithImage:image];
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
	
    
	[picker dismissModalViewControllerAnimated:YES];	
	
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
	[picker dismissModalViewControllerAnimated:YES];
}


#pragma mark Location View
//
/***********************************************
 * @description			LOCATION METHODS
 ***********************************************/
//

// Uses normal map logic

-(void)initLocationView:(PhotoWizardViewState)state{
	
	BetterLog(@"");
	
	[ButtonUtilities styleIBButton:_locationUpdateButton type:@"green" text:@"Edit Location"];
	[_locationUpdateButton addTarget:self action:@selector(locationButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
	
	[RMMapView class];
	_locationMapContents=[[RMMapContents alloc] initWithView:_locationMapView tilesource:[[self class] tileSource]];
	[_locationMapView setDelegate:self];
	_locationMapView.userInteractionEnabled=NO;
	
	[self retrieveLocationMapMarker];
	
	[self loadLocationFromPhoto];
		
}


-(RMMarker*)retrieveLocationMapMarker{
	
	if (self.locationMapMarker==nil) {
		self.locationMapMarker = [Markers markerPhoto];
		self.locationMapMarker.enableDragging=YES;
	}
	
	return self.locationMapMarker;
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
				[[UserLocationManager sharedInstance] startUpdatingLocationForSubscriber:LOCATIONSUBSCRIBERID];
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

	[self.locationMapView moveToLatLong:coordinate];
	
	[_locationMapView.markerManager addMarker:[self retrieveLocationMapMarker] AtLatLong:coordinate];
	
	[_locationMapView.contents setZoom:6];
		
}

-(void)updateLocationMapViewForLocation:(CLLocation*)location{
	
	
	_locationLabel.text=[NSString stringWithFormat:@"%f, %f",location.coordinate.latitude,location.coordinate.longitude];
	
	[self.locationMapView moveToLatLong:location.coordinate];
	
	if ([_locationMapView.contents zoom] < 18) {
		[_locationMapView.contents setZoom:14];
	}
	

	
	[_locationMapView.markerManager addMarker:[self retrieveLocationMapMarker] AtLatLong:location.coordinate];
	
	
}



#pragma mark Category View
//
/***********************************************
 * @description			Category Methods
 ***********************************************/
//

-(void)initCategoryView:(PhotoWizardViewState)state{
	
	[PhotoCategoryManager sharedInstance];
	
	[ButtonUtilities styleIBButton:_categoryButton type:@"orange" text:@"Choose..."];
	[ButtonUtilities styleIBButton:_categoryFeaturebutton type:@"green" text:@"Choose..."];
	
	[_categoryButton addTarget:self action:@selector(showCategoryMenu:) forControlEvents:UIControlEventTouchUpInside];
	[_categoryFeaturebutton addTarget:self action:@selector(showCategoryMenu:) forControlEvents:UIControlEventTouchUpInside];
	
	
}


-(void)updateCategoryView{
	
}

-(void)resetCategoryView{
	
	[ButtonUtilities styleIBButton:_categoryButton type:@"orange" text:@"Choose..."];
	[ButtonUtilities styleIBButton:_categoryFeaturebutton type:@"green" text:@"Choose..."];
	
	_uploadImage.category=nil;
	_uploadImage.feature=nil;
	
}



-(IBAction)showCategoryMenu:(id)sender{
	
	UIButton *button=(UIButton*)sender;
	PhotoCategoryType dataType=button.tag;
	
    self.categoryMenuView=[[PhotoWizardCategoryMenuViewController alloc]initWithNibName:@"PhotoWizardCategoryMenuView" bundle:nil];
	_categoryMenuView.dataType=dataType;
	_categoryMenuView.uploadImage=_uploadImage;
	
	switch(dataType){
		
		case PhotoCategoryTypeFeature:
			_categoryMenuView.dataProvider=[[PhotoCategoryManager sharedInstance].dataProvider objectForKey:@"feature"];
		break;
		
		case PhotoCategoryTypeCategory:
			_categoryMenuView.dataProvider=[[PhotoCategoryManager sharedInstance].dataProvider objectForKey:@"category"];
		break;
	}
	
	self.categoryMenu = [[popoverClass alloc] initWithContentViewController:_categoryMenuView];
	self.categoryMenu.delegate = self;
	
	[self.categoryMenu presentPopoverFromRect:button.frame inView:self.categoryView permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
    
	
}


-(void)didSelectCategoryFromMenu:(NSNotification*)notification{
	
	NSDictionary *userInfo=notification.userInfo;
	
	PhotoCategoryVO *vo=[userInfo objectForKey:@"dataProvider"];
	PhotoCategoryType dataType=[[userInfo objectForKey:@"dataType"]intValue];
	
	switch(dataType){
			
		case PhotoCategoryTypeFeature:
			_uploadImage.feature=vo;
			[_categoryFeaturebutton setTitle:_uploadImage.feature.name forState:UIControlStateNormal];
		break;
			
		case PhotoCategoryTypeCategory:
			_uploadImage.category=vo;
			[_categoryButton setTitle:_uploadImage.category.name forState:UIControlStateNormal];
		break;
	}
	
	[_categoryMenu dismissPopoverAnimated:YES];
	
	if(_uploadImage.feature!=nil && _uploadImage.category!=nil){
        [self initialiseViewState:PhotoWizardViewStateDescription];
    }
	
}


#pragma mark -
#pragma mark WEPopoverControllerDelegate implementation

- (void)popoverControllerDidDismissPopover:(WEPopoverController *)thePopoverController {
	self.categoryMenu = nil;
}

- (BOOL)popoverControllerShouldDismissPopover:(WEPopoverController *)thePopoverController {
	return YES;
}

#pragma mark Description View
//
/***********************************************
 * @description			Description Methods
 ***********************************************/
//


-(void)initDescriptionView:(PhotoWizardViewState)state{

	_photodescriptionField.delegate=self;
	[self resetDescriptionField];

}

-(void)resetDescriptionView{
	
	_photodescriptionField.text=[[StringManager sharedInstance] stringForSection:@"photowizard" andType:@"descriptionprompt"];
	_photodescriptionField.textColor=UIColorFromRGB(0x999999);
	
}


-(void)resetDescriptionField{
	
	[self resetDescriptionView];
	
	[self removeViewState:PhotoWizardViewStateUpload];
}

-(void)updateDescriptionView{
	
	_descImagePreview.image=_uploadImage.image;
	
	if(_uploadImage.caption!=nil)
		_photodescriptionField.text=_uploadImage.caption;
    
}


- (BOOL)textViewShouldBeginEditing:(UITextView *)aTextView {
   
    if (_photodescriptionField.inputAccessoryView == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"UITextViewAccessoryView" owner:self options:nil];
        _photodescriptionField.inputAccessoryView = _textViewAccessoryView;
        self.textViewAccessoryView = nil;
    }
	
	 if([_photodescriptionField.text isEqualToString:[[StringManager sharedInstance] stringForSection:@"photowizard" andType:@"descriptionprompt"]]){
		 _photodescriptionField.text=@"";
		 _photodescriptionField.textColor=UIColorFromRGB(0x555555);
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


- (void)textViewDidChange:(UITextView *)textView{
	
	if([_photodescriptionField.text isEqualToString:[[StringManager sharedInstance] stringForSection:@"photowizard" andType:@"descriptionprompt"]]){
		_photodescriptionField.text=@"";
		_photodescriptionField.textColor=UIColorFromRGB(0x555555);
		return;
	}
	
	if(_photodescriptionField.text.length==0){
		[self resetDescriptionField];
		return;
	}
	
	_photodescriptionField.textColor=UIColorFromRGB(0x555555);
	
    
}


#pragma mark Upload View
//
/***********************************************
 * @description			Upload Methods
 ***********************************************/
//


-(void)initUploadView:(PhotoWizardViewState)state{
	
	[self updateUploadUIState:@"waiting"];
	
	
	
	[ButtonUtilities styleIBButton:_uploadButton type:@"orange" text:@"Upload Photo"];
	[_uploadButton addTarget:self action:@selector(uploadPhoto:) forControlEvents:UIControlEventTouchUpInside];
	
}

-(void)updateUploadView{
	_uploadProgressView.progress=0;
}


-(IBAction)uploadPhoto:(id)sender{
	
	/*
    if ([UserAccount sharedInstance].isLoggedIn==NO) {
		
		if([UserAccount sharedInstance].accountMode==kUserAccountCredentialsExist){
			
			BetterLog(@"kUserAccountCredentialsExist");
			
			[[PhotoManager sharedInstance] UserPhotoUploadRequest:_uploadImage];
			
			[self updateUploadUIState:@"loading"];
			
		}else {
			
			BetterLog(@"kUserAccountNotLoggedIn");
			
			if (self.loginView == nil) {
				self.loginView = [[UISplitViewController alloc] initWithNibName:@"AccountView" bundle:nil];
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
	
	 */
	
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
	
	
	[ButtonUtilities styleIBButton:_photoMapButton type:@"orange" text:@"View map"];
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
		[appDelegate showTabBarViewControllerByName:@"Photomap"];
		
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
