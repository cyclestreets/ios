//
//  RequestQueueVO.h
//  RacingUK
//
//  Created by Neil Edwards on 09/11/2011.
//  Copyright (c) 2011 Chroma. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetRequest.h"

@interface RequestQueueVO : NSObject{
	
	NetRequest		*request;
	int				index;
	BOOL			status;
	
}
@property (nonatomic, strong)	NetRequest		*request;
@property (nonatomic)	int		index;
@property (nonatomic)	BOOL		status;
@end
