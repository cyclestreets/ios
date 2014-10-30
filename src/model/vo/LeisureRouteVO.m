//
//  LeisureRouteVO.m
//  CycleStreets
//
//  Created by Neil Edwards on 26/10/2014.
//  Copyright (c) 2014 CycleStreets Ltd. All rights reserved.
//

#import "LeisureRouteVO.h"

#import "SettingsManager.h"

static NSString *const RouteTypeDuration=@"Duration";
static NSString *const RouteTypeDistance=@"Distance";



@implementation LeisureRouteVO


- (instancetype)init
{
	self = [super init];
	if (self) {
		_routeType=LeisureRouteTypeDuration;
		_routeValue=0;
		
	}
	return self;
}


-(LeisureRouteType)changeRouteType:(NSInteger)index{
	
	NSArray *routeTypes=[LeisureRouteVO routeTypes];
	_routeType=(LeisureRouteType)[routeTypes[index] integerValue];
	
	return _routeType;
	
}


// Note this should be based on percentage of slider
-(NSString*)readoutString{
	
	NSArray *valueRange=[LeisureRouteVO typeRangeArrayForRouteType:_routeType];
	
	if(_routeType==LeisureRouteTypeDistance){
		
		float actualValue=(_routeValue/100.0f) * ([valueRange[1] floatValue]-[valueRange[0] floatValue]);
		actualValue+=[valueRange[0] floatValue];										  
		
		return [NSString stringWithFormat:@"%i %@",(int)actualValue,[[SettingsManager sharedInstance] routeUnitisMiles] ? actualValue<2 ? @"mile" : @"miles":@"km"];
	}else{
		
		float actualValue=(_routeValue/100.0f) * ([valueRange[1] floatValue]-[valueRange[0] floatValue]);
		actualValue+=[valueRange[0] floatValue];
		
		return [NSString stringWithFormat:@"%i mins",(int)actualValue];
	}
	
}


-(NSString*)coordinateString{
	
	return [NSString stringWithFormat:@"%f, %f",_routeCoordinate.latitude,_routeCoordinate.longitude];
	
}



-(BOOL)isValid{
	
	return YES;
}

-(BOOL)validateValues{
	
	
	return YES;
}



#pragma mark - dataProviders

+(NSArray*)routeTypesStrings{
	return @[RouteTypeDuration,RouteTypeDistance];
}

+(NSArray*)routeTypes{
	return @[@(LeisureRouteTypeDuration),@(LeisureRouteTypeDistance)];
}

+(NSDictionary*)endPointsForRouteType:(LeisureRouteType)type{
	
	
	return @{};
}


+(NSArray*)typeRangeArrayForRouteType:(LeisureRouteType)type{
	
	if(type==LeisureRouteTypeDistance){
		return @[@(1),@(20)];
	}else{
		return @[@(10),@(120)];
	}
	
}



@end
