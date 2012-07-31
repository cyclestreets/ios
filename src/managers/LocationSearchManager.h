//
//  LocationSearchManager.h
//  CycleStreets
//
//  Created by neil on 06/04/2011.
//  Copyright 2011 CycleStreets Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FrameworkObject.h"
#import "MBProgressHUD.h"
#import <AddressBook/AddressBook.h>

enum{
	LocationSearchFilterLocal,
	LocationSearchFilterNational,
	LocationSearchFilterRecent,
	LocationSearchFilterContacts
};
typedef int LocationSearchFilterType;

enum{
	LocationSearchRequestTypeMap,
	LocationSearchRequestTypePhoto,
	LocationSearchRequestTypeNone
};
typedef int LocationSearchRequestType;

@interface LocationSearchManager : FrameworkObject <MBProgressHUDDelegate>{
	
	MBProgressHUD					*HUD;
	
	LocationSearchFilterType		activeFilterType;
	LocationSearchRequestType		activeRequestType;
	
	NSMutableDictionary				*requestResultDict;
	
	NSMutableArray					*recentSelectedArray;
	

}
@property (nonatomic, strong)	MBProgressHUD	*HUD;
@property (nonatomic, assign)	LocationSearchFilterType	activeFilterType;
@property (nonatomic, assign)	LocationSearchRequestType	activeRequestType;
@property (nonatomic, strong)	NSMutableDictionary	*requestResultDict;
@property (nonatomic, strong)	NSMutableArray	*recentSelectedArray;


-(void)searchForLocation:(NSString*)searchString withFilter:(LocationSearchFilterType)filterType forRequestType:(LocationSearchRequestType)requestType;

+ (LocationSearchRequestType)locationrequestStringTypeToConstant:(NSString*)stringType;
+ (NSString*)locationrequestConstantToString:(LocationSearchRequestType)requestType;

@end
