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
#import "UIViewAdditions.h"
#import "ButtonUtilities.h"
#import "StyleManager.h"
#import "PhotoMapImageLocationViewController.h"
#import "UserAccount.h"
#import "PhotoManager.h"
#import "CycleStreetsAppDelegate.h"


@interface PhotoWizardViewController(Private) 

-(void)initialiseViewState:(PhotoWizardViewState)state;
-(void)navigateToViewState:(PhotoWizardViewState)state;
-(void)updateGlobalViewUIForState;

-(void)initInfoView:(PhotoWizardViewState)state;
-(void)initPhotoView:(PhotoWizardViewState)state;
-(void)updatePhotoView;
-(void)initLocationView:(PhotoWizardViewState)state;
-(void)updateLocationView;
-(void)initCategoryView:(PhotoWizardViewState)state;
-(void)initDescriptionView:(PhotoWizardViewState)state;
-(void)initUploadView:(PhotoWizardViewState)state;
-(void)initCompleteView:(PhotoWizardViewState)state;

-(void)addViewToPageContainer:(NSMutableDictionary*)viewDict;


-(void)updatePageControlExtents;

-(IBAction)pageControlValueChanged:(id)sender;

-(void)loadLocationFromPhoto;
- (void)startlocationManagerIsLocating;
- (void)stoplocationManagerIsLocating;
- (void)PanGestureCaptured:(UIPanGestureRecognizer *)gesture;

-(void)updateSelectionLabels;

-(void)didRecievePhotoImageUploadResponse:(NSDictionary*)dict;
-(void)didRecieveFileUploadResponse:(NSDictionary*)dict;

@end


@implementation PhotoWizardViewController
@synthesize viewState;
@synthesize pageScrollView;
@synthesize pageControl;
@synthesize pageContainer;
@synthesize activePage;
@synthesize maxVisitedPage;
@synthesize viewArray;
@synthesize pageTitleLabel;
@synthesize pageNumberLabel;
@synthesize locationsc;
@synthesize locpangesture;
@synthesize uploadImage;
@synthesize infoView;
@synthesize continueButton;
@synthesize cancelViewButton;
@synthesize photoPickerView;
@synthesize imagePreview;
@synthesize photoSizeLabel;
@synthesize cameraButton;
@synthesize libraryButton;
@synthesize photoLocationView;
@synthesize locationMapView;
@synthesize locationMarker;
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
@synthesize categoryLoader;
@synthesize categoryIndex;
@synthesize metacategoryIndex;
@synthesize photodescriptionView;
@synthesize descImagePreview;
@synthesize photodescriptionField;
@synthesize photoUploadView;
@synthesize uploadButton;
@synthesize cancelButton;
@synthesize uploadProgressView;
@synthesize uploadLabel;
@synthesize loginView;
@synthesize photoResultView;
@synthesize photoMapButton;



//
/***********************************************
 * @description		NOTIFICATIONS
 ***********************************************/
//

-(void)listNotificationInterests{
	
	[self initialise];
    
    [notifications addObject:UPLOADUSERPHOTORESPONSE];
	[notifications addObject:FILEUPLOADPROGRESS];
	
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
}


-(void)didRecievePhotoImageUploadResponse:(NSDictionary*)dict{
    
    NSString *state=[dict objectForKey:STATE];
	
	if([state isEqualToString:SUCCESS]){
		
		[self initialiseViewState:PhotoWizardViewStateResult];
		[self navigateToViewState:PhotoWizardViewStateResult];
		
		
	}else {
		
		
		// show error message
		
	}
    
    
}

//
/***********************************************
 * @description			Notification from RFM of http upload progress
 ***********************************************/
//
-(void)didRecieveFileUploadResponse:(NSDictionary*)dict{
    
	int totalBytesWritten=[[dict objectForKey:@"totalBytesWritten"] intValue];
	//int bytesWritten=[[dict objectForKey:@"bytesWritten"] intValue];
	int totalBytesExpectedToWrite=[[dict objectForKey:@"totalBytesExpectedToWrite"] intValue];
	
	float percent=totalBytesWritten/totalBytesExpectedToWrite;
	
    uploadProgressView.progress=percent;
    
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
    
    categoryIndex=0;
    metacategoryIndex=0;
	
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
    //pageControl.defersCurrentPageDisplay=YES;
    pageControl.numberOfPages=1;
	[pageControl addTarget:self action:@selector(pageControlValueChanged:) forControlEvents:UIControlEventValueChanged];
	
	
	[self initialiseViewState:PhotoWizardViewStateInfo];
    
}



-(void)viewWillAppear:(BOOL)animated{
	
   [self createNonPersistentUI];
	
    [super viewWillAppear:animated];
}


-(void)createNonPersistentUI{
    
   
    
}

//
/***********************************************
 * @description			initialises and adds view state to container (one off operation)
 ***********************************************/
//
-(void)initialiseViewState:(PhotoWizardViewState)state{
	
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
	
	[self updatePageControlExtents];
	
}


-(void)removeViewState:(PhotoWizardViewState)state{
    
    // removes enabled state from pages
    // so page control stops showing access
    
}


//
/***********************************************
 * @description			scroll To ViewState if initialised
 ***********************************************/
//
-(void)navigateToViewState:(PhotoWizardViewState)state{
	
	if(state<=maxVisitedPage){
		

		viewState=state;
		pageControl.currentPage=viewState;
		activePage=viewState;
        
		CGPoint offset=CGPointMake(viewState*SCREENWIDTH, 0);
		[pageScrollView setContentOffset:offset animated:YES];
		
		[self updateGlobalViewUIForState];
		
		
		
    }
	
	
}


-(void)updateGlobalViewUIForState{
	pageTitleLabel.text=[[viewArray objectAtIndex:activePage] objectForKey:@"title"];
    pageNumberLabel.text=[NSString stringWithFormat:@"%i of %i",activePage+1, [viewArray count]];
	
	// should call updateView for State
}



-(void)addViewToPageContainer:(NSMutableDictionary*)viewDict{
	
	[viewDict setObject:@"created" forKey:BOX_BOOL(YES)];
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
	[ButtonUtilities styleIBButton:cancelButton type:@"red" text:@"Cancel"];
	[continueButton addTarget:self action:@selector(cancelUploadbuttonSelected:) forControlEvents:UIControlEventTouchUpInside];
	
}

-(IBAction)continueUploadbuttonSelected:(id)sender{
    
	[self initialiseViewState:PhotoWizardViewStatePhoto];
	[self navigateToViewState:PhotoWizardViewStatePhoto];
    
}

-(IBAction)cancelUploadbuttonSelected:(id)sender{
    
}


#pragma mark Photo View
//
/***********************************************
 * @description			PhotoPicker methods
 ***********************************************/
//

-(void)initPhotoView:(PhotoWizardViewState)state{
	
	[ButtonUtilities styleIBButton:cameraButton type:@"green" text:@"Camera"];
	[cameraButton addTarget:self action:@selector(cameraButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
	[ButtonUtilities styleIBButton:libraryButton type:@"green" text:@"Library"];
	[libraryButton addTarget:self action:@selector(libraryButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
	
}

-(void)updatePhotoView{
	
	if(uploadImage!=nil){
        imagePreview.image=uploadImage.image;
        photoSizeLabel.text=[NSString stringWithFormat:@"%i x %i",uploadImage.width, uploadImage.height];
    }else{
		photoSizeLabel.text=EMPTYSTRING;
    }
}

-(IBAction)cameraButtonSelected:(id)sender{
	
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
		UIImagePickerController *picker = [[UIImagePickerController alloc] init];
		picker.delegate = self;
		picker.sourceType = UIImagePickerControllerSourceTypeCamera;
		picker.allowsEditing = YES;
		[self presentModalViewController:picker animated:YES];
		[picker release];
		
	}else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error accessing camera" message:@"Device does not have a camera" 
													   delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
    
	
}


-(IBAction)libraryButtonSelected:(id)sender{
	
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
		UIImagePickerController *picker = [[UIImagePickerController alloc] init];
		picker.navigationBar.backgroundColor=UIColorFromRGBAndAlpha(0xFFFFFF,0);
		picker.delegate = self;
		picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
		picker.allowsEditing = YES;
		[self presentModalViewController:picker animated:YES];
		[picker release];
	}
	else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error accessing photo library" message:@"Device does not support a photo library" 
													   delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
	
	
}


#pragma mark imagePickerController  Delegate methods -
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	
	// TODO: image should be sized, a) on screen & b) upload size
    // initial image should be max resolution possible for app
    // setttings.imageSize 
	UIImage *image=[info objectForKey:UIImagePickerControllerEditedImage];
    self.uploadImage=[[UploadPhotoVO alloc]initWithImage:image];
	imagePreview.image=uploadImage.image;
	photoSizeLabel.text=[NSString stringWithFormat:@"%i x %i",uploadImage.width, uploadImage.height];
	
	
	NSURL *referenceURL = [info objectForKey:UIImagePickerControllerReferenceURL];
	ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
	
	[library assetForURL:referenceURL resultBlock:^(ALAsset *asset){           
		
		CLLocation *location = (CLLocation *)[asset valueForProperty:ALAssetPropertyLocation];
		uploadImage.location=location;
		BetterLog(@"location=%f %f",location.coordinate.latitude, location.coordinate.longitude);
		
		
	} failureBlock:^(NSError *error) {
		 BetterLog(@"error retrieving image from  - %@",[error localizedDescription]);
	 }];
	
	[library release];
    
	[picker dismissModalViewControllerAnimated:YES];	
	
	[self initialiseViewState:PhotoWizardViewStateLocation];
    
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
	
	[ButtonUtilities styleIBButton:locationUpdateButton type:@"green" text:@"Locate"];
	[locationUpdateButton addTarget:self action:@selector(locationButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
	[ButtonUtilities styleIBButton:locationResetButton type:@"red" text:@"Reset"];
	[locationResetButton addTarget:self action:@selector(libraryButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
		
}


-(void)updateLocationView{
	
	CLLocationCoordinate2D imageloc=uploadImage.location.coordinate;
	CLLocationCoordinate2D zeroloc=CLLocationCoordinate2DMake(0,0);
	
	MKMapPoint p1 = MKMapPointForCoordinate(imageloc);
	MKMapPoint p2 = MKMapPointForCoordinate(zeroloc);
	
	//Calculate distance in meter
	CLLocationDistance dist = MKMetersBetweenMapPoints(p1, p2);
	
    if(uploadImage.location==nil || dist==0.0){
		locationMapView.showsUserLocation=YES;
	}else{
        [self loadLocationFromPhoto];
        [self initialiseViewState:PhotoWizardViewStateCategory];
    }
}


- (IBAction) locationButtonSelected {
	
    PhotoMapImageLocationViewController *lv=[[PhotoMapImageLocationViewController alloc]initWithNibName:[PhotoMapImageLocationViewController nibName] bundle:nil];
    
    UINavigationController *navController = [SuperViewController createCustomNavigationControllerWithView:lv];
	[self.navigationController presentModalViewController:navController animated:YES];
    
}
-(IBAction)resetButtonSelected:(id)sender{
    
    // if userlocation!=nil
    // if location !-nil
    // reset to location
    // update mapui
}

//
/***********************************************
 * @description			delegate method
 ***********************************************/
//
-(void)UserDidUpdatePhotoLocation:(CLLocation*)location{
    
    if(location!=nil){
    
        MKCoordinateRegion region = MKCoordinateRegionMake(location.coordinate,MKCoordinateSpanMake(0.004,0.004) );
        [locationMapView setRegion:region animated:YES];
        
        uploadImage.userLocation=location;
        
        [self initialiseViewState:PhotoWizardViewStateCategory];
    }
    
}




-(void)loadLocationFromPhoto{
	
	BetterLog(@"");
	
	MKCoordinateRegion region = MKCoordinateRegionMake(uploadImage.location.coordinate,MKCoordinateSpanMake(0.004,0.004) );
	[locationMapView setRegion:region animated:YES];
	
	
}



#pragma mark Category View
//
/***********************************************
 * @description			Category Methods
 ***********************************************/
//

-(void)initCategoryView:(PhotoWizardViewState)state{
	
	CycleStreets *cycleStreets = [CycleStreets sharedInstance];
	[cycleStreets.categoryLoader setupCategories];
    categoryIndex=0;
    metacategoryIndex=0;
	
	
}
-(void)updateCategoryView{
    
    [self updateSelectionLabels];
	
}


#pragma mark picker delegate and data source

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	if (component == 0) {
		return [self.categoryLoader.metaCategoryLabels objectAtIndex:row];
	} else {
		return [self.categoryLoader.categoryLabels objectAtIndex:row];
	}
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
	if (component == 0) {
		return [self.categoryLoader.metaCategoryLabels count];
	} else {
		return [self.categoryLoader.categoryLabels count];
	}
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
	if (component == 0) {
		metacategoryIndex = row;
	} else {
		categoryIndex = row;
	}
	[self updateSelectionLabels];
}


-(void)updateSelectionLabels{
    
    uploadImage.category=[self.categoryLoader.categoryLabels objectAtIndex:categoryIndex];
    uploadImage.metaCategory=[self.categoryLoader.metaCategoryLabels objectAtIndex:metacategoryIndex];
	
	categoryTypeLabel.text=uploadImage.metaCategory;
	categoryDescLabel.text=uploadImage.category;
    
    if(uploadImage.metaCategory!=nil && uploadImage.category!=nil){
        [self initialiseViewState:PhotoWizardViewStateDescription];
    }
    
}


#pragma mark Description View
//
/***********************************************
 * @description			Description Methods
 ***********************************************/
//

-(void)initDescriptionView{
	
	

}
-(void)updateDescriptionView{
	
    photodescriptionField.text=uploadImage.description;
    
}

- (void)textViewDidChange:(UITextView *)textView{
    
    if(textView.text.length>0){
        [self initialiseViewState:PhotoWizardViewStateUpload];
    }
    
}


#pragma mark Upload View
//
/***********************************************
 * @description			Upload Methods
 ***********************************************/
//


-(void)initUploadView{
	
	uploadProgressView.progress=0.0;
	
}


// TODO: UserPhotoUploadRequest needs to execute if user logins correctly
-(IBAction)uploadPhoto:(id)sender{
    
    if ([UserAccount sharedInstance].isLoggedIn==NO) {
		
		if([UserAccount sharedInstance].accountMode==kUserAccountCredentialsExist){
			
			BetterLog(@"kUserAccountCredentialsExist");
			
			[[PhotoManager sharedInstance] UserPhotoUploadRequest:uploadImage];
			
		}else {
			
			BetterLog(@"kUserAccountNotLoggedIn");
			
			if (self.loginView == nil) {
				self.loginView = [[[AccountViewController alloc] initWithNibName:@"AccountView" bundle:nil] autorelease];
			}
			self.loginView.isModal=YES;
			self.loginView.shouldAutoClose=YES;
			UINavigationController *nav=[[UINavigationController alloc]initWithRootViewController:self.loginView];
			[self presentModalViewController:nav animated:YES];
			[nav release];
		}
        
		
		
	} else {
		
		BetterLog(@"kUserAccountLoggedIn");
		
		[[PhotoManager sharedInstance] UserPhotoUploadRequest:uploadImage];
	}
	
	
}

-(IBAction)cancelUploadPhoto:(id)sender{
	
    // is this required?
	
	
}



//
/***********************************************
 * @description			Complete View
 ***********************************************/
//

-(void)initCompleteView:(PhotoWizardViewState)state{
	
	
	[ButtonUtilities styleIBButton:photoMapButton type:@"orange" text:@"View Map"];
	[photoMapButton addTarget:self action:@selector(photoMapButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
	
    
    // there is
    // thumbnailUrl
    // and url
    photoResultURLLabel.text=[uploadImage.responseDict objectForKey:@"url"];
	
	pageControl.numberOfPages=1;

	
}

-(IBAction)photoMapButtonSelected:(id)sender{
	
    [self navigateToViewState:PhotoWizardViewStateInfo];
	
	// call navigate to PM
    [PhotoManager sharedInstance].autoLoadLocation=uploadImage.location;
    CycleStreetsAppDelegate *appDelegate=(CycleStreetsAppDelegate*)[[UIApplication sharedApplication] delegate];
	[appDelegate showTabBarViewControllerByName:@"PhotoMap"];
		
}



#pragma mark Generic
//
/***********************************************
 * @description			generic
 ***********************************************/
//

-(void)viewDidUnload{
    
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end
