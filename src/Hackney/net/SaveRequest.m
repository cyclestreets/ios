/** Cycle Atlanta, Copyright 2012, 2013 Georgia Institute of Technology
 *                                    Atlanta, GA. USA
 *
 *   @author Christopher Le Dantec <ledantec@gatech.edu>
 *   @author Anhong Guo <guoanhong@gatech.edu>
 *
 *   Updated/Modified for Atlanta's app deployment. Based on the
 *   CycleTracks codebase for SFCTA.
 *
 ** CycleTracks, Copyright 2009,2010 San Francisco County Transportation Authority
 *                                    San Francisco, CA, USA
 *
 *   @author Matt Paul <mattpaul@mopimp.com>
 *
 *   This file is part of CycleTracks.
 *
 *   CycleTracks is free software: you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as published by
 *   the Free Software Foundation, either version 3 of the License, or
 *   (at your option) any later version.
 *
 *   CycleTracks is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details.
 *
 *   You should have received a copy of the GNU General Public License
 *   along with CycleTracks.  If not, see <http://www.gnu.org/licenses/>.
 */

//
//  SaveRequest.m
//  CycleTracks
//
//  Copyright 2009-2010 SFCTA. All rights reserved.
//  Written by Matt Paul <mattpaul@mopimp.com> on 8/25/09.
//	For more information on the project,
//	e-mail Billy Charlton at the SFCTA <billy.charlton@sfcta.org>

#import "constants.h"
#import "SaveRequest.h"
#import "ZipUtil.h"

@implementation SaveRequest

@synthesize request, deviceUniqueIdHash, postVars;

#pragma mark init

- initWithPostVars:(NSDictionary *)inPostVars with:(NSInteger) type image:(NSData*) imageData;
{
	if (self = [super init])
	{
		// create request.
        self.request = [[NSMutableURLRequest alloc] init];
        [request setURL:[NSURL URLWithString:kSaveURL]];
        [request setHTTPMethod:@"POST"];
        
        // Nab the unique device id hash from our delegate.
		
		self.deviceUniqueIdHash = [[UIDevice currentDevice] identifierForVendor];
        
        self.postVars = [NSMutableDictionary dictionaryWithDictionary:inPostVars];
        [postVars setObject:deviceUniqueIdHash forKey:@"device"];
        
        if (type == 3) {
            [request setValue:@"3" forHTTPHeaderField:@"Cycleatl-Protocol-Version"];
        }
        else if (type == 4){
            [request setValue:@"4" forHTTPHeaderField:@"Cycleatl-Protocol-Version"];
        }
        
        if (type == 4){
            // create the POST request for saving a Note
            NSString *boundary = @"cycle*******notedata*******atlanta";
            NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
            [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
            
            
            // post body
            NSMutableData *body = [NSMutableData data];
            
            // add note details
            for (NSString *key in postVars) {
                [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key] dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[[NSString stringWithFormat:@"%@\r\n", [postVars objectForKey:key]] dataUsingEncoding:NSUTF8StringEncoding]];
            }                        
            
            // add image data
            if (imageData) {
                NSLog(@"there's an image");
                [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"file\"; filename=\"%@.jpg\"\r\n", deviceUniqueIdHash] dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:imageData];
                [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
            }
            
            [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            
            // setting the body of the post to the reqeust
            [request setHTTPBody:body];
            
            // set the content-length
            NSString *postLength = [NSString stringWithFormat:@"%d", [body length]];
            [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
            
        } else {
            // create the POST request for saving a Trip
            [request setValue:@"gzip" forHTTPHeaderField:@"Content-Encoding"];
            // this is a bit grotty, but it indicates a) cycleatl namespace
            // b) trip upload, c) version 3, d) form encoding
            [request setValue:@"application/vnd.cycleatl.trip-v3+form" forHTTPHeaderField:@"Content-Type"];            
            
            //convert dict to string
            NSMutableString *postBody = [NSMutableString string];
            
            NSString *sep = @"";
            for(NSString * key in postVars) {
                [postBody appendString:[NSString stringWithFormat:@"%@%@=%@",
                                        sep,
                                        key,
                                        [postVars objectForKey:key]]];
                sep = @"&";
            }
            //append actual image data
            // for (each image to upload){
            //      [postBody appendString 
            
            //NSLog(@"Post body unzipped: %@", postBody);
            // gzip the POST payload
            NSData *originalData = [postBody dataUsingEncoding:NSUTF8StringEncoding];
            NSData *postBodyDataZipped = [ZipUtil gzipDeflate:originalData];
            
            NSLog(@"Initializing HTTP POST request to %@ of size %d, orig size %d",
                  kSaveURL, [postBodyDataZipped length], [originalData length]);
            
            [request setValue:[NSString stringWithFormat:@"%d", [postBodyDataZipped length]] forHTTPHeaderField:@"Content-Length"];
            //set the POST body
            [request setHTTPBody:postBodyDataZipped];
        }
        
	}
    
	return self;
}

#pragma mark instance methods

// add POST vars to request
- (NSURLConnection *)getConnectionWithDelegate:(id)delegate
{
    
	NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:delegate];
	return conn;
}

- (void)dealloc
{
	self.request = nil;
    self.postVars = nil;
    self.deviceUniqueIdHash = nil;
    
}

@end