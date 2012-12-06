//
//  CSOverlayMapSource.h
//  CycleStreets
//
//  Created by Neil Edwards on 06/12/2012.
//  Copyright (c) 2012 CycleStreets Ltd. All rights reserved.
//

#import "RMAbstractMercatorWebSource.h"

/*!
 \brief Subclass of RMAbstractMercatorWebSource for access to the Open Cycle Map project's development server.
 
 Provides key-based access to tiles from the Open Cycle Map project.
 */
@interface CSOverlayMapSource : RMAbstractMercatorWebSource <RMAbstractMercatorWebSource>{
}

@end