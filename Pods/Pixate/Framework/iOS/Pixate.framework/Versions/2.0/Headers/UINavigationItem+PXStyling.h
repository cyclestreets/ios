//
//  UINavigationItem+PXStyling.h
//  Pixate
//
//  Created by Paul Colton on 10/15/13.
//  Copyright (c) 2013 Pixate, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PXStyleable.h"
#import <Pixate/PXVirtualControl.h>

/**
 *
 *  UINavigationItem supports the following element name:
 *
 *  - navigation-item
 *
 *  UINavigationItem supports the following properties:
 *
 *  - PXFillStyler
 *  - PXBorderStyler
 *  - PXBoxShadowStyler
 *  - PXOpacityStyler
 *  - PXTextContentStyler
 *  - text-transform: lowercase | uppercase | capitalize
 *
 *  UINavigationItem adds support for the following children:
 *
 *  - back-bar-button // see bar-button-item
 *  - left-bar-button // see bar-button-item
 *  - right-bar-button // see bar-button-item
 *
 */

@interface UINavigationItem (PXStyling) <PXVirtualControl>

// make styleParent writeable here
@property (nonatomic, readwrite, weak) id pxStyleParent;

// make pxStyleElementName writeable here
@property (nonatomic, readwrite, copy) NSString *pxStyleElementName;

@end
