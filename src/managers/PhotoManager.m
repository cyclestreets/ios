//
//  PhotoManager.m
//  CycleStreets
//
//  Created by Neil Edwards on 13/04/2011.
//  Copyright 2011 CycleStreets Ltd. All rights reserved.
//

#import "PhotoManager.h"
#import "UserAccount.h"
#import "BUResponseObject.h"
#import "CycleStreets.h"
#import "BUNetworkOperation.h"
#import "UserVO.h"
#import "GlobalUtilities.h"
#import "HudManager.h"
#import "GenericConstants.h"
#import "BUDataSourceManager.h"
#import "BuildTargetConstants.h"

@interface PhotoManager()


@property (nonatomic, assign) BOOL						showingHUD;
@property (nonatomic, strong) NSTimer					* retreiveTimer;

@end



@implementation PhotoManager
SYNTHESIZE_SINGLETON_FOR_CLASS(PhotoManager);


#pragma mark - Notifications
//
/***********************************************
 * @description		NOTIFICATIONS
 ***********************************************/
//

-(void)listNotificationInterests{
	
	[notifications addObject:REQUESTDIDCOMPLETEFROMSERVER];
	[notifications addObject:DATAREQUESTFAILED];
	[notifications addObject:REMOTEFILEFAILED];
	[notifications addObject:REQUESTDIDFAIL];
	[notifications addObject:XMLPARSERDIDFAILPARSING];
	
	[self addRequestID:RETREIVELOCATIONPHOTOS];
	[self addRequestID:RETREIVEROUTEPHOTOS];
	[self addRequestID:UPLOADUSERPHOTO];
	
	
	[super listNotificationInterests];
	
}

-(void)didReceiveNotification:(NSNotification*)notification{
	
	[super didReceiveNotification:notification];
	NSDictionary	*dict=[notification userInfo];
	BUNetworkOperation		*response=[dict objectForKey:RESPONSE];
	
	NSString	*dataid=response.dataid;
	BetterLog(@"response.dataid=%@",response.dataid);
	
	if([self isRegisteredForRequest:dataid]){
		
		if([notification.name isEqualToString:REMOTEFILEFAILED] || [notification.name isEqualToString:DATAREQUESTFAILED] || [notification.name isEqualToString:SERVERCONNECTIONFAILED] || [notification.name isEqualToString:REQUESTDIDFAIL] || [notification.name isEqualToString:XMLPARSERDIDFAILPARSING]){
			
			[[HudManager sharedInstance] removeHUD];
			
			if([dataid isEqualToString:RETREIVELOCATIONPHOTOS]){
				NSDictionary *dict=[NSDictionary dictionaryWithObjectsAndKeys:ERROR,@"status", nil];
				[[NSNotificationCenter defaultCenter] postNotificationName:RETREIVELOCATIONPHOTOSRESPONSE object:dict userInfo:nil];
				
			}else if([dataid isEqualToString:UPLOADUSERPHOTO]){
				
				NSDictionary *dict=[[NSDictionary alloc] initWithObjectsAndKeys:ERROR,STATE,EMPTYSTRING,MESSAGE, nil];
				[[NSNotificationCenter defaultCenter] postNotificationName:UPLOADUSERPHOTORESPONSE object:nil userInfo:dict];
				
				[[HudManager sharedInstance] showHudWithType:HUDWindowTypeError withTitle:@"Photo upload failed" andMessage:nil];
			}
		}

		
	}
	
	
	
}




#pragma mark - Photo Downloading

-(void)retrievePhotosForLocationBounds:(CLLocationCoordinate2D)ne withEdge:(CLLocationCoordinate2D)sw{
    [self retrievePhotosForLocationBounds:ne withEdge:sw withLimit:25 fordataID:RETREIVELOCATIONPHOTOS];
}
-(void)retrievePhotosForRouteBounds:(CLLocationCoordinate2D)ne withEdge:(CLLocationCoordinate2D)sw{
    [self retrievePhotosForLocationBounds:ne withEdge:sw withLimit:25 fordataID:RETREIVEROUTEPHOTOS];
}


-(void)retrievePhotosForLocationBounds:(CLLocationCoordinate2D)ne withEdge:(CLLocationCoordinate2D)sw withLimit:(int)limit fordataID:(NSString*)dataid{
	
	BetterLog(@"");
	
	if(_showingHUD==NO){
		[[HudManager sharedInstance] showHudWithType:HUDWindowTypeProgress withTitle:@"" andMessage:nil andDelay:0 andAllowTouch:NO];
		_showingHUD=YES;
	}

    CLLocationCoordinate2D centre;
    centre.latitude = (ne.latitude + sw.latitude)/2;
    centre.longitude = (ne.longitude + sw.longitude)/2;
    
    NSMutableDictionary *parameters=[NSMutableDictionary dictionaryWithObjectsAndKeys:[CycleStreets sharedInstance].APIKey,@"key",
                                     [NSNumber numberWithFloat:centre.longitude],@"longitude",
                                     [NSNumber numberWithFloat:centre.latitude],@"latitude",
                                     [NSNumber numberWithFloat:ne.latitude],@"n",
                                     [NSNumber numberWithFloat:ne.longitude],@"e",
                                     [NSNumber numberWithFloat:sw.latitude],@"s",
                                     [NSNumber numberWithFloat:sw.longitude],@"w",
                                     [NSNumber numberWithInt:13],@"zoom",
                                     @"1",@"useDom",
                                     @"300",@"thumbnailsize",
                                     [NSNumber numberWithInt:limit],@"limit",
                                      @"1",@"suppressplaceholders",
                                     @"1",@"minimaldata",
									 [self uploadPhotoId],@"selectedid",
                                     nil];
	// cns option
	if([[APPLICATIONNAME lowercaseString] isEqualToString:@"cyclenorthstaffs"]){
		[parameters setObject:API_IDENTIFIER forKey:@"username"];
	}
    
    BUNetworkOperation *request=[[BUNetworkOperation alloc]init];
    request.dataid=dataid;
    request.requestid=ZERO;
    request.parameters=parameters;
    request.source=DataSourceRequestCacheTypeUseNetwork;
	
	if([dataid isEqualToString:RETREIVELOCATIONPHOTOS]){
		
		request.completionBlock=^(BUNetworkOperation *operation, BOOL complete,NSString *error){
		
			[self retrievePhotosForLocationResponse:operation];
		
		};

		
	}else{
		
		request.completionBlock=^(BUNetworkOperation *operation, BOOL complete,NSString *error){
			
			[self retrievePhotosForRouteResponse:operation];
			
		};
		
	}
	
	[[BUDataSourceManager sharedInstance] processDataRequest:request];
	
    
    NSDictionary *dict=[[NSDictionary alloc] initWithObjectsAndKeys:request,REQUEST,nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:REQUESTDATAREFRESH object:nil userInfo:dict];


}





-(void)retrievePhotosForLocationResponse:(BUNetworkOperation*)response{
	
	[[HudManager sharedInstance]removeHUD:NO];
	_showingHUD=NO;
	
	    
    switch (response.responseStatus) {
            
        case ValidationRetrievePhotosSuccess:
		{	
			self.locationPhotoList=response.responseObject;
			NSDictionary *dict=[NSDictionary dictionaryWithObjectsAndKeys:SUCCESS,@"status", nil];
			[[NSNotificationCenter defaultCenter] postNotificationName:RETREIVELOCATIONPHOTOSRESPONSE object:dict userInfo:nil];
		}   
		break;
          
		case ValidationRetrievePhotosFailed:
		{	
			NSDictionary *dict=[NSDictionary dictionaryWithObjectsAndKeys:ERROR,@"status", nil];
			[[NSNotificationCenter defaultCenter] postNotificationName:RETREIVELOCATIONPHOTOSRESPONSE object:dict userInfo:nil];
        
		}
		break;
        default:
			
		break;
    }
    
    
}



-(void)retrievePhotosForRouteResponse:(BUNetworkOperation*)response{
	
	BetterLog(@"");
	
	[[HudManager sharedInstance]removeHUD:NO];
	_showingHUD=NO;
	
	
    switch (response.responseStatus) {
            
        case ValidationRetrievePhotosSuccess:
		{
			self.routePhotoList=response.responseObject;
			NSDictionary *dict=[NSDictionary dictionaryWithObjectsAndKeys:SUCCESS,@"status", nil];
			[[NSNotificationCenter defaultCenter] postNotificationName:RETREIVEROUTEPHOTOSRESPONSE object:dict userInfo:nil];
		}
			break;
			
		case ValidationRetrievePhotosFailed:
		{
			NSDictionary *dict=[NSDictionary dictionaryWithObjectsAndKeys:ERROR,@"status", nil];
			[[NSNotificationCenter defaultCenter] postNotificationName:RETREIVEROUTEPHOTOSRESPONSE object:dict userInfo:nil];
			
		}
			break;
        default:
			
			break;
    }
    
    
}


-(void)assesRetrievedComplete{
	
	if(_showingHUD==YES){
		[_retreiveTimer invalidate];
		[[HudManager sharedInstance]removeHUD:NO];
		_showingHUD=NO;
	}
}


#pragma mark - Photo Upload
//
/***********************************************
 * @description			Upload methods
 ***********************************************/
//

-(void)UserPhotoUploadRequest:(UploadPhotoVO*)photo{
    
    self.uploadPhoto=photo;
	
    
    NSMutableDictionary *getparameters=[NSMutableDictionary dictionaryWithObject:[CycleStreets sharedInstance].APIKey forKey:@"key"];
	
	NSMutableDictionary *postparameters=[_uploadPhoto uploadParams];
	
	postparameters[@"username"]=[UserAccount sharedInstance].user.username;
	postparameters[@"password"]=[UserAccount sharedInstance].userPassword;
	
	NSMutableDictionary *parameters=[NSMutableDictionary dictionaryWithObjectsAndKeys:getparameters,@"getparameters",postparameters,@"postparameters", nil];
    
    BUNetworkOperation *request=[[BUNetworkOperation alloc]init];
	request.dataid=UPLOADUSERPHOTO;
	request.requestid=ZERO;
	request.parameters=parameters;
	request.source=DataSourceRequestCacheTypeUseNetwork;
	request.trackProgress=YES;
	
	request.completionBlock=^(BUNetworkOperation *operation, BOOL complete,NSString *error){
			
		[self UserPhotoUploadResponse:operation];
			
	};
	
	request.progressBlock=^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite){
		
		NSDictionary *progressDict=@{@"bytesWritten":@(bytesWritten),@"totalBytesWritten":@(totalBytesWritten),@"totalBytesExpectedToWrite":@(totalBytesExpectedToWrite)};
		[[NSNotificationCenter defaultCenter] postNotificationName:FILEUPLOADPROGRESS object:nil userInfo:progressDict];
		
	};
	
	[[BUDataSourceManager sharedInstance] processDataRequest:request];

	
	[[HudManager sharedInstance] showHudWithType:HUDWindowTypeProgress withTitle:@"Uploading Photo" andMessage:nil];
	
    
    
    
}


-(void)UserPhotoUploadResponse:(BUNetworkOperation*)result{
	
	BetterLog(@"");
    
    switch(result.responseStatus){
            
		case ValidationUserPhotoUploadSuccess:
		{
            _uploadPhoto.responseDict=result.responseObject;
			
			NSDictionary *dict=[[NSDictionary alloc] initWithObjectsAndKeys:SUCCESS,STATE, nil];
			[[NSNotificationCenter defaultCenter] postNotificationName:UPLOADUSERPHOTORESPONSE object:nil userInfo:dict];
			
			[[HudManager sharedInstance] showHudWithType:HUDWindowTypeSuccess withTitle:@"Photo uploaded" andMessage:nil];
         
		}
		break;
			
		case ValidationUserPhotoUploadFailed:
		{	
			NSDictionary *dict=[[NSDictionary alloc] initWithObjectsAndKeys:ERROR,STATE,result.validationMessage,MESSAGE, nil];
			[[NSNotificationCenter defaultCenter] postNotificationName:UPLOADUSERPHOTORESPONSE object:nil userInfo:dict];
			
			[[HudManager sharedInstance] showHudWithType:HUDWindowTypeError withTitle:@"Photo upload failed" andMessage:nil];
		}   
		break;
			
		default:
			[[HudManager sharedInstance]removeHUD];
		break;
            
            
	}

}



#pragma mark - Utility
//
/***********************************************
 * @description			UTILITY
 ***********************************************/
//


-(NSString*)uploadPhotoId{
	
	if(_uploadPhoto==nil)
		return ZERO;
	
	return _uploadPhoto.uploadedPhotoId;
}


-(BOOL)isUserPhoto:(PhotoMapVO*)photo{
	
	if(_uploadPhoto==nil)
		return NO;
	
	if(_uploadPhoto.responseDict!=nil){
		
		NSString *uploadid=_uploadPhoto.uploadedPhotoId;
		
		if([photo.csid isEqualToString:uploadid]){
			return YES;
		}
	}
	
	return NO;
}


#pragma mark - Dev only

-(void)createAutoLoadLocation{
	
	self.autoLoadLocation=[[CLLocation alloc]initWithLatitude:51.00000 longitude:0.200000];
	
}



@end
