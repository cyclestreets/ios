//
//  FormManager.m
//  CycleStreets
//
//  Created by Neil Edwards on 20/12/2010.
//  Copyright 2010 CycleStreets Ltd. All rights reserved.
//

#import "FormManager.h"
#import "SynthesizeSingleton.h"
#import "StringManager.h"
#import "GlobalUtilities.h"
#import "RegexKitLite.h"


static NSString *const FORMVALIDATEEMAIL=@"FORMVALIDATEEMAIL";
static NSString *const FORMVALIDATEURL=@"FORMVALIDATEURL";
static NSString *const FORMVALIDATEMIN=@"FORMVALIDATEMIN";
static NSString *const FORMVALIDATERANGE=@"FORMVALIDATERANGE";
static NSString *const FORMVALIDATEREGEX=@"FORMVALIDATEREGEX";


@interface FormManager(Private)

-(NSString*)formTypeToString:(FormManagerFieldType)type;

-(BOOL)validateValueInRange:(int)value minValue:(int)min  maxValue:(int)max
-(BOOL)validateString:(NSString*)str forRegEx:(NSString*)regex;
-(BOOL)validateLength:(NSString*)str forLength:(int)length;
-(BOOL)validatURL:(NSString *)str;
-(BOOL)validateEmail:(NSString*)str;

-(NSString*)dataPath;
-(void)loadFormDataFile;

@end



@implementation FormManager
SYNTHESIZE_SINGLETON_FOR_CLASS(FormManager);
@synthesize activeFormId;
@synthesize formDataProvider;
@synthesize activeFormFieldArray;
@synthesize fieldType;
@synthesize errorArray;
@synthesize validateMethods;
@synthesize activeFormView;
@synthesize formLoaded;


//=========================================================== 
// dealloc
//=========================================================== 
- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    [activeFormId release], activeFormId = nil;
    [formDataProvider release], formDataProvider = nil;
    [activeFormFieldArray release], activeFormFieldArray = nil;
    [errorArray release], errorArray = nil;
    [validateMethods release], validateMethods = nil;
    [activeFormView release], activeFormView = nil;
	
    [super dealloc];
}



-(id)init{
	if (self = [super init]){
		
		formLoaded=NO;
		
		validateMethods=[[NSDictionary alloc] initWithObjectsAndKeys:
					   [NSValue valueWithPointer:@selector(validateEmail:)],FORMVALIDATEEMAIL,
					   [NSValue valueWithPointer:@selector(validateURL:)],FORMVALIDATEURL,
					   [NSValue valueWithPointer:@selector(validateLength:forLength:)],FORMVALIDATEMIN,
						[NSValue valueWithPointer:@selector(validateString:forRegEx:)],FORMVALIDATEREGEX,
						 [NSValue valueWithPointer:@selector(validateValueInRange:minValue:maxValue:)],FORMVALIDATERANGE
					   nil];
		
		[self loadFormDataFile];
	}
	return self;
}



-(void)loadFormByID:(NSString*)formid{
	
	activeFormFieldArray=[formDataProvider objectForKey:formid];
	
}

-(void)unloadForm:(NSString*)formid{
	
	activeFormId=nil;
	activeFormFieldArray=nil;
	activeFormView=nil;
	
}


//
/***********************************************
 * @description			TBD: for full dynamic form support
 ***********************************************/
//
-(BOOL)popuplateFormView:(UIView*)formview withID:(NSString*)formid{
	
	// can set field params & switch/slider options from config plist
	
}




-(FormManagerError)validateFormForId:(NSString*)formid{
	
	if([formid isEqualToString:activeFormId]){
	
		activeFormFieldArray=[formDataProvider objectForKey:activeFormId];
		
		for(FormItemVO *formitem in activeFormFieldArray){
			
			// NOTE: all form methods need same signatue
			SEL vaidatemethod=[[validateMethods objectForKey:type] pointerValue];
			[self performSelector:validatemethod withObject:formitem.target withObject:formitem.parameters];
			
			
		}
		
	}else {
		return kFormManagerErrorNotFound;
	}

	
}


-(NSMutableArray*)errorArrayForForm:(NSString*)formid{
	
	// if has error, return error array for ui highlighting
	
	
}


//
/***********************************************
 * @description			VALIDATORS
 ***********************************************/
//

-(BOOL)validateEmail:(NSString*)str withParams(id)parameters{
	return [GlobalUtilities validateEmail:str]; 
}

-(BOOL)validatURL:(NSString *)str  withParams(id)parameters{
	return [GlobalUtilities validateURL:str];
}


-(BOOL)validateLength:(NSString*)str  withParams(NSDictionary*)parameters{
	return [str length]>=length;
}

-(BOOL)validateString:(NSString*)str withParams:(NSString*)parameters{
	
	if ([regex isRegexValid]){
		return [str isMatchedByRegex:regex];
	}else {
		return NO;
	}

}


// is valid date (is valid ie not 32/34/56 )
-(BOOL)validateDate:(NSString*)str withParams:(NSDictionary*)parameters{
	
	// is valid date
	
	// conforms to required input formatting
	
}


// is future date (ie cards)
-(BOOL)validateFutureDate:(NSString*)str withParams:(NSDictionary*)parameters{
	
	// is valid date
	
	// is in future
	
}

// is > date (ie age restrictions)
-(BOOL)validatePastDate:(NSString*)str withParams:(NSDictionary*)parameters{
	
	// is valid date
	
	// date< min date
	
}


// value>min && value<max
-(BOOL)validateValueInRange:(NSNumber*)value withParams(NSDictionary*)parameters{
	
	return NO;
	
}




-(NSString*)formTypeToString:(FormManagerFieldType)type{
	
	switch(type){
		
		case kFormFieldTypeTextField:
			return 
		break;
		case kFormFieldTypeSliderType:
			
		break;
		case kFormFieldTypeSwitchType:
			
		break;
		
	}
}




#pragma mark Style sheet loading methods
// @private
-(void)loadFormDataFile{
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:[self dataPath]]){
		
		// load data file and parse NSDict entries into FormItemVOs
		formDataProvider = [[NSMutableDictionary alloc] initWithContentsOfFile:[self dataPath]];
		
		for(NSDictionary *formviewdict in formDataProvider){ // top level forms
			for(NSString *formkey in formviewdict){ // ui items
				NSDictionary *formitem=[formviewdict objectForKey:formkey];
				FormItemVO *formvo=[[FormItemVO alloc]init];
				for(NSString *key in formitem){
					[formvo setValue:[formitem objectForKey:@"key" forKey:key]];
				}
				[formviewdict setValue:formvo forKey:formkey];
			}
		}
		
		
		
	}else {
		
		[self stylesheetFailed];
	}
	
}


#pragma mark Data path methods
// @private
-(NSString*)dataPath{
	return [[NSBundle mainBundle] pathForResource:kFormManagerDataFile ofType:@"plist"];
}



@end
