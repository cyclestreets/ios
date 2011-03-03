//
//  StringManager.m
//  NagMe
//
//  Created by Neil Edwards on 19/02/2010.
//  Copyright 2010 Chroma. All rights reserved.
//

#import "StringManager.h"
#import "SynthesizeSingleton.h"
#import "AppConstants.h"
#import "GlobalUtilities.h"

@interface StringManager(Private)

-(void)loadfile;
-(void)fileFailed;
-(void)fileLoaded;
-(NSString*)dataPath;

@end


@implementation StringManager
SYNTHESIZE_SINGLETON_FOR_CLASS(StringManager);
@synthesize stringsDict;
@synthesize delegate;


/***********************************************************/
// dealloc
/***********************************************************/
- (void)dealloc
{
    [stringsDict release], stringsDict = nil;
    delegate = nil;
	
    [super dealloc];
}




-(id)init{
	if (self = [super init]){
		
	}
	return self;
}


-(void)initialise{
	[self loadfile];
}


#pragma mark Style sheet loading methods
// @private
-(void)loadfile{
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:[self dataPath]]){
		
		stringsDict = [[NSMutableDictionary alloc] initWithContentsOfFile:[self dataPath]];
		
	}else {
		
		[self fileFailed];
	}
	
}


// @private
-(void)fileFailed{
	if([delegate respondsToSelector:@selector(startupFailedWithError:)]){
		[delegate startupFailedWithError:STARTUPERROR_STRINGSFAILED];
	}
	
}





-(NSString*)stringForSection:(NSString*)section andType:(NSString*)type{
	
	NSString *string=@"";
	
	if([stringsDict objectForKey:section]!=nil){
		string=[[stringsDict objectForKey:section] objectForKey:type];
	}else {
		BetterLog(@"[ERROR] Unable to find string for key %@",type);
	}

	
	return string;
	
}





#pragma mark Data path methods
// @private
-(NSString*)dataPath{
	return [[NSBundle mainBundle] pathForResource:@"contentStrings" ofType:@"plist"];
}


@end
