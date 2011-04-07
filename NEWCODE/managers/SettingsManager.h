//
//  SettingsManager.h
//  CycleStreets
//
//  Created by neil on 22/02/2011.
//  Copyright 2011 CycleStreets Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SynthesizeSingleton.h"
#import "SettingsVO.h"

@interface SettingsManager : NSObject {
	
	SettingsVO				*dataProvider;

}
SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(SettingsManager);
@property (nonatomic, retain)		SettingsVO		* dataProvider;


@property (nonatomic,readonly)     BOOL		routeUnitisMiles;

-(void)loadData;
-(void)saveData;
@end
