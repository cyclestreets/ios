//
//  POITypeVO.h
//  CycleStreets
//
//  Created by Neil Edwards on 20/10/2011.
//  Copyright (c) 2011 CycleStreets Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface POICategoryVO : NSObject<NSCoding>{
	
	NSString			*key;
	NSString			*name;
	NSString			*shortname;
	int					total;
	UIImage				*icon;
	
}
@property (nonatomic, retain)	NSString		*key;
@property (nonatomic, retain)	NSString		*name;
@property (nonatomic, retain)	NSString		*shortname;
@property (nonatomic)	int				total;
@property (nonatomic, retain)	UIImage			*icon;
@end
