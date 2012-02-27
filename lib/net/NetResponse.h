//
//  NetResponse.h
//  CycleStreets
//
//  Created by Neil Edwards on 14/01/2010.
//  Copyright 2010 CycleStreets.. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppConstants.h"

@interface NetResponse : NSObject {
	NSString				*dataid;
	NSString				*requestid;
	id						dataProvider; // could be ma or vo
	BOOL					updated;
	NSMutableData			*responseData;
	NSString				*revisionId;
	NSString				*error;
	BOOL					status;
	DataParserType			dataType;
}
@property (nonatomic, retain)		NSString		* dataid;
@property (nonatomic, retain)		NSString		* requestid;
@property (nonatomic, retain)		id		 dataProvider;
@property (nonatomic)		BOOL		 updated;
@property (nonatomic, retain)		NSMutableData		* responseData;
@property (nonatomic, retain)		NSString		* revisionId;
@property (nonatomic, retain)		NSString		* error;
@property (nonatomic)		BOOL		 status;
@property (nonatomic)		DataParserType		 dataType;


@end
