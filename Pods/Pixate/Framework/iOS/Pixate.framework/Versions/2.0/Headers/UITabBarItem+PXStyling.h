//
//  UITabBarItem+PXStyling.h
//  Pixate
//
//  Created by Kevin Lindsey on 10/31/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Pixate/PXVirtualControl.h>

/**
 *
 *  UITabBarItem supports the following element name:
 *
 *  - tab-bar-item
 *
 *  UITabBarItem supports the following pseudo-class states:
 *
 *  - normal (default)
 *  - selected
 *  - unselected
 *
 *  UITabBarItem supports the following properties:
 *
 *  - PXShapeStyler
 *  - PXFillStyler
 *  - PXBorderStyler
 *  - PXBoxShadowStyler
 *  - PXFontStyler
 *  - PXColorStyler
 *  - PXTextContentStyler
 *
 */
@interface UITabBarItem (PXStyling) <PXVirtualControl>

// make styleParent writeable here
@property (nonatomic, readwrite, weak) id pxStyleParent;

@end
