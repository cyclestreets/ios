//
//  SettingsVO.h
//  CycleStreets
//
//  Created by Neil Edwards on 31/03/2011.
//  Copyright 2011 CycleStreets Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SettingsVO : NSObject {

}


@property (nonatomic, strong)		NSString				* mapStyle;
@property (nonatomic, strong)		NSString				* routeUnit;
@property (nonatomic, strong)		NSString				* imageSize;
@property (nonatomic)		BOOL							autoEndRoute;

@property (nonatomic)		BOOL							migrationKey;
@end
