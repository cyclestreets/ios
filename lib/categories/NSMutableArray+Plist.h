//
//  NSArray+Plist.h
//  CycleStreets
//
//  Created by Neil Edwards on 14/10/2014.
//  Copyright (c) 2014 CycleStreets Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (Plist)

-(BOOL)writeToPlistFile:(NSString*)filename;


+(NSMutableArray*)readFromPlistFile:(NSString*)filename;

@end
