//
//  UIView+PXStyling.h
//  PXButtonDemo
//
//  Created by Kevin Lindsey on 8/22/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PXStyleable.h"

@interface UIView (PXStyling) <PXStyleable>

@property (nonatomic, copy) NSString *styleId;
@property (nonatomic, copy) NSString *styleClass;
@property (nonatomic, copy) NSString *styleCSS;
@property (nonatomic) PXStylingMode styleMode UI_APPEARANCE_SELECTOR;

@end
