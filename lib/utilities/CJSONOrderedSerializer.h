//
//  CJSONOrderedSerializer.h
//  CycleStreets
//
//  Created by Neil Edwards on 05/02/2014.
//  Copyright (c) 2014 CycleStreets Ltd. All rights reserved.
//

#import "CJSONSerializer.h"

@interface CJSONOrderedSerializer : CJSONSerializer


- (NSData *)serializeDictionary:(NSDictionary *)inDictionary error:(NSError **)outError;

@end
