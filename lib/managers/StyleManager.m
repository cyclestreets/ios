//
//  StyleManager.m
//
//
//  Created by neil on 25/11/2009.
//  Copyright 2009 Buffer. All rights reserved.
//

#import "StyleManager.h"
#import "GlobalUtilities.h"
#import "SynthesizeSingleton.h"
#import "UIColor-Expanded.h"
#import "AppConstants.h"
#import "GenericConstants.h"


@interface StyleManager(Private) 

-(void)loadStyleSheet;
-(void)styleSheetLoaded;
-(void)stylesheetFailed;
-(NSString*)dataPath;
@end




@implementation StyleManager
SYNTHESIZE_SINGLETON_FOR_CLASS(StyleManager);
@synthesize styleDict;
@synthesize colors;
@synthesize fonts;
@synthesize uiimages;
@synthesize delegate;




-(id)init{
	
	if (self = [super init])
	{
	}
	return self;
}


-(void)initialise{
	[self loadStyleSheet];
}


#pragma mark Style sheet loading methods
// @private
-(void)loadStyleSheet{
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:[self dataPath]]){
		
		styleDict = [[NSMutableDictionary alloc] initWithContentsOfFile:[self dataPath]];
		[self styleSheetLoaded];
		
	}else {
		[self stylesheetFailed];
	}

}


// @private
-(void)styleSheetLoaded{
	
	colors=[styleDict objectForKey:@"colors"];
	fonts=[styleDict objectForKey:@"fonts"];
	uiimages=[styleDict objectForKey:@"uiimages"];
	self.delegate=nil;
}


// @private
-(void)stylesheetFailed{
	
	if([delegate respondsToSelector:@selector(startupFailedWithError:)]){
		[delegate startupFailedWithError:STARTUPERROR_STYLESFAILED];
	}
	self.delegate=nil;
}




#pragma mark Accessor methods

// @public 
-(UIFont*)fontForType:(NSString*)type{
	
	// return a font spec for a specific srtyle type
	
	return [UIFont systemFontOfSize:12];
	
}

// @public 
-(UIColor*)colorForType:(NSString*)type{
	
	UIColor *color;
	
	if([colors objectForKey:type]!=nil){
		color=[UIColor colorWithHexString:[colors objectForKey:type]];
	}else{
		color=[UIColor	 redColor];
	}
	
	return color;
	
}

// @public 
-(UIImage*)imageForType:(NSString*)type{
	
	UIImage *image=nil;
	
	if([uiimages objectForKey:type]!=nil){
		image=[UIImage imageNamed:[uiimages objectForKey:type]];
	}
	if(image==nil){
		BetterLog(@"[ERROR] UI Image for UI type: %@ returned nil",type);
	}
	return image;
	
}


#pragma mark Data path methods
// @private
-(NSString*)dataPath{
	return [[NSBundle mainBundle] pathForResource:@"styles" ofType:@"plist"];
}


@end
