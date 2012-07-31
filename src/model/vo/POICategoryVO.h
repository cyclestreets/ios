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
@property (nonatomic, strong)	NSString		*key;
@property (nonatomic, strong)	NSString		*name;
@property (nonatomic, strong)	NSString		*shortname;
@property (nonatomic)	int				total;
@property (nonatomic, strong)	UIImage			*icon;
@end
