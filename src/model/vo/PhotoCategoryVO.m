//
//  PhotoCategoryVO.m
//  CycleStreets
//
//  Created by Gaby Jones on 17/04/2012.
//  Copyright (c) 2012 CycleStreets Ltd. All rights reserved.
//

#import "PhotoCategoryVO.h"

@implementation PhotoCategoryVO



static NSString *kNAME = @"name";
static NSString *kTAG = @"tag";
static NSString *KCATEGORYTAG = @"categoryType";



//=========================================================== 
//  Keyed Archiving
//
//=========================================================== 
- (void)encodeWithCoder:(NSCoder *)encoder 
{
    [encoder encodeObject:_name forKey:kNAME];
    [encoder encodeObject:_tag forKey:kTAG];
	[encoder encodeInt:_categoryType forKey:KCATEGORYTAG];
}

- (id)initWithCoder:(NSCoder *)decoder 
{
    self = [super init];
    if (self) {
        self.name = [decoder decodeObjectForKey:kNAME];
        self.tag = [decoder decodeObjectForKey:kTAG];
		self.categoryType = [decoder decodeIntForKey:KCATEGORYTAG];
    }
    return self;
}



@end
