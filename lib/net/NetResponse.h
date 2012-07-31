//
//  NetResponse.h
//  Buffer
//
//  Created by Neil Edwards on 14/01/2010.
//  Copyright 2010 Buffer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetResponse : NSObject {
	NSString				*dataid;
	NSString				*requestid;  // unique request id
	NSString				*requestType;  // sub request id
	id						dataProvider; // could be ma or vo
	BOOL					updated;
	NSMutableData			*responseData;
	NSString				*revisionId;
	NSString				*error;
	BOOL					status;
	DataParserType			dataType;
}
@property (nonatomic, strong)	NSString		*dataid;
@property (nonatomic, strong)	NSString		*requestid;
@property (nonatomic, strong)	NSString		*requestType;
@property (nonatomic, strong)	id		dataProvider;
@property (nonatomic)	BOOL		updated;
@property (nonatomic, strong)	NSMutableData		*responseData;
@property (nonatomic, strong)	NSString		*revisionId;
@property (nonatomic, strong)	NSString		*error;
@property (nonatomic)	BOOL		status;
@property (nonatomic)	DataParserType		dataType;


@end
