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
@property (nonatomic, strong)			NSString *activeFormId;
@property (nonatomic, strong)			NSDictionary *formDataProvider;
@property (nonatomic, strong)			NSMutableArray *activeFormFieldArray;
@property (nonatomic)			FormManagerFieldType fieldType;
@property (nonatomic, strong)			NSMutableArray *errorArray;
@property (nonatomic, strong)			NSDictionary *validateMethods;
@property (nonatomic, strong)			UIView *activeFormView;
@property (nonatomic)			BOOL formLoaded;

SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(FormManager);

-(void)loadFormByID:(NSString*)formid;
-(BOOL)popuplateFormView:(UIView*)formview withID:(NSString*)formid;
-(FormManagerError)validateFormForId:(NSString*)formid;
-(NSMutableArray*)errorArrayForForm:(NSString*)formid;


@end
