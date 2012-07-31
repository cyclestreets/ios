/*

Copyright (C) 2010  CycleStreets Ltd

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

*/

//  Query.m
//  CycleStreets
//
//  Created by Alan Paxton on 02/03/2010.
//

#import "Query.h"
#import <MapKit/MapKit.h>
#import "XMLRequest.h"
#import "CycleStreets.h"
#import "SettingsViewController.h"
#import "AppDelegate.h"
#import "Files.h"
#import "Route.h"
#import "SettingsManager.h"
#import "SettingsVO.h"
#import "GlobalUtilities.h"

static NSString *format = @"%@?key=%@&start_longitude=%f&start_latitude=%f&finish_longitude=%f&finish_latitude=%f&layer=%@&plan=%@&speed=%@&useDom=%@&clientid=%@";
static NSString *routeidformat = @"%@?key=%@&useDom=%@&itinerary=%@&plan=%@";

static NSString *urlPrefix = @"http://www.cyclestreets.net/api/journey.xml";
static NSString *layer = @"6";
static NSString *useDom = @"1";

@implementation Query
@synthesize url;
@synthesize request;
@synthesize routeID;

//=========================================================== 
// dealloc
//=========================================================== 
- (void)dealloc
{
    url = nil;
    request = nil;
    routeID = nil;
	
}



- (NSString *)convertToKilometres:(NSString *)stringMiles {
	NSInteger miles = [stringMiles integerValue];
	NSInteger kilometres = 50;//clearly stupid value.
	if (miles == 10) {
		kilometres = 16;
	} else if (miles == 12) {
		kilometres = 20;
	} else if (miles == 15) {
		kilometres = 24;
	}
	return [[NSNumber numberWithInteger:kilometres] stringValue];
}

- (id) initFrom:(CLLocation *)from to:(CLLocation *)to {
	if (self = [super init]) {
		
		//Fill in various of the parameters from the current settings value.
		CycleStreets *cycleStreets = [CycleStreets sharedInstance];
		SettingsVO *settingsdp = [SettingsManager sharedInstance].dataProvider;

		NSString *newURL = [NSString
							stringWithFormat:format,
							urlPrefix,
							[cycleStreets APIKey],
							[from coordinate].longitude,
							[from coordinate].latitude,
							[to coordinate].longitude,
							[to coordinate].latitude,
							layer,
							settingsdp.plan,
							[settingsdp returnKilometerSpeedValue],
							useDom,
							cycleStreets.files.clientid
							];
		BetterLog(@"Route request=%@",newURL);
		
		url = newURL;
	}
	return self;
}

- (id) initRouteID:(NSString*)routeid {
	
	if (self = [super init]) {
		
		//Fill in various of the parameters from the current settings value.
		CycleStreets *cycleStreets = [CycleStreets sharedInstance];
		SettingsVO *settingsdp = [SettingsManager sharedInstance].dataProvider;
		
		self.routeID=routeid;
		
		NSString *newURL = [NSString
							stringWithFormat:routeidformat,
							urlPrefix,
							[cycleStreets APIKey],
							useDom,
							routeid,
							settingsdp.plan
							];
		BetterLog(@"Route id request=%@",newURL);
		
		url = newURL;
	}
	return self;
}

+ (Query *)example {
	CLLocation *from = [[CLLocation alloc] initWithLatitude: 51.53523137707124 longitude: -0.16968727111816406];
	CLLocation *to = [[CLLocation alloc] initWithLatitude: 51.521935438813486 longitude: -0.1153564453125];
	Query *query = [[Query alloc] initFrom:from to:to];
	return query;
}

- (void) runWithTarget:(NSObject *)resultTarget onSuccess:(SEL)successMethod onFailure:(SEL)failureMethod {
	request = [[XMLRequest alloc] initWithURL:url delegate:(NSObject *)resultTarget tag:nil onSuccess:(SEL)successMethod onFailure:(SEL)failureMethod];
	request.elementsToParse = [Route routeXMLElementNames];
	[request start];
}

- (NSString *)description {
	NSString *copy = [url copy];
	return copy;
}



@end
