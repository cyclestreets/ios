//
//  PhotoCategoryVO.m
//  CycleStreets
//
//  Created by Gaby Jones on 17/04/2012.
//  Copyright (c) 2012 CycleStreets Ltd. All rights reserved.
//

#import "PhotoCategoryVO.h"

@implementation PhotoCategoryVO
@synthesize name;
@synthesize tag;


static NSString *kNAME = @"name";
static NSString *kTAG = @"tag";



//=========================================================== 
//  Keyed Archiving
//
//=========================================================== 
- (void)encodeWithCoder:(NSCoder *)encoder 
{
    [encoder encodeObject:self.name forKey:kNAME];
    [encoder encodeObject:self.tag forKey:kTAG];
}

- (id)initWithCoder:(NSCoder *)decoder 
{
    self = [super init];
    if (self) {
        self.name = [decoder decodeObjectForKey:kNAME];
        self.tag = [decoder decodeObjectForKey:kTAG];
    }
    return self;
}



@end
