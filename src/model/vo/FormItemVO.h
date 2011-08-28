//
//  FormItemVO.h
//  CycleStreets
//
//  Created by Neil Edwards on 20/12/2010.
//  Copyright 2010 CycleStreets Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FormManager.h"

@interface FormItemVO : NSObject {
	NSString			*itemid; // unique id
	NSString			*validateType; // validate method type
	NSMutableDictionary	*parameters; // vaidate method params
	NSString			*errorString; // error message
	NSString			*itemType; // ui component type
	BOOL				mandatory;
}
@property (nonatomic, retain)			NSString *itemid;
@property (nonatomic, retain)			NSString *validateType;
@property (nonatomic, retain)			NSMutableDictionary *parameters;
@property (nonatomic, retain)			NSString *errorString;
@property (nonatomic, retain)			NSString *itemType;
@property (nonatomic)			BOOL mandatory;

@end
