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
#import "WebPopup.h"
#import "UIButton+Blue.h"
#import "Common.h"
#import "GlobalUtilities.h"

@implementation CreditsViewController
@synthesize webView;
@synthesize failAlert;
@synthesize controlBar;
@synthesize stopLoadingButton;
@synthesize refreshButton;
@synthesize goBackButton;
@synthesize goForwardButton;
@synthesize activityBarItem;
@synthesize activityIndicator;
@synthesize pageLoaded;

/***********************************************************/
// dealloc
/***********************************************************/
- (void)dealloc
{
    [webView release], webView = nil;
    [failAlert release], failAlert = nil;
    [controlBar release], controlBar = nil;
    [stopLoadingButton release], stopLoadingButton = nil;
    [refreshButton release], refreshButton = nil;
    [goBackButton release], goBackButton = nil;
    [goForwardButton release], goForwardButton = nil;
    [activityBarItem release], activityBarItem = nil;
    [activityIndicator release], activityIndicator = nil;
	
    [super dealloc];
}





- (void)home {
	NSString *creditsFilePath = [[NSBundle mainBundle] pathForResource:@"credits" ofType:@"html"];
	NSURL *creditsURL = [NSURL fileURLWithPath:creditsFilePath];
	[self.webView loadRequest:[NSURLRequest requestWithURL:creditsURL]];	
	[self.webView setDelegate:self];
}


- (void)viewDidLoad {
	
	pageLoaded=NO;
	
	self.hidesBottomBarWhenPushed=YES;
	
	self.activityIndicator=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	activityIndicator.hidesWhenStopped=YES;
	self.activityBarItem=[[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
	
    [super viewDidLoad];
	
	[self home];
}



-(void)initialiseToolBarButtons{
	stopLoadingButton.enabled=NO;
	refreshButton.enabled=NO;
	goBackButton.enabled=NO;
	goForwardButton.enabled=NO;
}


//
/***********************************************
 * @description			UI Button Events
 ***********************************************/
//


-(IBAction)stopLoading:(id)sender{
	[webView stopLoading];
	[self updateUIState:@"loaded"];	
}

-(IBAction)refreshWebView:(id)sender{	
	[webView reload];
}


-(IBAction)goBackButonSelected:(id)sender{
	if(webView.canGoBack)
		[webView goBack];
}

-(IBAction)goForwardButtonSelected:(id)sender{
	if(webView.canGoForward)
		[webView goForward];
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
	webView.delegate=nil;
	[webView stopLoading];
	[self showActivityIndicator:NO];
	
}


-(void)showActivityIndicator:(BOOL)show{
	
	NSMutableArray *items=[NSMutableArray arrayWithArray:[controlBar items]];
	
	if (show==YES) {
		[items replaceObjectAtIndex:5 withObject:activityBarItem];
	}else {
		[items replaceObjectAtIndex:5 withObject:refreshButton];
	}
	[controlBar setItems:[NSArray arrayWithArray:items] animated:YES];

	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:show];
	
	show==YES ? [activityIndicator startAnimating] : [activityIndicator stopAnimating];
	
}


-(void)updateUIState:(NSString*)state{
	
	if([state isEqualToString:@"loading"]){
		
		stopLoadingButton.enabled=YES;
		[self showActivityIndicator:YES];
		
	}else if ([state isEqualToString:@"loaded"]){
		
		stopLoadingButton.enabled=NO;
		[self showActivityIndicator:NO];
		
		
	}
	
	goForwardButton.enabled=webView.canGoForward;
	goBackButton.enabled=webView.canGoBack;
	
}


#pragma mark web view delegate

- (void)webViewDidStartLoad:(UIWebView *)webView{
	
	pageLoaded=NO;
	[self updateUIState:@"loading"];	
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
	
	pageLoaded=YES;
	[self updateUIState:@"loaded"];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	DLog(@"webView:didFailLoadWithError");
	if (self.failAlert == nil) {
		self.failAlert = [[[UIAlertView alloc] initWithTitle:@"CycleStreets"
													 message:@"Unable to load web page."
													delegate:nil
										   cancelButtonTitle:@"OK"
										   otherButtonTitles:nil]
						  autorelease];
	}
	[self.failAlert show];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (void)nullify {
	self.webView = nil;
	self.failAlert = nil;
}

- (void)viewDidUnload {
	[self nullify];
    [super viewDidUnload];
}





@end
