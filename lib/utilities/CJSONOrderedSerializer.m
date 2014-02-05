//
//  CJSONOrderedSerializer.m
//  CycleStreets
//
//  Created by Neil Edwards on 05/02/2014.
//  Copyright (c) 2014 CycleStreets Ltd. All rights reserved.
//

#import "CJSONOrderedSerializer.h"

@implementation CJSONOrderedSerializer



- (NSData *)serializeDictionary:(NSDictionary *)inDictionary error:(NSError **)outError
{
    NSMutableData *theData = [NSMutableData data];
	
    [theData appendBytes:"{" length:1];
	
    NSArray *theKeys = [inDictionary allKeys];
	
	theKeys = [theKeys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
		return [(NSString *)obj1 compare:(NSString *)obj2 options:NSNumericSearch];
	}];
	
	
    NSEnumerator *theEnumerator = [theKeys objectEnumerator];
    NSString *theKey = NULL;
    while ((theKey = [theEnumerator nextObject]) != NULL)
	{
        id theValue = [inDictionary objectForKey:theKey];
        
        NSData *theKeyData = [self serializeString:theKey error:outError];
        if (theKeyData == NULL)
		{
            return(NULL);
		}
        NSData *theValueData = [self serializeObject:theValue error:outError];
        if (theValueData == NULL)
		{
            return(NULL);
		}
        
        
        [theData appendData:theKeyData];
        [theData appendBytes:":" length:1];
        [theData appendData:theValueData];
        
        if (theKey != [theKeys lastObject])
            [theData appendData:[@"," dataUsingEncoding:NSASCIIStringEncoding]];
	}
	
    [theData appendBytes:"}" length:1];
	
    return(theData);
}




@end
