//
//  LoginVO.h
//  CycleStreets
//
//  Created by Neil Edwards on 08/04/2011.
//  Copyright 2011 CycleStreets Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface LoginVO : NSObject {
	
	// mandatory
	NSString			*requestname;
	
	// user info
	NSString			*username;
	int					userid;
	NSString			*email;
	NSString			*name;
	
	// optional
	BOOL				validatekey;
	NSString			*validatedDate;
	int					lastsignin;
	NSString			*userIP;
	BOOL				deleted;

}
@property (nonatomic, strong)		NSString		* requestname;
@property (nonatomic, strong)		NSString		* username;
@property (nonatomic)		int		 userid;
@property (nonatomic, strong)		NSString		* email;
@property (nonatomic, strong)		NSString		* name;
@property (nonatomic)		BOOL		 validatekey;
@property (nonatomic, strong)		NSString		* validatedDate;
@property (nonatomic)		int		 lastsignin;
@property (nonatomic, strong)		NSString		* userIP;
@property (nonatomic)		BOOL		 deleted;

@end
