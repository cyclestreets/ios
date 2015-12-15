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


@interface LeisureRouteVO()

@property (nonatomic,assign)  float								finalScaledValue;

@end


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
		
		float topvalue=[valueRange.lastObject floatValue];
		float percent=((float)_routeValue/100);
		_finalScaledValue=percent*topvalue;
		
//		NSArray *scaleArr=@[@(1),@(1.2),@(1.5),@(1.75),@(2),@(2.25),@(2.5),@(2.75),@(3),@(3.5),@(4)];
//	
//		int scaleIndex=_routeValue;
//		float scaledValue;
//		scaleIndex=scaleIndex/10;
//		scaledValue=_routeValue*[scaleArr[scaleIndex] floatValue];
//		
//		scaledValue+=[valueRange[0] floatValue];
		
		//_finalScaledValue=scaledValue;
		
		return [NSString stringWithFormat:@"%i %@",(int)_finalScaledValue,[[SettingsManager sharedInstance] routeUnitisMiles] ? _finalScaledValue<2 ? @"mile" : @"miles":@"km"];
	}else{
		
		float topvalue=[valueRange.lastObject floatValue];
		float percent=((float)_routeValue/100);
		_finalScaledValue=percent*topvalue;
		
//		NSArray *scaleArr=@[@(1),@(1.2),@(1.5),@(2),@(2.5),@(3),@(3.5),@(4),@(5),@(6),@(7)];
//		
//		int scaleIndex=_routeValue;
//		float scaledValue;
//		scaleIndex=scaleIndex/10;
//		scaledValue=_routeValue*[scaleArr[scaleIndex] floatValue];
//		
//		scaledValue+=[valueRange[0] floatValue];
//		
//		_finalScaledValue=scaledValue;
		
		return [NSString stringWithFormat:@"%i mins",(int)_finalScaledValue];
	}
	
}


#pragma mark - getters


-(NSString*)coordinateString{
	
	return [NSString stringWithFormat:@"%f,%f",_routeCoordinate.longitude,_routeCoordinate.latitude];
	
}


-(BOOL)hasPOIs{
	return _poiArray.count>0;
}

-(NSString*)poiKeys{
	
	NSArray *arr=[_poiArray valueForKey:@"key"];
	return [arr componentsJoinedByString:@","];
	
}

-(NSString*)routeValueString{
	
	if(_routeType==LeisureRouteTypeDistance){
		
		if([[SettingsManager sharedInstance] routeUnitisMiles]){
			
			return [NSString stringWithFormat:@"%i", (int)(_finalScaledValue*1.6)*1000];
			
		}else{
			
			return [NSString stringWithFormat:@"%i", (int)_finalScaledValue*1000];
			
		}
		
		
	}else{
		
		return [NSString stringWithFormat:@"%i", (int)_finalScaledValue*60];
		
	}
	
}




#pragma mark -  validation


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
		return @[@(1),@(10)];
	}else{
		return @[@(15),@(60)];
	}
	
}



@end
