//
//  NSArray+Plist.m
//  CycleStreets
//
//  Created by Neil Edwards on 14/10/2014.
//  Copyright (c) 2014 CycleStreets Ltd. All rights reserved.
//

#import "NSMutableArray+Plist.h"

@implementation NSMutableArray (Plist)


-(BOOL)writeToPlistFile:(NSString*)filename{
	NSData * data = [NSKeyedArchiver archivedDataWithRootObject:self];
	NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString * documentsDirectory = [paths objectAtIndex:0];
	NSString * path = [documentsDirectory stringByAppendingPathComponent:filename];
	BOOL didWriteSuccessfull = [data writeToFile:path atomically:YES];
	return didWriteSuccessfull;
}

+(NSMutableArray*)readFromPlistFile:(NSString*)filename{
	NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString * documentsDirectory = [paths objectAtIndex:0];
	NSString * path = [documentsDirectory stringByAppendingPathComponent:filename];
	NSData * data = [NSData dataWithContentsOfFile:path];
	return  [NSKeyedUnarchiver unarchiveObjectWithData:data];
}


@end
