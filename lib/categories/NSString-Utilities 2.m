//
//  NSString+_Utilities.m
//  RacingUK
//
//  Created by Neil Edwards on 08/12/2011.
//  Copyright (c) 2011 Chroma. All rights reserved.
//

#import "NSString-Utilities.h"

@implementation NSString (Utilities)

- (BOOL) containsString: (NSString*) substring
{    
    NSRange range = [self rangeOfString : substring];
	
    BOOL found = ( range.location != NSNotFound );
	
    return found;
}

@end
