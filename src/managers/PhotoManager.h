//
//  PhotoManager.h
//  CycleStreets
//
//  Created by Neil Edwards on 13/04/2011.
//  Copyright 2011 CycleStreets Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FrameworkObject.h"
#import "SynthesizeSingleton.h"
#import "UserVO.h"
#import <CoreLocation/CoreLocation.h>
#import "PhotoMapListVO.h"
#import "UploadPhotoVO.h"
#import "PhotoMapVO.h"

@interface PhotoManager : FrameworkObject {
    

}
SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(PhotoManager);

@property (nonatomic, strong) PhotoMapListVO			* locationPhotoList;
@property (nonatomic, strong) PhotoMapListVO			* routePhotoList;

@property (nonatomic, strong) UploadPhotoVO				* uploadPhoto;
@property (nonatomic, strong) CLLocation				* autoLoadLocation;

-(void)retrievePhotosForLocationBounds:(CLLocationCoordinate2D)ne withEdge:(CLLocationCoordinate2D)sw;
-(void)retrievePhotosForRouteBounds:(CLLocationCoordinate2D)ne withEdge:(CLLocationCoordinate2D)sw;

-(void)UserPhotoUploadRequest:(UploadPhotoVO*)photo;

-(BOOL)isUserPhoto:(PhotoMapVO*)photo;




@end
