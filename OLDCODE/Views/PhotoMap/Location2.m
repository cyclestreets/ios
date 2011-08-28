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

//  Location2.m
//  CycleStreets
//
//  Created by Alan Paxton on 23/07/2010.
//

#import "Location2.h"
#import "NetworkRequest.h"
#import "PhotoEntry.h"
#import "GlobalUtilities.h"

@implementation Location2

@synthesize scroll;
@synthesize navigation;

@synthesize spinner;
@synthesize bgImageView;
@synthesize imageView;
@synthesize captionView;

@synthesize request;

static int THREE20 = 320;
static int FOUR60 = 460;
static int TEXT_MIN = 80;
static int SPINNER_HEIGHT = 60;


- (CGRect)imageFrame {
	CGRect rect;
	rect.origin.x = 0;
	rect.origin.y = 0;
	NSInteger width = THREE20;
	rect.size = self.imageView.image.size;
	CGFloat scale = width / rect.size.width;
	rect.size.width *= scale;
	rect.size.height *= scale;
	return rect;
}

- (CGRect)spinnerFrameIn:(CGRect)outer {
	CGRect rect;
	NSInteger h = SPINNER_HEIGHT;
	if (h > outer.size.width) {
		h = outer.size.width;
	}
	if (h > outer.size.height) {
		h = outer.size.height;
	}
	rect.size.height = h;
	rect.size.width = h;
	rect.origin.x = (outer.size.width - h)/2;
	rect.origin.y = (outer.size.height - h)/4;
	
	return rect;
}

- (CGRect)textFrameAt:(NSInteger)y {
	CGRect textFrame;
	textFrame.origin.y = y;
	textFrame.origin.x = 0;
	textFrame.size.width = THREE20;
	NSInteger h = FOUR60 - y;
	if (h < TEXT_MIN) {
		h = TEXT_MIN;
	}
	textFrame.size.height = h;
	
	return textFrame;
}

- (void)didBack {
	self.imageView.image = nil;
	[self.request cancel];
	self.request = nil;
	[self dismissModalViewControllerAnimated:YES];
}

- (void)cleanup {	
	self.bgImageView = nil;
	self.imageView = nil;
	self.captionView = nil;
	self.navigation = nil;
	self.scroll = nil;
	self.spinner = nil;	
	self.request = nil;
}

- (void) displayImage:(UIImage *)image caption:(NSString *)caption captionAlpha:(double)captionAlpha {
	self.imageView.image = image;
	CGRect imageFrame = [self imageFrame];
	self.imageView.frame = imageFrame;
	CGRect textFrame = [self textFrameAt:imageFrame.size.height];
	self.captionView.frame = textFrame;
	self.captionView.text = caption;
	self.captionView.alpha = captionAlpha;
	
	CGSize scrollSize;
	scrollSize.width = imageFrame.size.width;
	scrollSize.height = imageFrame.size.height + textFrame.size.height;
	self.scroll.contentSize = scrollSize;
}

- (void) displayImage:(UIImage *)image captionAlpha:(double)captionAlpha {
	[self displayImage:image caption:self.captionView.text captionAlpha:captionAlpha];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.imageView = [[[UIImageView alloc] init] autorelease];
	self.captionView = [[[UITextView alloc] init] autorelease];
	self.captionView.font = [UIFont systemFontOfSize:17];
	
	[self.scroll addSubview:self.bgImageView];
	[self.scroll addSubview:self.imageView];
	[self.scroll addSubview:self.captionView];
	
	[self displayImage:[UIImage imageNamed:@"bg320x240.png"] captionAlpha:0.5];
	
	UIBarButtonItem *back = [[[UIBarButtonItem alloc] initWithTitle:@"Done"
															   style:UIBarButtonItemStyleBordered
															  target:self
															   action:@selector(didBack)]
							 autorelease];
	UINavigationItem *navigationItem = [[[UINavigationItem alloc] initWithTitle:@"Photomap"] autorelease];
	[navigationItem setRightBarButtonItem:back];
	[self.navigation pushNavigationItem:navigationItem animated:NO];
}


#pragma mark photo loading

- (void) requestCleanup {
	[self.spinner stopAnimating];
	[self.spinner removeFromSuperview];
	self.request = nil;
}

- (void) didSucceed:(NetworkRequest *)request withData:(NSData *)data {
	UIImage *image = [UIImage imageWithData:data];
	[self displayImage:image captionAlpha:0.875];
	[self requestCleanup];
}

- (void) didFail:(NetworkRequest *)request {
	[self requestCleanup];
}

- (void) loadEntry:(PhotoEntry *)photoEntry {
	//placeholder image
	UIImage *image = [UIImage imageNamed:@"bg320x240.png"];
	self.navigation.topItem.title = [NSString stringWithFormat:@"Photo #%@", [photoEntry csid]];
	[self displayImage:image caption:[photoEntry caption] captionAlpha:0.25];
	
	self.request = [[[NetworkRequest alloc] initWithURL:[photoEntry bigImageURL]
											   delegate:self
													tag:nil
											  onSuccess:@selector(didSucceed:withData:)
											  onFailure:@selector(didFail:)]
					autorelease];
	[self.request start];
	if (self.spinner == nil) {
		self.spinner = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge]
						autorelease];		
	}
	self.spinner.frame = [self spinnerFrameIn:self.imageView.frame];
	[self.imageView addSubview:self.spinner];
	[self.spinner startAnimating];
}

- (void) loadThumbnail:(PhotoEntry *)photoEntry {
	//doesn't yet.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
	BetterLog(@">>>");
    [self.bgImageView removeFromSuperview];
	[self.imageView removeFromSuperview];
	[self.captionView removeFromSuperview];
	[self cleanup];
	[super viewDidUnload];
}


- (void)dealloc {
	[self cleanup];
	[super dealloc];
}


@end
