//
//  PXVirtualControl.h
//  Pixate
//
// !WARNING!  Do not include this header file directly in your application.
//            This file is not part of the public Pixate API and will likely change.
//
//  Created by Kevin Lindsey on 10/16/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Pixate/PXStyleable.h>

@protocol PXVirtualControl <PXStyleable>

@property (nonatomic, readonly) BOOL isVirtualControl;

@end
