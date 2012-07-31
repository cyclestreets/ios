//
//  RemoteFileManager.h
//  Racing UK
//
//  Created by Neil Edwards on 10/08/2009.
//  Copyright 2009 buffer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetRequest.h"
#import "SynthesizeSingleton.h"

@interface RemoteFileManager : NSObject {
	NSMutableData			*responseData;
	BOOL					networkAvailable;
	NSURLConnection			*myConnection;
	NSMutableArray			*requestQueue;
	NetRequest				*activeRequest;
	BOOL					queueRequests;
}
@property (nonatomic,strong)	NSMutableData			*responseData;
@property (nonatomic,strong)	NSURLConnection			*myConnection;
@property (nonatomic)			BOOL					networkAvailable;
@property(nonatomic,strong)		NSMutableArray			*requestQueue;
@property(nonatomic,strong)		NetRequest					*activeRequest;
@property (nonatomic)			BOOL						queueRequests;

SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(RemoteFileManager);
-(void)addRequestToQueue:(NetRequest*)request;
-(void)removeRequestFromQueue:(NSString*)type andResume:(BOOL)resume;
-(void)cancelAllRequests;
@end
