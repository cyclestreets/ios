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

//  Location2.h
//  CycleStreets
//
//  Created by Alan Paxton on 23/07/2010.
//

#import <UIKit/UIKit.h>
@class PhotoEntry;
@class NetworkRequest;

@interface Location2 : UIViewController {
	
	UINavigationBar *navigation;
	UIScrollView *scroll;

	UIImageView *bgImageView;
	UIImageView *imageView;
	UITextView *captionView;
		
	UIActivityIndicatorView *spinner;
	
	NetworkRequest *request;
}

//fixed IB elements
@property (nonatomic, retain) IBOutlet UINavigationBar *navigation;
@property (nonatomic, retain) IBOutlet UIScrollView *scroll;

//elements we fit in the scroll
@property (nonatomic, retain) UIImageView *bgImageView;
@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) UITextView *captionView;
 
@property (nonatomic, retain) UIActivityIndicatorView *spinner;
@property (nonatomic, retain) NetworkRequest *request;

- (void) loadEntry:(PhotoEntry *)photoEntry;

- (void) loadThumbnail:(PhotoEntry *)photoEntry;

@end
