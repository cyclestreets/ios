//
//  BuildTargetConstants.h
//  CycleStreets
//
//  Created by Neil Edwards on 09/10/2014.
//  Copyright (c) 2014 CycleStreets Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>


extern NSString *const API_IDENTIFIER;
extern NSString *const APPLICATIONNAME;
extern NSString *const CYCLENORTHSTAFFS;

extern BOOL const APIREQUIRESIDENTIFIER;


@interface BuildTargetConstants : NSObject

+(NSArray*)ApplicationSupportedMaps;

+(ApplicationBuildTarget)buildTarget;

+(void)insertAPIIdentifier:(NSMutableDictionary*)requestDict;

@end
