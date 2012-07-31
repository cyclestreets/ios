//
//  POILocationVO.h
//  CycleStreets
//
//  Created by Neil Edwards on 21/10/2011.
//  Copyright (c) 2011 CycleStreets Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface POILocationVO : NSObject<NSCoding>{
	
	NSString				*locationid;
	
	CLLocation				*location;
	
	NSString				*name;
	NSString				*notes;
	NSString				*website;
	
}
@property (nonatomic, strong)	NSString		*locationid;
@property (nonatomic, strong)	CLLocation		*location;
@property (nonatomic, strong)	NSString		*name;
@property (nonatomic, strong)	NSString		*notes;
@property (nonatomic, strong)	NSString		*website;
@end
