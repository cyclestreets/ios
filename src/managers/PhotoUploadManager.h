//
//  PhotoUploadManager.h
//  CycleStreets
//
//  Created by neil on 13/03/2012.
//  Copyright (c) 2012 CycleStreets Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FrameworkObject.h"
#import "SynthesizeSingleton.h"
#import "UploadPhotoVO.h"

@interface PhotoUploadManager : FrameworkObject{
    
    
    
}
SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(PhotoUploadManager);

-(void)UserPhotoUploadRequest:(UploadPhotoVO*)photo;
@end
