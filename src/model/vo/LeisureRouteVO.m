//
//  LeisureRouteVO.m
//  CycleStreets
//
//  Created by Neil Edwards on 26/10/2014.
//  Copyright (c) 2014 CycleStreets Ltd. All rights reserved.
//

#import "LeisureRouteVO.h"
#import "GlobalUtilities.h"
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
		_poiArray=[NSMutableArray array];
		
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
		
		NSArray *scaleArr=@[@(1),@(1.2),@(1.5),@(1.75),@(2),@(2.25),@(2.5),@(2.75),@(3),@(3.5),@(4)];
	
		int scaleIndex=_routeValue;
		float scaledValue;
		scaleIndex=scaleIndex/10;
		scaledValue=_routeValue*[scaleArr[scaleIndex] floatValue];
		
		scaledValue+=[valueRange[0] floatValue];
		
		return [NSString stringWithFormat:@"%i %@",(int)scaledValue,[[SettingsManager sharedInstance] routeUnitisMiles] ? scaledValue<2 ? @"mile" : @"miles":@"km"];
	}else{
		
		NSArray *scaleArr=@[@(1),@(1.2),@(1.5),@(2),@(2.5),@(3),@(3.5),@(4),@(5),@(6),@(7)];
		
		int scaleIndex=_routeValue;
		float scaledValue;
		scaleIndex=scaleIndex/10;
		scaledValue=_routeValue*[scaleArr[scaleIndex] floatValue];
		
		scaledValue+=[valueRange[0] floatValue];
		
		return [NSString stringWithFormat:@"%i mins",(int)scaledValue];
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
		return @[@(1),@(400)];
	}else{
		return @[@(30),@(730)];
	}
	
}



@end
