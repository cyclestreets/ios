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

static int MIN_SIZE = 80;
static int BIG_SIZE = 300;


static NSString *const VIDEOFORMATKEY=@"mp4";

@interface PhotoMapVO()

@property(nonatomic,readwrite)  BOOL					hasVideo;
@property(nonatomic,readwrite)  BOOL					hasPhoto;

@property(nonatomic,strong) NSDictionary				*videoFormats;

@end



@implementation PhotoMapVO



-(void)updateWithAPIDict:(NSDictionary*)dict{
	
	NSDictionary *propertiesDict=dict[@"properties"];
	if(propertiesDict!=nil){
		
		_csid=[propertiesDict[@"id"] integerValue];
		_bigImageURL=propertiesDict[@"thumbnailUrl"];
		_caption=propertiesDict[@"caption"];
		
		_hasPhoto=[propertiesDict[@"hasPhoto"] boolValue];
		_hasVideo=[propertiesDict[@"hasVideo"] boolValue];
		
		if(_hasVideo){
			_videoFormats=propertiesDict[@"videoFormats"];
			if(_videoFormats[VIDEOFORMATKEY]!=nil){
				_mediaType=PhotoMapMediaType_Video;
			}else{
				_hasVideo=NO;
			}
		}
		
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
	return [NSString stringWithFormat:@"%li",_csid];
}


@end
