//
//  POITypeVO.m
//  CycleStreets
//
//  Created by Neil Edwards on 20/10/2011.
//  Copyright (c) 2011 CycleStreets Ltd. All rights reserved.
//

#import "POICategoryVO.h"
#import "ImageCache.h"
#import "StringUtilities.h"

@implementation POICategoryVO


- (instancetype)init
{
	self = [super init];
	if (self) {
		
	}
	return self;
}


-(void)updateWithAPIDict:(NSDictionary*)dict{
	
	if(dict!=nil){
		
		_key=dict[@"id"];
		_name=dict[@"name"];
		_total=[dict[@"total"] intValue];
		
		
		UIImage *image=[StringUtilities imageFromString:dict[@"icon"]];
		NSString *imageFilename=[NSString stringWithFormat:@"Icon_POI_%@",_key];
		
		[[ImageCache sharedInstance] storeImage:image withName:imageFilename ofType:nil];
		[[ImageCache sharedInstance] saveImageToDisk:image withName:imageFilename ofType:nil];
		
		_imageName=imageFilename;
		
	}
	
}





- (id)copyWithZone:(NSZone *)zone
{
    id theCopy = [[[self class] allocWithZone:zone] init];  
    
	for (NSString *key in [self codableProperties]){
		
		id value = [self valueForKey:key];
		[theCopy setValue:[value copy] forKey:key];
		
	}
	
    return theCopy;
}


@end
