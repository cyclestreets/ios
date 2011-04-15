//
//  PhotoManager.m
//  CycleStreets
//
//  Created by Neil Edwards on 13/04/2011.
//  Copyright 2011 CycleStreets Ltd. All rights reserved.
//

#import "PhotoManager.h"
#import "UserAccount.h"
#import "PhotoAsset.h"


@interface PhotoManager(Private)


-(void)uploadPhotoForUserResponse:(ValidationVO*)validation;


@end



@implementation PhotoManager
SYNTHESIZE_SINGLETON_FOR_CLASS(PhotoManager);


//
/***********************************************
 * @description		NOTIFICATIONS
 ***********************************************/
//

-(void)listNotificationInterests{
	
	[self initialise];
	
	[super listNotificationInterests];
	
}

-(void)didReceiveNotification:(NSNotification*)notification{
	
	[super didReceiveNotification:notification];
	
	
}



-(void)uploadPhotoForUser:(PhotoAsset*)image{
	
	
	
	
	
	
}


-(void)uploadPhotoForUserResponse:(ValidationVO*)validation{
	
	
	switch(validation.validationStatus){
		
		case 0:
		
		break;
		
		
	}
	
}


@end
