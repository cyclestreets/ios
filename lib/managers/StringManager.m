//
//  StringManager.m
//
//
//  Created by Neil Edwards on 19/02/2010.
//  Copyright 2010 Buffer. All rights reserved.
//

#import "StringManager.h"
#import "SynthesizeSingleton.h"
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
    delegate = nil;
	
}




-(instancetype)init{
	if (self = [super init]){
		[self initialise];
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
		
        NSMutableDictionary *dict=[[NSMutableDictionary alloc] initWithContentsOfFile:[self dataPath]];
		self.stringsDict = dict;
		self.delegate=nil;
	}else {
		
		[self fileFailed];
	}
	
}


// @private
-(void)fileFailed{
	if([delegate respondsToSelector:@selector(startupFailedWithError:)]){
		[delegate startupFailedWithError:STARTUPERROR_STRINGSFAILED];
	}
	self.delegate=nil;
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
