//
//  CSUserRouteVO.m
//  CycleStreets
//
//  Created by Neil Edwards on 09/12/2014.
//  Copyright (c) 2014 CycleStreets Ltd. All rights reserved.
//

#import "CSUserRouteVO.h"

#import "NSDate+Helper.h"

@interface CSUserRouteVO()

@property (nonatomic,strong,readwrite)  NSString				*name;
@property (nonatomic,strong,readwrite)  NSString				*routeid;
@property (nonatomic,strong,readwrite)  NSArray					*plans;
@property (nonatomic,strong,readwrite)  NSString				*url;

@property (nonatomic,strong)  NSString							*datetime;

@end

@implementation CSUserRouteVO


- (instancetype)initWithDictionary:(NSDictionary*)dict
{
	self = [super init];
	if (self) {
		[self updateRouteWithDict:dict];
	}
	return self;
}


-(void)updateRouteWithDict:(NSDictionary*)dict{
	
	
	for (NSString *key in [self codableProperties]){
		
		NSString *localkey=key;
		if([key isEqualToString:@"routeid"])
			localkey=@"id";
		
		NSString *value=[dict objectForKey:localkey];
		if (value==nil)
			continue;
		
		
		
		id newvalue=[dict valueForKey:localkey];
		if(newvalue!=nil){
			
			[self setValue:newvalue forKey:key];
			
		}
		
	}
	
}

// getters

-(NSDate*)date{
	
	NSDate *newdate=nil;
	if(_datetime!=nil){
		newdate=[NSDate dateFromString:_datetime withFormat:[NSDate dbFormatString]];
	}
	
	return newdate;
	
}


-(NSString*)dateString{
	
	NSDate *date=[self date];
	if(date!=nil){
		return [NSDate stringFromDate:date withFormat:[NSDate fullDateFormatString]];
	}
	
	return EMPTYSTRING;
}


@end
