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

//  PhotoEntry.m
//  CycleStreets
//
//

#import "PhotoMapVO.h"
#import "GlobalUtilities.h"
#import "NSDate+Helper.h"

static int MIN_SIZE = 80;
static int BIG_SIZE = 300;


static NSString *const VIDEOFORMATKEY=@"mp4";

@interface PhotoMapVO()

@property(nonatomic,readwrite)  BOOL					hasVideo;
@property(nonatomic,readwrite)  BOOL					hasPhoto;

@property(nonatomic,strong) NSDictionary				*videoFormats;


@property(nonatomic, strong)	NSString				*date;
@property(nonatomic,strong)  NSArray					*tags;


@end



@implementation PhotoMapVO



-(void)updateWithAPIDict:(NSDictionary*)dict{
	
	NSDictionary *propertiesDict=dict[@"properties"];
	if(propertiesDict!=nil){
		
		_csid=[propertiesDict[@"id"] integerValue];
		_bigImageURL=propertiesDict[@"thumbnailUrl"];
		_caption=propertiesDict[@"caption"];
		
		_hasPhoto=[propertiesDict[@"hasPhoto"] boolValue];
		BOOL hasvideoNode=[propertiesDict[@"hasVideo"] boolValue];
		_hasVideo=NO;
		
		_categoryId=propertiesDict[@"categoryId"];
		_metacategoryId=propertiesDict[@"metacategoryId"];
		
		// node may exist but be empty of mp4s
		if(hasvideoNode){
			_videoFormats=propertiesDict[@"videoFormats"];
			if (_videoFormats!=nil) {
				if(_videoFormats[VIDEOFORMATKEY]!=nil){
					_mediaType=PhotoMapMediaType_Video;
					_hasVideo=YES;
				}
			}
		}
		
		// v2 additions
		_bearingString=propertiesDict[@"bearingString"];
		_date=propertiesDict[@"datetime"];
		_tags=propertiesDict[@"tags"];
		_username=propertiesDict[@"username"];
		_license=propertiesDict[@"license"];
		
		
	}
	
	NSDictionary *geomDict=dict[@"geometry"];
	if(geomDict!=nil){
		
		_locationCoords=CLLocationCoordinate2DMake([geomDict[@"coordinates"][1] doubleValue],[geomDict[@"coordinates"][0] doubleValue]);
		
	}
	
	
}


// Optimize small URL for smallest thumbnail available which is big enough.
- (void) generateSmallImageURL:(NSString *)sizes {
	//default to the known big one.
	self.smallImageURL = self.bigImageURL;
	
	//try and find a known smaller one
	int bestSize = SCREENPIXELWIDTH;
	int lastSize=0;
	for (NSString *size in [sizes componentsSeparatedByString:@"|"]) {
		int newSize = [size intValue];
		
		if (newSize >= MIN_SIZE) {
			
			if (newSize > bestSize) {
				bestSize=lastSize;
				break;
			}else{
				lastSize=newSize;
			}
		}
	}
	
	//we got one. Fix up the URL.
	if (bestSize > 0) {
		NSString *from = [[NSNumber numberWithInt:BIG_SIZE] stringValue];
		NSString *to = [[NSNumber numberWithInt:bestSize] stringValue];
		self.smallImageURL = [self.bigImageURL stringByReplacingOccurrencesOfString:from withString:to];
	}
}



- (CLLocationCoordinate2D)location {
	return _locationCoords;
}


-(NSString*)csImageUrlString{
	return [NSString stringWithFormat:@"http://cycle.st/p%@",self.csidString];
}

-(NSString*)csVideoURLString{
	
	if(_videoFormats[VIDEOFORMATKEY]!=nil){
		NSDictionary *csViceoDict=_videoFormats[VIDEOFORMATKEY];
		return csViceoDict[@"url"];
	}
	return nil;
	
}


-(NSString*)csidString{
	return [NSString stringWithFormat:@"%li",(long)_csid];
}

-(NSString*)categoryIconString{
	
	if(_metacategoryId!=nil && _categoryId!=nil){
		
		// there are 3 meta categories that map to neutral
		NSArray *neutralStrs=@[@"other",@"any",@"event"];
		NSString *metasuffix=_metacategoryId;
		
		if([neutralStrs indexOfObject:_metacategoryId]!=NSNotFound){
			metasuffix=@"neutral";
		}
		
		return [NSString stringWithFormat:@"%@_%@.pdf",_categoryId,metasuffix];
		
	}else{
		return @"bicycles_other.pdf";
	}
}


-(NSString*)dateString{
	
	if(_date!=nil){
		
		return [NSDate stringFromDate:[NSDate dateFromString:_date withFormat:[NSDate dbFormatString]] withFormat:[NSDate shortHumanFormatStringWithTime]];
		
	}else{
		return  EMPTYSTRING;
	}
	
}

-(NSString*)tagString{
	
	if(_tags!=nil && _tags.count>0){
		
		return [_tags componentsJoinedByString:@","];
		
	}else{
		return EMPTYSTRING;
	}
}


@end
