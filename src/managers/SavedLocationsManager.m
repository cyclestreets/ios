//
//  SavedLocationsManager.m
//  CycleStreets
//
//  Created by Neil Edwards on 14/10/2014.
//  Copyright (c) 2014 CycleStreets Ltd. All rights reserved.
//

#import "SavedLocationsManager.h"

#import "GenericConstants.h"
#import "AppConstants.h"
#import "GlobalUtilities.h"

#import "NSMutableArray+Plist.h"

#import "SavedLocationVO.h"

static NSString *const SAVEDLOCATIONARCHIVEKEY=@"SavedLocationsManager";
static NSString *const SAVEDLOCATIONARCHIVEFILE=@"SavedLocations.data";


@interface SavedLocationsManager()


@property (nonatomic,readwrite)  NSMutableArray								*dataProvider;


@end




@implementation SavedLocationsManager
SYNTHESIZE_SINGLETON_FOR_CLASS(SavedLocationsManager);

- (instancetype)init
{
	self = [super init];
	if (self) {
		[self loadDataFile];
	}
	return self;
}


#pragma mark - File I/O

-(void)loadDataFile{
	
	NSFileManager *fm=[NSFileManager defaultManager];
	
	BetterLog(@" filepath=%@",[self filepath]);
	
	if ([fm fileExistsAtPath:[self filepath]]) {
		
		BetterLog(@"SavedLocations.data file exists");
		
		
		NSMutableData *data = [[NSMutableData alloc] initWithContentsOfFile:[self filepath]];
		NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
		self.dataProvider = [unarchiver decodeObjectForKey:SAVEDLOCATIONARCHIVEKEY];
		[unarchiver finishDecoding];
		
		
	}else{
		
		self.dataProvider=[NSMutableArray array];
		
		
		[self saveDataFile];
		
	}
	
}


- (void)saveDataFile{
	
	NSMutableData *data = [[NSMutableData alloc] init];
	NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
	[archiver encodeObject:_dataProvider forKey:SAVEDLOCATIONARCHIVEKEY];
	[archiver finishEncoding];
	[data writeToFile:[self filepath] atomically:YES];
	
}


- (void)removeDataFile{
	
	NSFileManager* fileManager = [NSFileManager defaultManager];
	
	BOOL fileexists = [fileManager fileExistsAtPath:[self filepath]];
	
	if(fileexists==YES){
		
		NSError *error=nil;
		[fileManager removeItemAtPath:[self filepath] error:&error];
	}
	
}


#pragma mark - Location adding/removing


// add location
-(void)addSavedLocation:(SavedLocationVO*)location{
	
	[self updateDefaultLocationForType:location.locationType];
	
	[_dataProvider addObject:location];
	
	[self saveDataFile];
	
	
	
}




// remove location
-(void)removeSavedLocation:(SavedLocationVO*)location{
	
	[_dataProvider removeObject:location];
	
	[self saveDataFile];
}



// sync data to server
-(void)syncLocationDataToServer{
	
	
	
	
}



-(void)saveLocations{
	[self saveDataFile];
}
	
	
	
#pragma mark - Utility


// as part of add, finds and updates any same type non default location type
// ie if user attempts to set a new home location it will swap any existing one to SavedLocationTypeOther
-(void)updateDefaultLocationForType:(SavedLocationType)locationType{
	
	[_dataProvider enumerateObjectsUsingBlock:^(SavedLocationVO *obj, NSUInteger idx, BOOL *stop) {
		
		if(obj.locationType==locationType){
			obj.locationType=SavedLocationTypeOther;
			*stop=YES;
		}
		
	}];
	
	
}




-(SavedLocationVO*)findLocationByID:(NSString*)uuid{
	
	__block SavedLocationVO *location=nil;
	
	[_dataProvider indexOfObjectPassingTest:^BOOL(SavedLocationVO *obj, NSUInteger idx, BOOL *stop) {
		
		if ([obj.locationID isEqualToString:uuid]) {
			location=obj;
			*stop=YES;
			return YES;
		}
		
		return NO;
	}];
	
	return location;
}


-(NSString*)filepath{
	NSArray* paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString* docsdir=[paths objectAtIndex:0];
	BetterLog(@"docsdir=%@",docsdir);
	return [docsdir stringByAppendingPathComponent:SAVEDLOCATIONARCHIVEFILE];
}



@end
