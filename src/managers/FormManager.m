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
#import "FormItemVO.h"
#import "StringUtilities.h"


static NSString *const FORMVALIDATEEMAIL=@"FORMVALIDATEEMAIL";
static NSString *const FORMVALIDATEURL=@"FORMVALIDATEURL";
static NSString *const FORMVALIDATEMIN=@"FORMVALIDATEMIN";
static NSString *const FORMVALIDATERANGE=@"FORMVALIDATERANGE";
static NSString *const FORMVALIDATEREGEX=@"FORMVALIDATEREGEX";


@interface FormManager(Private)

-(NSString*)formTypeToString:(FormManagerFieldType)type;

-(BOOL)validateValueInRange:(int)value withParams:(NSDictionary*)parameters;
-(BOOL)validateString:(NSString*)str withParams:(NSString*)parameters;
-(BOOL)validateLength:(NSString*)str  withParams:(NSDictionary*)parameters;
-(BOOL)validatURL:(NSString *)str  withParams:(id)parameters;
-(BOOL)validateEmail:(NSString*)str withParams:(id)parameters;

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





-(id)init{
	if (self = [super init]){
		
		formLoaded=NO;
		
		validateMethods=[[NSDictionary alloc] initWithObjectsAndKeys:
					   [NSValue valueWithPointer:@selector(validateEmail:)],FORMVALIDATEEMAIL,
					   [NSValue valueWithPointer:@selector(validateURL:)],FORMVALIDATEURL,
					   [NSValue valueWithPointer:@selector(validateLength:forLength:)],FORMVALIDATEMIN,
						[NSValue valueWithPointer:@selector(validateString:forRegEx:)],FORMVALIDATEREGEX,
						 [NSValue valueWithPointer:@selector(validateValueInRange:minValue:maxValue:)],FORMVALIDATERANGE,
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
	
	return YES;
	
}




-(FormManagerError)validateFormForId:(NSString*)formid{
	
	if([formid isEqualToString:activeFormId]){
	
		activeFormFieldArray=[formDataProvider objectForKey:activeFormId];
		
		for(FormItemVO *formitem in activeFormFieldArray){
			
			// NOTE: all form methods need same signatue
			//SEL validatemethod=[[validateMethods objectForKey:formitem.validateType] pointerValue];
			//[self performSelector:validatemethod withObject:formitem.target withObject:formitem.parameters];
			
			
		}
		return kFormManagerErrorNone;
		
	}
	
	return kFormManagerErrorNotFound;
	
}


-(NSMutableArray*)errorArrayForForm:(NSString*)formid{
	
	// if has error, return error array for ui highlighting
	
	return nil;
}


//
/***********************************************
 * @description			VALIDATORS
 ***********************************************/
//

-(BOOL)validateEmail:(NSString*)str withParams:(id)parameters{
	return [StringUtilities validateEmail:str]; 
}

-(BOOL)validatURL:(NSString *)str  withParams:(id)parameters{
	// [GlobalUtilities validateURL:str];
	return YES;
}


-(BOOL)validateLength:(NSString*)str  withParams:(NSDictionary*)parameters{
	int length=1;
	return [str length]>=length;
}

-(BOOL)validateString:(NSString*)str withParams:(NSString*)parameters{
	
	if ([parameters isRegexValid]){
		return [str isMatchedByRegex:parameters];
	}else {
		return NO;
	}

}


// is valid date (is valid ie not 32/34/56 )
-(BOOL)validateDate:(NSString*)str withParams:(NSDictionary*)parameters{
	
	// is valid date
	
	// conforms to required input formatting
	
	return YES;
}


// is future date (ie cards)
-(BOOL)validateFutureDate:(NSString*)str withParams:(NSDictionary*)parameters{
	
	// is valid date
	
	// is in future
	return YES;
}

// is > date (ie age restrictions)
-(BOOL)validatePastDate:(NSString*)str withParams:(NSDictionary*)parameters{
	
	// is valid date
	
	// date< min date
	return YES;
}


// value>min && value<max
-(BOOL)validateValueInRange:(int)value withParams:(NSDictionary*)parameters{
	
	return NO;
	
}




-(NSString*)formTypeToString:(FormManagerFieldType)type{
	
	switch(type){
		
		case kFormFieldTypeTextField:
			return @"UITextField";
		break;
		case kFormFieldTypeSliderType:
			return @"UISlider";
		break;
		case kFormFieldTypeSwitchType:
			return @"UISwitch";
		break;
		
		default:
			return nil;
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
					[formvo setValue:[formitem objectForKey:@"key"] forKey:key];
				}
				[formviewdict setValue:formvo forKey:formkey];
			}
		}
		
		
		
	}else {
		
		//[self stylesheetFailed];
	}
	
}


#pragma mark Data path methods
// @private
-(NSString*)dataPath{
	return [[NSBundle mainBundle] pathForResource:kFormManagerDataFile ofType:@"plist"];
}



@end
