//
//  PhotoWizardViewController.m
//  CycleStreets
//
//  Created by neil on 28/02/2012.
//  Copyright (c) 2012 CycleStreets Ltd. All rights reserved.
//

#import "PhotoWizardViewController.h"
#import "MapViewController.h"
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
#import "MapViewController.h"
#import "Markers.h"
#import <ImageIO/ImageIO.h>

static NSString *const LOCATIONSUBSCRIBERID=@"PhotoWizard";



@interface PhotoWizardViewController(Private)

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
@synthesize viewState;
@synthesize pageScrollView;
@synthesize pageControl;
@synthesize headerView;
@synthesize footerView;
@synthesize pageContainer;
@synthesize activePage;
@synthesize maxVisitedPage;
@synthesize viewArray;
@synthesize isModal;
@synthesize nextButton;
@synthesize prevButton;
@synthesize pageTitleLabel;
@synthesize pageNumberLabel;
@synthesize locationsc;
@synthesize locpangesture;
@synthesize uploadImage;
@synthesize infoView;
@synthesize continueButton;
@synthesize photoPickerView;
@synthesize imagePreview;
@synthesize photoSizeLabel;
@synthesize photolocationLabel;
@synthesize photodateLabel;
@synthesize cameraButton;
@synthesize libraryButton;
@synthesize photoLocationView;
@synthesize locationMapView;
@synthesize locationMapContents;
@synthesize locationMapMarker;
@synthesize locationLabel;
@synthesize locationUpdateButton;
@synthesize locationResetButton;
@synthesize avoidAccidentalTaps;
@synthesize singleTapDidOccur;
@synthesize singleTapPoint;
@synthesize locationManagerIsLocating;
@synthesize categoryView;
@synthesize categoryTypeLabel;
@synthesize categoryDescLabel;
@synthesize pickerView;
@synthesize categoryButton;
@synthesize categoryFeaturebutton;
@synthesize categoryMenuView;
@synthesize photodescriptionView;
@synthesize textViewAccessoryView;
@synthesize descImagePreview;
@synthesize photodescriptionField;
@synthesize photoUploadView;
@synthesize uploadButton;
@synthesize cancelButton;
@synthesize uploadProgressView;
@synthesize uploadLabel;
@synthesize loginView;
@synthesize photoResultView;
@synthesize photoResultURLLabel;
@synthesize photoMapButton;
@synthesize categoryMenu;
@synthesize cancelViewButton;



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
	
    uploadProgressView.progress=percent;
    
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
	
    viewState=PhotoWizardViewStateInfo;
	activePage=0;
	maxVisitedPage=-1;
	
	// set up scroll view with layoutbox for sub items
	self.pageContainer=[[LayoutBox alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 10)];
	pageContainer.layoutMode=BUHorizontalLayoutMode;
	
    
    self.viewArray=[NSMutableArray arrayWithObjects:
					[NSMutableDictionary dictionaryWithObjectsAndKeys:infoView, @"view", @"Information",@"title",BOX_BOOL(NO),@"created",nil],
					[NSMutableDictionary dictionaryWithObjectsAndKeys:photoPickerView, @"view",@"Photo Picker",@"title" ,BOX_BOOL(NO),@"created",nil],
					[NSMutableDictionary dictionaryWithObjectsAndKeys:photoLocationView, @"view",@"Location",@"title" ,BOX_BOOL(NO),@"created",nil],
					[NSMutableDictionary dictionaryWithObjectsAndKeys:categoryView, @"view",@"Photo Category",@"title" ,BOX_BOOL(NO),@"created",nil],
					[NSMutableDictionary dictionaryWithObjectsAndKeys:photodescriptionView, @"view",@"Description",@"title" ,BOX_BOOL(NO),@"created",nil],
					[NSMutableDictionary dictionaryWithObjectsAndKeys:photoUploadView, @"view",@"Upload",@"title",BOX_BOOL(NO),@"created",nil],
					[NSMutableDictionary dictionaryWithObjectsAndKeys:photoResultView, @"view", @"Result",@"title",BOX_BOOL(NO),@"created",nil],nil ];
    
	[pageScrollView addSubview:pageContainer];
	 
	pageScrollView.pagingEnabled=YES;
	pageScrollView.backgroundColor=UIColorFromRGB(0xDBD8D3);
	pageScrollView.delegate=self;
	pageControl.hidesForSinglePage=YES;
    pageControl.numberOfPages=1;
	[pageControl addTarget:self action:@selector(pageControlValueChanged:) forControlEvents:UIControlEventValueChanged];
	
	
	[self createNavigationBarUI];

	
	[self initialiseViewState:PhotoWizardViewStateInfo];
    
}


-(void)createNavigationBarUI{
	
	if(isModal!=YES){
		
		self.navigationItem.backBarButtonItem.tintColor=UIColorFromRGB(0xA71D1D);
		
		
		self.prevButton=[ButtonUtilities UIButtonWithWidth:10 height:32 type:@"barbuttongreen" text:@"Previous"];
		[prevButton addTarget:self action:@selector(navigateToPreviousView:) forControlEvents:UIControlEventTouchUpInside];
		self.nextButton=[ButtonUtilities UIButtonWithWidth:10 height:32 type:@"barbuttongreen" text:@"Next"];
		[nextButton addTarget:self action:@selector(navigateToNextView:) forControlEvents:UIControlEventTouchUpInside];
		
		
		self.navigationItem.title=@"";
		
		LayoutBox *containerView=[[LayoutBox alloc] initWithFrame:CGRectMake(0, 0, 10, 32)];
		containerView.itemPadding=5;
		[containerView addSubview:prevButton];
		[containerView addSubview:nextButton];
			
		self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithCustomView:containerView];
			
		
		
		pageScrollView.y=20;
		headerView.y=0;
		footerView.y=387;
		pageControl.y=0;
		
	}
	
}


-(void)viewWillAppear:(BOOL)animated{
	
   [self createNonPersistentUI];
	
    [super viewWillAppear:animated];
}


// intercept back event to reset pw if we are on Complete state
-(void) viewWillDisappear:(BOOL)animated {
	
	if(viewState==PhotoWizardViewStateResult){
	
		if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
			[self resetPhotoWizard];
		}
		
	}
		
    [super viewWillDisappear:animated];
}


-(void)createNonPersistentUI{
    
   
    
}




-(void)resetPhotoWizard{
	
	viewState=PhotoWizardViewStateInfo;
	activePage=0;
	maxVisitedPage=-1;
	
	[pageContainer removeAllSubViews];
	
	for(NSMutableDictionary *viewDict in viewArray){
		
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
	
	NSMutableDictionary *viewdict=[viewArray objectAtIndex:state];
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
	
	
	if(state>maxVisitedPage){
		maxVisitedPage=state;
	}
	
	if (maxVisitedPage==activePage) {
		nextButton.enabled=NO;
	}else {
		nextButton.enabled=YES;
	}
	
	if (activePage==0) {
		prevButton.enabled=NO;
	}else {
		prevButton.enabled=YES;
	}
	
	[self updatePageControlExtents];
	
}


-(void)removeViewState:(PhotoWizardViewState)state{
	
	BetterLog(@"");
    
    maxVisitedPage=state-1;
	
	if (maxVisitedPage==activePage) {
		nextButton.enabled=NO;
	}else {
		nextButton.enabled=YES;
	}
    
	[self updatePageControlExtents];
}

-(void)resetToViewState:(PhotoWizardViewState)state{
	
	BetterLog(@"");
    
    maxVisitedPage=state-1;
	activePage=state;
	viewState=state;
	pageControl.currentPage=viewState;
	
	if (maxVisitedPage==activePage) {
		nextButton.enabled=NO;
	}else {
		nextButton.enabled=YES;
	}
	
	CGPoint offset=CGPointMake(viewState*SCREENWIDTH, 0);
	[pageScrollView setContentOffset:offset animated:YES];
	
    
	[self updatePageControlExtents];
}


//
/***********************************************
 * @description			scroll To ViewState if initialised
 ***********************************************/
//
-(void)navigateToViewState:(PhotoWizardViewState)state{
	
	BetterLog(@"");
	
	if(state<=maxVisitedPage){
		

		viewState=state;
		pageControl.currentPage=viewState;
		activePage=viewState;
        
		CGPoint offset=CGPointMake(viewState*SCREENWIDTH, 0);
		[pageScrollView setContentOffset:offset animated:YES];
		
		[self updateGlobalViewUIForState];
		
		
		
    }
	
	
}


-(IBAction)navigateToNextView:(id)sender{
	
	if(activePage<maxVisitedPage){
		[self navigateToViewState:activePage+1];
	}

}

-(IBAction)navigateToPreviousView:(id)sender{
	
	if(activePage>0){
		[self navigateToViewState:activePage-1];
	}
	
}


-(IBAction)closeWindowButtonSelected:(id)sender{
	
	[self dismissModalViewControllerAnimated:YES];
	
}


-(void)updateGlobalViewUIForState{
	
	BetterLog(@"");
	
	pageTitleLabel.text=[[viewArray objectAtIndex:activePage] objectForKey:@"title"];
    pageNumberLabel.text=[NSString stringWithFormat:@"%i of %i",activePage+1, [viewArray count]];
	
	[self updateView];
	
	if (maxVisitedPage==activePage) {
		nextButton.enabled=NO;
	}else {
		nextButton.enabled=YES;
	}
	
	if (activePage==0) {
		prevButton.enabled=NO;
	}else {
		prevButton.enabled=YES;
	}
	
	if (activePage==PhotoWizardViewStateResult) {
		prevButton.enabled=NO;
		nextButton.enabled=NO;
	}
	
}

-(void)updateView{
	
	
	switch (viewState) {
			
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
	UIScrollView *sc=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH, pageScrollView.height)];
	UIView *stateview=[viewDict objectForKey:@"view"];
	
	[sc addSubview:stateview];
	[sc setContentSize:CGSizeMake(SCREENWIDTH, stateview.height)];
	[pageContainer addSubview:sc];
		
	[pageScrollView setContentSize:CGSizeMake(pageContainer.width, pageScrollView.height)];
	
}


#pragma mark Paging
//
/***********************************************
 * @description			PAGE EVENTS
 ***********************************************/
//

-(void)scrollViewDidEndDecelerating:(UIScrollView *)sc{
	BetterLog(@"");
	CGPoint offset=pageScrollView.contentOffset;
	activePage=offset.x/SCREENWIDTH;
	pageControl.currentPage=activePage;
	viewState=activePage;
	[pageControl updateCurrentPageDisplay];
	[self updateGlobalViewUIForState];
}


-(IBAction)pageControlValueChanged:(id)sender{
	BetterLog(@"");
	UIPageControl *pc=(UIPageControl*)sender;
    if(pc.currentPage<=maxVisitedPage){
        CGPoint offset=CGPointMake(pc.currentPage*SCREENWIDTH, 0);
        [pageScrollView setContentOffset:offset animated:YES];
		activePage=pc.currentPage;
		
    }else{
        pc.currentPage=activePage;
    }
	
}
-(void)scrollViewDidEndScrollingAnimation:(UIScrollView*)sc{
	BetterLog(@"");
	[self scrollViewDidEndDecelerating:pageScrollView];
	[self updatePageControlExtents];
}


-(void)updatePageControlExtents{
	
	BetterLog(@"");
	
	pageControl.numberOfPages=maxVisitedPage+1;
	
	
	
}


//
/***********************************************
 * @description			View info methods
 ***********************************************/
//

-(void)initInfoView:(PhotoWizardViewState)state{
	
	[ButtonUtilities styleIBButton:continueButton type:@"green" text:@"Continue"];
	[continueButton addTarget:self action:@selector(continueUploadbuttonSelected:) forControlEvents:UIControlEventTouchUpInside];
	
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
	
	imagePreview.image=nil;
	
	[ButtonUtilities styleIBButton:cameraButton type:@"green" text:@"Camera"];
	[cameraButton addTarget:self action:@selector(cameraButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
	[ButtonUtilities styleIBButton:libraryButton type:@"green" text:@"Library"];
	[libraryButton addTarget:self action:@selector(libraryButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
	
	[cameraButton setEnabled:[UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]];
	[libraryButton setEnabled:[UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]];
	
}

-(void)updatePhotoView{
	
	if(uploadImage!=nil){
        imagePreview.image=uploadImage.image;
        photoSizeLabel.text=[NSString stringWithFormat:@"%i x %i",uploadImage.width, uploadImage.height];
		photodateLabel.text=[NSString stringWithFormat:@"%@",uploadImage.dateString];
    }else{
		photoSizeLabel.text=EMPTYSTRING;
		photolocationLabel.text=EMPTYSTRING;
		photodateLabel.text=EMPTYSTRING;
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
	imagePreview.image=uploadImage.image;
	photoSizeLabel.text=[NSString stringWithFormat:@"%i x %i",uploadImage.width, uploadImage.height];
	
	
	NSURL *referenceURL = [info objectForKey:UIImagePickerControllerReferenceURL];
	ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
	
	[library assetForURL:referenceURL resultBlock:^(ALAsset *asset){
		
		ALAssetRepresentation *rep = [asset defaultRepresentation];
        NSDictionary *metadata = rep.metadata;
		NSDictionary *gpsDict = [metadata objectForKey:(NSString *)kCGImagePropertyGPSDictionary];
        
		if(gpsDict!=nil){
			uploadImage.bearing=[[gpsDict objectForKey:@"ImgDirection"] intValue];
		}
		
		CLLocation *location = (CLLocation *)[asset valueForProperty:ALAssetPropertyLocation];
		uploadImage.location=location;
		
		NSDate		*assetdate=(NSDate*)[asset valueForProperty:ALAssetPropertyDate];
		uploadImage.date=assetdate;
		
		photolocationLabel.text=[[GlobalUtilities convertBooleanToType:@"string" :location!=nil] capitalizedString];
		photodateLabel.text=[NSString stringWithFormat:@"%@",uploadImage.dateString];
		
		if(location!=nil)
			BetterLog(@"location=%f %f",location.coordinate.latitude, location.coordinate.longitude);
		
		
	} failureBlock:^(NSError *error) {
		 BetterLog(@"error retrieving image from  - %@",[error localizedDescription]);
	 }];
	
    
	[picker dismissModalViewControllerAnimated:YES];	
	
	// ensure further screens are reset
	[self initialiseViewState:PhotoWizardViewStateLocation];
	
	 
	 NSMutableDictionary *viewdict=[viewArray objectAtIndex:PhotoWizardViewStateCategory];
	 if([viewdict objectForKey:@"created"]==BOX_BOOL(YES)){
		 
		 maxVisitedPage=PhotoWizardViewStateLocation;
	
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
	
	[ButtonUtilities styleIBButton:locationUpdateButton type:@"green" text:@"Edit Location"];
	[locationUpdateButton addTarget:self action:@selector(locationButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
	
	[RMMapView class];
	locationMapContents=[[RMMapContents alloc] initWithView:locationMapView tilesource:[MapViewController tileSource]];
	[locationMapView setDelegate:self];
	locationMapView.userInteractionEnabled=NO;
	
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
	
	CLLocationCoordinate2D imageloc=uploadImage.location.coordinate;
	CLLocationCoordinate2D zeroloc=CLLocationCoordinate2DMake(0,0);
	
	MKMapPoint p1 = MKMapPointForCoordinate(imageloc);
	MKMapPoint p2 = MKMapPointForCoordinate(zeroloc);
	
	//Calculate distance in meters
	CLLocationDistance dist = MKMetersBetweenMapPoints(p1, p2);
	
    if(uploadImage.location==nil || dist==0.0){
		
		
		if(uploadImage.userLocation!=nil){
			
			
			[self updateLocationMapViewForLocation:uploadImage.userLocation];
			
		}else{
			
			if([UserLocationManager sharedInstance].doesDeviceAllowLocation==NO){
				
				[self displayDefaultLocation];
				
			}else {
				[[UserLocationManager sharedInstance] startUpdatingLocationForSubscriber:LOCATIONSUBSCRIBERID];
			}
			
		}
		
		
		
	}else{
		if(uploadImage.userLocation==nil)
			[self loadLocationFromPhoto];
		
		[self initialiseViewState:PhotoWizardViewStateCategory];
		
    }
	
	
}


- (IBAction) locationButtonSelected:(id)sender {
	
    PhotoWizardLocationViewController *lv=[[PhotoWizardLocationViewController alloc]initWithNibName:[PhotoWizardLocationViewController nibName] bundle:nil];
	lv.delegate=self;
	lv.userlocation=uploadImage.userLocation;
	lv.photolocation=uploadImage.location;
	
	[self presentModalViewController:lv animated:YES];
    
}
-(IBAction)resetButtonSelected:(id)sender{
    
    if(uploadImage.userLocation!=nil){
		uploadImage.userLocation=nil;
	}
    
	if(uploadImage.location!=nil){
		[self updateLocationMapViewForLocation:uploadImage.location];
	}
}

//
/***********************************************
 * @description			delegate method
 ***********************************************/
//
-(void)UserDidUpdatePhotoLocation:(CLLocation*)location{
    
    if(location!=nil){
		
		uploadImage.userLocation=location;
    
		[self updateLocationMapViewForLocation:uploadImage.userLocation];
        
        [self initialiseViewState:PhotoWizardViewStateCategory];
    }
    
}


-(void)loadLocationFromPhoto{
	
	if(uploadImage.location!=nil){
		
		[self updateLocationMapViewForLocation:uploadImage.location];
		
	}
}

-(void)displayDefaultLocation{
	
	CLLocationCoordinate2D coordinate=[UserLocationManager defaultCoordinate];
	
	locationLabel.text=[NSString stringWithFormat:@"%f, %f",coordinate.latitude,coordinate.longitude];

	[self.locationMapView moveToLatLong:coordinate];
	
	[locationMapView.markerManager addMarker:[self retrieveLocationMapMarker] AtLatLong:coordinate];
	
	[locationMapView.contents setZoom:6];
		
}

-(void)updateLocationMapViewForLocation:(CLLocation*)location{
	
	
	locationLabel.text=[NSString stringWithFormat:@"%f, %f",location.coordinate.latitude,location.coordinate.longitude];
	
	[self.locationMapView moveToLatLong:location.coordinate];
	
	if ([locationMapView.contents zoom] < 18) {
		[locationMapView.contents setZoom:14];
	}
	

	
	[locationMapView.markerManager addMarker:[self retrieveLocationMapMarker] AtLatLong:location.coordinate];
	
	
}



#pragma mark Category View
//
/***********************************************
 * @description			Category Methods
 ***********************************************/
//

-(void)initCategoryView:(PhotoWizardViewState)state{
	
	[PhotoCategoryManager sharedInstance];
	
	[ButtonUtilities styleIBButton:categoryButton type:@"orange" text:@"Choose..."];
	[ButtonUtilities styleIBButton:categoryFeaturebutton type:@"green" text:@"Choose..."];
	
	[categoryButton addTarget:self action:@selector(showCategoryMenu:) forControlEvents:UIControlEventTouchUpInside];
	[categoryFeaturebutton addTarget:self action:@selector(showCategoryMenu:) forControlEvents:UIControlEventTouchUpInside];
	
	
}


-(void)updateCategoryView{
	
}

-(void)resetCategoryView{
	
	[ButtonUtilities styleIBButton:categoryButton type:@"orange" text:@"Choose..."];
	[ButtonUtilities styleIBButton:categoryFeaturebutton type:@"green" text:@"Choose..."];
	
	uploadImage.category=nil;
	uploadImage.feature=nil;
	
}



-(IBAction)showCategoryMenu:(id)sender{
	
	UIButton *button=(UIButton*)sender;
	PhotoCategoryType dataType=button.tag;
	
    self.categoryMenuView=[[PhotoWizardCategoryMenuViewController alloc]initWithNibName:@"PhotoWizardCategoryMenuView" bundle:nil];
	categoryMenuView.dataType=dataType;
	categoryMenuView.uploadImage=uploadImage;
	
	switch(dataType){
		
		case PhotoCategoryTypeFeature:
			categoryMenuView.dataProvider=[[PhotoCategoryManager sharedInstance].dataProvider objectForKey:@"feature"];
		break;
		
		case PhotoCategoryTypeCategory:
			categoryMenuView.dataProvider=[[PhotoCategoryManager sharedInstance].dataProvider objectForKey:@"category"];
		break;
	}
	
	self.categoryMenu = [[popoverClass alloc] initWithContentViewController:categoryMenuView];
	self.categoryMenu.delegate = self;
	
	[self.categoryMenu presentPopoverFromRect:button.frame inView:self.categoryView permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
    
	
}


-(void)didSelectCategoryFromMenu:(NSNotification*)notification{
	
	NSDictionary *userInfo=notification.userInfo;
	
	PhotoCategoryVO *vo=[userInfo objectForKey:@"dataProvider"];
	PhotoCategoryType dataType=[[userInfo objectForKey:@"dataType"]intValue];
	
	switch(dataType){
			
		case PhotoCategoryTypeFeature:
			uploadImage.feature=vo;
			[categoryFeaturebutton setTitle:uploadImage.feature.name forState:UIControlStateNormal];
		break;
			
		case PhotoCategoryTypeCategory:
			uploadImage.category=vo;
			[categoryButton setTitle:uploadImage.category.name forState:UIControlStateNormal];
		break;
	}
	
	[categoryMenu dismissPopoverAnimated:YES];
	
	if(uploadImage.feature!=nil && uploadImage.category!=nil){
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

	photodescriptionField.delegate=self;
	[self resetDescriptionField];

}

-(void)resetDescriptionView{
	
	photodescriptionField.text=[[StringManager sharedInstance] stringForSection:@"photowizard" andType:@"descriptionprompt"];
	photodescriptionField.textColor=UIColorFromRGB(0x999999);
	
}


-(void)resetDescriptionField{
	
	[self resetDescriptionView];
	
	[self removeViewState:PhotoWizardViewStateUpload];
}

-(void)updateDescriptionView{
	
	descImagePreview.image=uploadImage.image;
	
	if(uploadImage.caption!=nil)
		photodescriptionField.text=uploadImage.caption;
    
}


- (BOOL)textViewShouldBeginEditing:(UITextView *)aTextView {
   
    if (photodescriptionField.inputAccessoryView == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"UITextViewAccessoryView" owner:self options:nil];
        photodescriptionField.inputAccessoryView = textViewAccessoryView;
        self.textViewAccessoryView = nil;
    }
	
	 if([photodescriptionField.text isEqualToString:[[StringManager sharedInstance] stringForSection:@"photowizard" andType:@"descriptionprompt"]]){
		 photodescriptionField.text=@"";
		 photodescriptionField.textColor=UIColorFromRGB(0x555555);
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
	
	if(![photodescriptionField.text isEqualToString:[[StringManager sharedInstance] stringForSection:@"photowizard" andType:@"descriptionprompt"]]){
        [self initialiseViewState:PhotoWizardViewStateUpload];
		uploadImage.caption=photodescriptionField.text;
    }
	
	[photodescriptionField resignFirstResponder];
	
}


- (void)textViewDidChange:(UITextView *)textView{
	
	if([photodescriptionField.text isEqualToString:[[StringManager sharedInstance] stringForSection:@"photowizard" andType:@"descriptionprompt"]]){
		photodescriptionField.text=@"";
		photodescriptionField.textColor=UIColorFromRGB(0x555555);
		return;
	}
	
	if(photodescriptionField.text.length==0){
		[self resetDescriptionField];
		return;
	}
	
	photodescriptionField.textColor=UIColorFromRGB(0x555555);
	
    
}


#pragma mark Upload View
//
/***********************************************
 * @description			Upload Methods
 ***********************************************/
//


-(void)initUploadView:(PhotoWizardViewState)state{
	
	[self updateUploadUIState:@"waiting"];
	
	
	
	[ButtonUtilities styleIBButton:uploadButton type:@"orange" text:@"Upload Photo"];
	[uploadButton addTarget:self action:@selector(uploadPhoto:) forControlEvents:UIControlEventTouchUpInside];
	
}

-(void)updateUploadView{
	uploadProgressView.progress=0;
}


-(IBAction)uploadPhoto:(id)sender{
	
	
    if ([UserAccount sharedInstance].isLoggedIn==NO) {
		
		if([UserAccount sharedInstance].accountMode==kUserAccountCredentialsExist){
			
			BetterLog(@"kUserAccountCredentialsExist");
			
			[[PhotoManager sharedInstance] UserPhotoUploadRequest:uploadImage];
			
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
		
		[[PhotoManager sharedInstance] UserPhotoUploadRequest:uploadImage];
		
		[self updateUploadUIState:@"loading"];
	}
	
	
}


-(void)updateUploadUIState:(NSString*)state{
	
	
	if([state isEqualToString:@"loading"]){
		
		uploadLabel.textColor=[UIColor darkGrayColor];
		uploadLabel.text=@"Uploading...";
		uploadButton.enabled=NO;
		
	}else if([state isEqualToString:@"error"]){
		
		uploadLabel.textColor=UIColorFromRGB(0xC20000);
		uploadLabel.text=@"An error occured while uploading your image, please try again.";
		uploadButton.enabled=YES;
		uploadProgressView.progress=0;
		
	}else {
		
		uploadLabel.textColor=[UIColor darkGrayColor];
		uploadLabel.text=@"Ready to upload";
		uploadButton.enabled=YES;
	}
	
	
	
}



-(IBAction)cancelUploadPhoto:(id)sender{
	
    uploadProgressView.progress=0;
	
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
	
	
	[ButtonUtilities styleIBButton:photoMapButton type:@"orange" text:@"View map"];
	[photoMapButton addTarget:self action:@selector(photoMapButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
	
    photoResultURLLabel.text=[uploadImage.responseDict objectForKey:@"url"];
	
	
}

-(void)updateCompleteView{
	
	BetterLog(@"");
	
	pageControl.numberOfPages=1;
	[pageControl updateCurrentPageDisplay];
	maxVisitedPage=0;
	pageScrollView.scrollEnabled=NO;
	
	
}




-(IBAction)photoMapButtonSelected:(id)sender{
	
	
	[PhotoManager sharedInstance].autoLoadLocation=uploadImage.activeLocation;
	
	if(isModal==YES){
	
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
