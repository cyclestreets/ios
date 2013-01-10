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

//  Credits.m
//  CycleStreets
//
//  Created by Alan Paxton on 09/03/2010.
//

#import "CreditsViewController.h"
#import "GlobalUtilities.h"


@interface CreditsViewController()

@property (nonatomic, weak)		IBOutlet UIWebView				* webView;
@property (nonatomic, weak)		IBOutlet UIAlertView				* failAlert;
@property (nonatomic, weak)		IBOutlet UIToolbar				* controlBar;
@property (nonatomic, weak)		IBOutlet UIBarButtonItem				* stopLoadingButton;
@property (nonatomic, weak)		IBOutlet UIBarButtonItem				* refreshButton;
@property (nonatomic, weak)		IBOutlet UIBarButtonItem				* goBackButton;
@property (nonatomic, weak)		IBOutlet UIBarButtonItem				* goForwardButton;
@property (nonatomic, weak)		IBOutlet UIBarButtonItem				* activityBarItem;
@property (nonatomic, weak)		IBOutlet UIActivityIndicatorView				* activityIndicator;
@property (nonatomic)		BOOL				 pageLoaded;

@end



@implementation CreditsViewController



- (void)home {
	NSString *creditsFilePath = [[NSBundle mainBundle] pathForResource:@"credits" ofType:@"html"];
	NSURL *creditsURL = [NSURL fileURLWithPath:creditsFilePath];
	[self.webView loadRequest:[NSURLRequest requestWithURL:creditsURL]];	
	[self.webView setDelegate:self];
}


- (void)viewDidLoad {
	
	_pageLoaded=NO;
	
	self.hidesBottomBarWhenPushed=YES;
	
	self.activityIndicator=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	_activityIndicator.hidesWhenStopped=YES;
	self.activityBarItem=[[UIBarButtonItem alloc] initWithCustomView:_activityIndicator];
	
    [super viewDidLoad];
	
	[self home];
}



-(void)initialiseToolBarButtons{
	_stopLoadingButton.enabled=NO;
	_refreshButton.enabled=NO;
	_goBackButton.enabled=NO;
	_goForwardButton.enabled=NO;
}


//
/***********************************************
 * @description			UI Button Events
 ***********************************************/
//


-(IBAction)stopLoading:(id)sender{
	[_webView stopLoading];
	[self updateUIState:@"loaded"];	
}

-(IBAction)refreshWebView:(id)sender{	
	[_webView reload];
}


-(IBAction)goBackButonSelected:(id)sender{
	if(_webView.canGoBack)
		[_webView goBack];
}

-(IBAction)goForwardButtonSelected:(id)sender{
	if(_webView.canGoForward)
		[_webView goForward];
}


//
/***********************************************
 * @description			UI updates
 ***********************************************/
//

-(void)resetUI{
	
	BetterLog(@"");
	[self updateUIState:@"loaded"];
	
}

-(void)stopLoadingActivity{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	_webView.delegate=nil;
	[_webView stopLoading];
	[self showActivityIndicator:NO];
	
}


-(void)showActivityIndicator:(BOOL)show{
	
	NSMutableArray *items=[NSMutableArray arrayWithArray:[_controlBar items]];
	
	if (show==YES) {
		[items replaceObjectAtIndex:5 withObject:_activityBarItem];
	}else {
		[items replaceObjectAtIndex:5 withObject:_refreshButton];
	}
	[_controlBar setItems:[NSArray arrayWithArray:items] animated:YES];

	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:show];
	
	show==YES ? [_activityIndicator startAnimating] : [_activityIndicator stopAnimating];
	
}


-(void)updateUIState:(NSString*)state{
	
	if([state isEqualToString:@"loading"]){
		
		_stopLoadingButton.enabled=YES;
		[self showActivityIndicator:YES];
		
	}else if ([state isEqualToString:@"loaded"]){
		
		_stopLoadingButton.enabled=NO;
		[self showActivityIndicator:NO];
		
		
	}
	
	_goForwardButton.enabled=_webView.canGoForward;
	_goBackButton.enabled=_webView.canGoBack;
	
}


#pragma mark web view delegate

- (void)webViewDidStartLoad:(UIWebView *)webView{
	
	_pageLoaded=NO;
	[self updateUIState:@"loading"];	
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
	
	_pageLoaded=YES;
	[self updateUIState:@"loaded"];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	BetterLog(@"webView:didFailLoadWithError");
	if (self.failAlert == nil) {
		self.failAlert = [[UIAlertView alloc] initWithTitle:@"CycleStreets"
													 message:@"Unable to load web page."
													delegate:nil
										   cancelButtonTitle:@"OK"
										   otherButtonTitles:nil];
	}
	[self.failAlert show];
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
	
	if (self.isViewLoaded && !self.view.window) {
        self.view = nil;
    }
	
	self.webView = nil;
	self.failAlert = nil;
    
}


@end
