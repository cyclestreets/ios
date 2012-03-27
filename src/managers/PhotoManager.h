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

@interface PhotoManager : FrameworkObject {
    
    UploadPhotoVO               *uploadPhoto;
    
    CLLocation                  *autoLoadLocation;
	
	PhotoMapListVO				*locationPhotoList;

}
SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(PhotoManager);
@property (nonatomic, retain)	UploadPhotoVO			*uploadPhoto;
@property (nonatomic, retain)	CLLocation			*autoLoadLocation;
@property (nonatomic, retain)	PhotoMapListVO			*locationPhotoList;

-(void)retrievePhotosForLocationBounds:(CLLocationCoordinate2D)ne withEdge:(CLLocationCoordinate2D)sw;
-(void)retrievePhotosForLocationBounds:(CLLocationCoordinate2D)ne withEdge:(CLLocationCoordinate2D)sw withLimit:(int)limit;


-(void)uploadPhotoForUser:(UserVO*)user withImage:(NSData*)imageData andProperties:(NSMutableDictionary*)postparameters;


-(void)UserPhotoUploadRequest:(UploadPhotoVO*)photo;


@end
