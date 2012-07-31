//
//  FormItemVO.m
//  CycleStreets
//
//  Created by Neil Edwards on 20/12/2010.
//  Copyright 2010 CycleStreets Ltd. All rights reserved.
//

#import "FormItemVO.h"


@implementation FormItemVO
@synthesize itemid;
@synthesize validateType;
@synthesize parameters;
@synthesize errorString;
@synthesize itemType;
@synthesize mandatory;


- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}


@end
