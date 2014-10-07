//
//  NetResponse.h
//  Buffer
//
//  Created by Neil Edwards on 14/01/2010.
//  Copyright 2010 Buffer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GenericConstants.h"

@interface BUNetworkResponse : NSObject {

}

@property (nonatomic, strong)	NSString		*dataid;
@property (nonatomic, strong)	NSString		*requestid;
@property (nonatomic, strong)	NSString		*requestType;
@property (nonatomic, strong)	id				dataProvider;

@end
