//
//  PhotoCategoryVO.h
//  CycleStreets
//
//  Created by Gaby Jones on 17/04/2012.
//  Copyright (c) 2012 CycleStreets Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

enum{
	PhotoCategoryTypeCategory,
	PhotoCategoryTypeFeature
};
typedef int PhotoCategoryType;

@interface PhotoCategoryVO : NSObject<NSCoding>{
	
	NSString			*name;
	NSString			*tag;
	
	
	
}
@property (nonatomic, strong) NSString				* name;
@property (nonatomic, strong) NSString				* tag;
@property (nonatomic,assign)  PhotoCategoryType		categoryType;

@end
