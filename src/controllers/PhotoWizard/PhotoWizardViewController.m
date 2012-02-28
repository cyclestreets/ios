//
//  PhotoWizardViewController.m
//  CycleStreets
//
//  Created by neil on 28/02/2012.
//  Copyright (c) 2012 CycleStreets Ltd. All rights reserved.
//

#import "PhotoWizardViewController.h"

@interface PhotoWizardViewController(Private) 

-(void)didRecievePhotoImageUploadResponse:(NSDictionary*)dict;

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
	
	[super listNotificationInterests];
	
}

-(void)didReceiveNotification:(NSNotification*)notification{
	
	BetterLog(@"");
	
	[super didReceiveNotification:notification];
	
    if([notification.name isEqualToString:UPLOADUSERPHOTORESPONSE]){
        [self didRecievePhotoImageUploadResponse:notification.userInfo];
    }
	
	
}


-(void)didRecievePhotoImageUploadResponse:(NSDictionary*)dict{
    
    
    
    
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
	
	
}



-(void)viewWillAppear:(BOOL)animated{
	
    [self createNonPersistentUI];
	
    [super viewWillAppear:animated];
}


-(void)createNonPersistentUI{
    
    
    
    
}


//
/***********************************************
 * @description			view state updates
 ***********************************************/
//

-(void)updateViewState:(PhotoWizardViewState)state{
    
    
    // update view state
    
    // switch states
    
    
    // update title
    
    
}


//
/***********************************************
 * @description			paged scroll view update
 ***********************************************/
//




//
/***********************************************
 * @description			PhotoPicker methods
 ***********************************************/
//

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
		picker.navigationBar.backgroundColor=UIColorFromRGB(0xFFFFFF,0);
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
	UIImage *image=[ImageManipulator resizeImage:[info objectForKey:UIImagePickerControllerEditedImage] destWidth:userImage.frame.size.width destHeight:userImage.frame.size.height];
    
    self.uploadImage=[[UploadPhotoVO alloc]initWithImage:image];
    
	[picker dismissModalViewControllerAnimated:YES];	
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	[picker dismissModalViewControllerAnimated:YES];
}



//
/***********************************************
 * @description			Category Methods
 ***********************************************/
//
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
	
	typeLabel.text=[self.categoryLoader.metaCategoryLabels objectAtIndex:metacategoryIndex];
	descLabel.text=[self.categoryLoader.categoryLabels objectAtIndex:categoryIndex];
}



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
