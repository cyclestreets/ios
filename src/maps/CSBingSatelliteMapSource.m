//
//  CSBingSatelliteMapSource.m
//  CycleStreets
//
//  Created by Neil Edwards on 16/01/2015.
//  Copyright (c) 2015 CycleStreets Ltd. All rights reserved.
//

#import "CSBingSatelliteMapSource.h"
#import "StringUtilities.h"
#import "BUNetworkOperation.h"
#import "BUDataSourceManager.h"
#import "GlobalUtilities.h"


static NSString *const BINGAPIKEY=@"AgHV52-Gik3ea9np4bd9njM-kWOtQuGZne-sV96AeQtq9beH7Z_eumfxrAkYCNmY";

@interface CSBingSatelliteAuthentication()

@property (nonatomic,strong)  NSString				*mapTileURL;
@property (nonatomic,assign)  int					mapTileZoom;

@property (nonatomic,strong)  NSDictionary			*responseDict;

@end

@implementation CSBingSatelliteAuthentication
SYNTHESIZE_SINGLETON_FOR_CLASS(CSBingSatelliteAuthentication);


- (instancetype)init
{
	self = [super init];
	if (self) {
		_mapTileZoom=19;
		[self fetchBingAuthentication];
	}
	return self;
}


-(void)fetchBingAuthentication{
	
	NSMutableDictionary *parameters=[@{@"key":BINGAPIKEY} mutableCopy];
	parameters[@"output"]=@"json";
	parameters[@"mapVersion"]=@"v1";
	
	
	BUNetworkOperation *request=[[BUNetworkOperation alloc]init];
	request.dataid=BINGMAPAUTHENTICATION;
	request.requestid=ZERO;
	request.parameters=parameters;
	request.source=DataSourceRequestCacheTypeUseNetwork;
	request.trackProgress=YES;
	
	request.completionBlock=^(BUNetworkOperation *operation, BOOL complete,NSString *error){
		
		[self fetchBingAuthenticationResponse:operation];
		
	};
	
	
	[[BUDataSourceManager sharedInstance] processDataRequest:request];
	
	
}


-(void)fetchBingAuthenticationResponse:(BUNetworkOperation*)result{
	
	
	switch(result.responseStatus){
			
		case ValidationBingAuthenticationSuccess:
		{
			self.responseDict=result.response.responseObject[DATAPROVIDER];
			
			NSString *imageURL=_responseDict[@"imageUrl"];
			NSArray *imageDomains=_responseDict[@"imageUrlSubdomains"];
			NSString *domainStr=imageDomains[[GlobalUtilities randomIntBetween:0 and:imageDomains.count]];
			
			NSString *urlTemplate=[imageURL stringByReplacingOccurrencesOfString:@"{subdomain}" withString:domainStr];
			urlTemplate=[urlTemplate stringByReplacingOccurrencesOfString:@"{culture}" withString:@"en-GB"];
			urlTemplate=[urlTemplate stringByReplacingOccurrencesOfString:@"{quadkey}" withString:@"%@"];
			
			self.mapTileURL=urlTemplate;
			
			self.mapTileZoom=[_responseDict[@"zoomMax"] intValue];
			
			
		}
		break;
			
		case ValidationBingAuthenticationFailed:
		{
		}
		break;
			
		default:
		break;
	}
	
}


-(int)mapTileZoom{
	
	if(_mapTileZoom>0){
		return _mapTileZoom;
	}
	return 19;
	
}


@end






@implementation CSBingSatelliteMapSource


// getters

-(int)maxZoom{
	return 19;
}

-(int)minZoom{
	return 1;
}

-(BOOL)isRetinaEnabled{
	return YES;
}


// for use with new retina tiles
-(NSString*)cacheTileTemplate{
	
	if([self isRetinaEnabled]){
		return @"http://tile.cyclestreets.net/mapnik/%li/%li/%li@%ix.png";
	}else{
		return @"http://tile.cyclestreets.net/mapnik/%li/%li/%li.png";
	}
	
}

// for use directly with map kit, if - (NSURL *)URLForTilePath:(MKTileOverlayPath)path is implemented this is effectively ignored
- (NSString *)remotetileTemplate{
	
	return [[CSBingSatelliteAuthentication sharedInstance] mapTileURL];
	
}


- (NSURL *)URLForTilePath:(MKTileOverlayPath)path{
	
	NSString *quadKey=[self convertXZYToQuadKey:path];
	
	NSString *tileTemplate=[self remotetileTemplate];
	
	if(tileTemplate){
		
		NSString *urlstring=NSStringFormat(tileTemplate,quadKey);
	
		NSURL *url= [NSURL URLWithString:urlstring];
	
		return url;
	}else{
		
		return nil;
		
	}
	
}



-(NSString*)convertXZYToQuadKey:(MKTileOverlayPath)path{
	
	NSMutableString *quadKey=[[NSMutableString alloc]init];
	
	for (int i=path.z; i>0; --i) {
		
		int bitmask=1 << (i - 1);
		int digit=0;
		
		if ((path.x & bitmask) != 0) {
			digit++;
		}
		if ((path.y & bitmask) != 0) {
			digit++;
			digit++;
		}
		
		[quadKey appendFormat:@"%i",digit];
		
	}
	return quadKey;
}


- (NSString *)uniqueTilecacheKey
{
	return MAPPING_BASE_BING_SATELLITE;
}

- (NSString *)shortName
{
	return @"Bing Map";
}

- (NSString *)longDescription
{
	return @"Bing";
}

- (NSString *)shortDescription
{
	return @"Bing Satellite map style";
}

- (NSString *)shortAttribution
{
	return @"© Bing ";
}

- (NSString *)longAttribution
{
	return @"Map data © Microsoft";
}

-(NSString*)thumbnailImage{
	return @"BSMapStyle.png";
}


@end
