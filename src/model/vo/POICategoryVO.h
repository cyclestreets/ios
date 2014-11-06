//
//  POITypeVO.h
//  CycleStreets
//
//  Created by Neil Edwards on 20/10/2011.
//  Copyright (c) 2011 CycleStreets Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BUCodableObject.h"

@interface POICategoryVO : BUCodableObject<NSCopying>

@property (nonatomic, strong)	NSString		*key;
@property (nonatomic, strong)	NSString		*name;
@property (nonatomic, strong)	NSString		*shortname;
@property (nonatomic)	int						total;
@property (nonatomic, strong)	NSString		*imageName;


@property (nonatomic,assign)  BOOL				selected;

@end
