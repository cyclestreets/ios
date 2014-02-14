//
//  PXShapeView.h
//  Pixate
//
//  Created by Kevin Lindsey on 5/30/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PXShapeDocument.h"

/**
 *  PXShapeView serves as a convenience class for displaying vector graphics as defined by Pixate's ShapeKit.
 */
@interface PXShapeView : UIView

/**
 *  The top-level scene being rendered into this view
 */
@property (nonatomic, weak) PXShapeDocument *document;

/**
 *  The string path to a vector graphics file to be rendered into this view
 */
@property (nonatomic, strong) NSString *resourcePath;

/**
 *  Load a vector graphics file at the given URL. Note that this implementation currently supports like file resources
 *  only.
 *
 *  @param URL The URL to load
 */
- (void)loadSceneFromURL:(NSURL *)URL;

/**
 *  Create an image of the current display
 */
- (UIImage *)renderToImage;

/**
 *  Apply this views bounds to the content it contains. This may result in the content being scaled and/or shifted
 *  based on the scene's viewport settings
 */
- (void)applyBoundsToScene;

@end
