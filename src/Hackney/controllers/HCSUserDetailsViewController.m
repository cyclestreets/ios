//
//  HCSUserDetailsViewController.m
//  CycleStreets
//
//  Created by Neil Edwards on 27/01/2014.
//  Copyright (c) 2014 CycleStreets Ltd. All rights reserved.
//

#import "HCSUserDetailsViewController.h"
#import "PickerViewController.h"

#import "User.h"
#import "UserManager.h"

@interface HCSUserDetailsViewController ()<UIPickerViewDelegate,UIPickerViewDataSource>

@property (nonatomic,strong)  User											*user;

@property (nonatomic,strong)  NSArray										*ageArray;
@property (nonatomic,strong)  NSArray										*genderArray;

@property (nonatomic,strong)  NSArray										*activePickerDataSource;
@property (nonatomic,strong)  UIPickerView									*fieldPicker;

@property(nonatomic,weak) IBOutlet UINavigationItem							*myNavigationItem;

@property (weak, nonatomic) IBOutlet UITextField							*ageField;
@property (weak, nonatomic) IBOutlet UITextField							*genderField;
@property (nonatomic, strong) IBOutlet UIView								*pickerAccessoryView;

@property (nonatomic,strong)  UITextField									*currentTextField;

@property (nonatomic,strong)  NSArray										*theData;

@end

@implementation HCSUserDetailsViewController

//
/***********************************************
 * @description		NOTIFICATIONS
 ***********************************************/
//

-(void)listNotificationInterests{
    
	
	
	[super listNotificationInterests];
	
}

-(void)didReceiveNotification:(NSNotification*)notification{
	
	
	
}


//
/***********************************************
 * @description			VIEW METHODS
 ***********************************************/
//

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad
{
	
	self.navigationController.navigationBarHidden=YES;
	self.modalPresentationCapturesStatusBarAppearance=NO;
	self.navigationController.view.backgroundColor=[UINavigationBar appearance].barTintColor;
	

	
    [super viewDidLoad];
	
    [self createPersistentUI];
}


-(void)viewWillAppear:(BOOL)animated{
    
    [self createNonPersistentUI];
    
    [super viewWillAppear:animated];
}


-(void)createPersistentUI{
	
	
	switch (_viewMode) {
		case HCSUserDetailsViewModeSave:
		{
			_myNavigationItem.leftBarButtonItem.title=@"Cancel";
			_myNavigationItem.rightBarButtonItem.title=@"Next";
		}
		break;
		case HCSUserDetailsViewModeShow:
		{
			
			_myNavigationItem.leftBarButtonItem=nil;
			
			
		}
		break;
	}
	
	
	
	self.user=[[UserManager sharedInstance] fetchUser];
	
	self.genderArray = @[@"Female",@"Male",@"Other / prefer not to say"];
    self.ageArray = @[@"0-10", @"11-16", @"17-24", @"25-44", @"45-64", @"65-74", @"75-84",@"85+"];
	
	self.fieldPicker = [[UIPickerView alloc] init];
    _fieldPicker.dataSource = self;
    _fieldPicker.delegate = self;
    _ageField.inputView = _fieldPicker;
	_genderField.inputView= _fieldPicker;
	
	
    
}

-(void)createNonPersistentUI{
    
    if(_user.gender!=nil){
		_genderField.text=_user.gender;
	}
	if(_user.age!=nil){
		_ageField.text=_user.age;
	}
    
}


#pragma mark - UITextField delegate methods


- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
	
	if(textField.inputView!=nil){
		
		if (textField.inputAccessoryView == nil) {
			[[NSBundle mainBundle] loadNibNamed:@"UIPickerAccessoryView" owner:self options:nil];
			textField.inputAccessoryView = _pickerAccessoryView;
			self.pickerAccessoryView = nil;
		}
		
	}
	
	
	return YES;
	
}


- (void)textFieldDidBeginEditing:(UITextField *)textField{
	
	self.currentTextField=textField;
	
	if(_currentTextField ==_ageField){
		self.activePickerDataSource=_ageArray;
	}else if (_currentTextField==_genderField){
		self.activePickerDataSource=_genderArray;
	}
	
	[_fieldPicker reloadAllComponents];
	
}

-(IBAction)didDismissPickerFromToolBar:(id)sender{
	_currentTextField.text = _activePickerDataSource[[_fieldPicker selectedRowInComponent:0]];
    [_currentTextField resignFirstResponder];
}


#pragma mark - UIPicker methods

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return _activePickerDataSource.count;
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return  1;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return _activePickerDataSource[row];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    _currentTextField.text = _activePickerDataSource[row];
    [_currentTextField resignFirstResponder];
}





//
/***********************************************
 * @description			UI EVENTS
 ***********************************************/
//

-(IBAction)didSelectActionButton:(id)sender{
	
	
	_user.age=_ageField.text;
	_user.gender=_genderField.text;
	
	[[CoreDataStore mainStore] save];
	
	switch (_viewMode) {
		case HCSUserDetailsViewModeSave:
		{
			PickerViewController *pickerController = [[PickerViewController alloc] initWithNibName:@"TripPurposePicker" bundle:nil];
			pickerController.delegate = self.tripDelegate;
			
			[self.navigationController pushViewController:pickerController animated:YES];
		}
		break;
		case HCSUserDetailsViewModeShow:
			[self didRequestPopController];
		break;
		
	}
	
}


-(IBAction)didSelectCancel:(id)sender{
	
	switch (_viewMode) {
		case HCSUserDetailsViewModeSave:
			 [_tripDelegate didCancelSaveJourneyController];
		break;
		case HCSUserDetailsViewModeShow:
			[self didRequestPopController];
		break;
	}
   
	
}


//
/***********************************************
 * @description			SEGUE METHODS
 ***********************************************/
//

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    
    
}


//
/***********************************************
 * @description			MEMORY
 ***********************************************/
//
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

@end
