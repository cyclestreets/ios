//
//  UIBarButtonItem+PXStyling.h
//  Pixate
//
//  Created by Kevin Lindsey on 12/11/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Pixate/PXVirtualControl.h>

/**
 *
 *  UIBarButtonItem supports the following element name:
 *
 *  - bar-button-item
 *
 *  UIBarButtonItem supports the following  children:
 *
 *  - icon
 *
 *  UIBarButtonItem icon supports the following properties:
 *
 *  - PXShapeStyler
 *  - PXFillStyler
 *  - PXBorderStyler
 *  - PXBoxShadowStyler
 *  - -ios-rendering-mode: original | template | automatic // iOS7 or later
 *
 *  UIBarButtonItem supports the following properties:
 *
 *  - PXOpacityStyler
 *  - PXShapeStyler
 *  - PXFillStyler
 *  - PXBorderStyler
 *  - PXBoxShadowStyler
 *  - PXFontStyler
 *  - PXPaintStyler
 *  - PXTextContentStyler
 *  - -ios-tint-color: <paint>
 *
 *  UIBarButtonItem supports the following pseudo-class states:
 *
 *  - normal
 *  - highlighted
 *  - disabled
 *
 */
@interface UIBarButtonItem (PXStyling) <PXVirtualControl>

// make styleParent writeable here
@property (nonatomic, readwrite, weak) id pxStyleParent;
    
// make pxStyleElementName writeable here
@property (nonatomic, readwrite, copy) NSString *pxStyleElementName;

@end
