//
//  MBProgressHUD+Additions.h
//  CycleStreets
//
//  Created by Neil Edwards on 18/12/2015.
//  Copyright © 2015 CycleStreets Ltd. All rights reserved.
//

#import "MBProgressHUD.h"
#import "GenericConstants.h"

@interface MBProgressHUD (Additions)

@property (nonatomic, readwrite, assign) BOOL cancelOperation;

@property (nonatomic, copy) GenericCompletionBlock cancelOperationBlock;


@end
