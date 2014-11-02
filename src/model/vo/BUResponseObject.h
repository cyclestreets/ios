//
//  ValidationVO.h
//
//  Created by Neil Edwards on 16/02/2010.
//  Copyright 2010 CycleStreets. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppConstants.h"
#import "BUCodableObject.h"

@interface BUResponseObject : BUCodableObject


@property (nonatomic, assign)		BUResponseStatusCode		responseCode;  // code for response transaction status
@property (nonatomic, strong)		id							responseObject; // response data


@property (nonatomic,readonly) BUResponseStatusCode responseStatus;

-(BUResponseStatusCode)isReturnCodeValid;

@end
