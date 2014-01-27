//
//  HCSUserDetailsViewController.m
//  CycleStreets
//
//  Created by Neil Edwards on 27/01/2014.
//  Copyright (c) 2014 CycleStreets Ltd. All rights reserved.
//

#import "HCSUserDetailsViewController.h"

#import <JVFloatLabeledTextField.h>

#import "User.h"
#import "UserManager.h"

@interface HCSUserDetailsViewController ()<UIPickerViewDelegate,UIPickerViewDataSource>

@property (nonatomic,strong)  User											*user;

@property (nonatomic,strong)  NSArray										*ageArray;
@property (nonatomic,strong)  NSArray										*genderArray;

@property (nonatomic,strong)  NSArray										*activePickerDataSource;
@property (nonatomic,strong)  UIPickerView									*fieldPicker;

@property (weak, nonatomic) IBOutlet JVFloatLabeledTextField				*nameField;
@property (weak, nonatomic) IBOutlet UITextField							*ageField;
@property (weak, nonatomic) IBOutlet UITextField							*genderField;

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

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    [self createPersistentUI];
}


-(void)viewWillAppear:(BOOL)animated{
    
    [self createNonPersistentUI];
    
    [super viewWillAppear:animated];
}


-(void)createPersistentUI{
	
	self.user=[[UserManager sharedInstance] fetchUser];
	
	self.genderArray = @[@"Female",@"Male"];
    self.ageArray = @[@"Less than 18", @"18-24", @"25-34", @"35-44", @"45-54", @"55-64", @"65+"];
	
	self.fieldPicker = [[UIPickerView alloc] init];
    _fieldPicker.dataSource = self;
    _fieldPicker.delegate = self;
    _ageField.inputView = _fieldPicker;
	_genderField.inputView= _fieldPicker;
	
	// inputaCcessoryView
    
}

-(void)createNonPersistentUI{
    
    
    
}


#pragma mark - UITextField delegate methods

- (void)textFieldDidBeginEditing:(UITextField *)textField{
	
	self.currentTextField=textField;
	
	if(_currentTextField ==_ageField){
		self.activePickerDataSource=_ageArray;
	}else if (_currentTextField==_genderField){
		self.activePickerDataSource=_genderArray;
	}
	
	[_fieldPicker reloadAllComponents];
	
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

-(IBAction)didSelectSaveButton:(id)sender{
	
	
	
	
	
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
