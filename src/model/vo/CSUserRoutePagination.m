//
//  CSUserRoutePagination.m
//  CycleStreets
//
//  Created by Neil Edwards on 15/01/2015.
//  Copyright (c) 2015 CycleStreets Ltd. All rights reserved.
//

#import "CSUserRoutePagination.h"

@interface CSUserRoutePagination()

@property (nonatomic,strong)  NSDictionary					*dataProvider;

@end

@implementation CSUserRoutePagination

- (instancetype)initWithDictionary:(NSDictionary*)dict
{
	self = [super init];
	if (self) {
		_dataProvider=dict;
	}
	return self;
}


-(NSInteger)currentCount{
	return [_dataProvider[@"count"] integerValue];
}

-(NSInteger)total{
	return [_dataProvider[@"total"] integerValue];
}

-(NSString*)bottomID{
	return _dataProvider[@"bottom"];
}

-(NSString*)topID{
	return _dataProvider[@"top"];
}

-(NSString*)earliestID{
	return _dataProvider[@"earliest"];
}


-(BOOL)hasEarlier{
	return _dataProvider[@"hasEarlier"];
	
}

@end
