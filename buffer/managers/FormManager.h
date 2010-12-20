//
//  FormManager.h
//  CycleStreets
//
//  Created by Neil Edwards on 20/12/2010.
//  Copyright 2010 CycleStreets Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FrameworkObject.h"
#import "SynthesizeSingleton.h"


#define kFormManagerDataFile @"FormData"

enum  {
	kFormManagerErrorNone=0,
	kFormManagerErrorMultiple=1,
	kFormManagerErrorSingle=2,
	kFormManagerErrorNotFound=3
};
typedef int FormManagerError;


enum  {
	kFormFieldTypeTextField=0,
	kFormFieldTypeSwitchType=1,
	kFormFieldTypeSliderType=2
};
typedef int FormManagerFieldType;


@interface FormManager : FrameworkObject {
	
	NSString				*activeFormId;
	NSDictionary			*formDataProvider;
	NSMutableArray			*activeFormFieldArray;
	FormManagerFieldType	fieldType;
	NSMutableArray			*errorArray;
	NSDictionary			*validateMethods;
	
	UIView					*activeFormView;
	
	BOOL					formLoaded;
	
}
@property (nonatomic, retain)			NSString *activeFormId;
@property (nonatomic, retain)			NSDictionary *formDataProvider;
@property (nonatomic, retain)			NSMutableArray *activeFormFieldArray;
@property (nonatomic)			FormManagerFieldType fieldType;
@property (nonatomic, retain)			NSMutableArray *errorArray;
@property (nonatomic, retain)			NSDictionary *validateMethods;
@property (nonatomic, retain)			UIView *activeFormView;
@property (nonatomic)			BOOL formLoaded;

SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(FormManager);

-(void)loadFormByID:(NSString*)formid;
-(BOOL)popuplateFormView:(UIView*)formview withID:(NSString*)formid;
-(BOOL)validateFormForId:(NSString*)formid;
-(NSMutableArray*)errorArrayForForm:(NSString*)formid;

// validators
-(BOOL)validateEmail:(NSString*)str;
-(BOOL)validatURL:(NSString*)str;
-(BOOL)validateLength:(NSString*)str;
-(BOOL)validateString:(NSString*) forRegEx:(NSString*)regex;
-(BOOL)validateValueInRange:(int)value minValue:(int)min  maxValue:(int)max;

@end
