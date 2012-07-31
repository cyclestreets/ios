//
//  PullRefreshTableViewController.m
//  Plancast
//
//  Created by Leah Culver on 7/2/10.
//  Copyright (c) 2010 Leah Culver
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

#import <QuartzCore/QuartzCore.h>
#import "PullRefreshTableViewController.h"
#import	"AppConstants.h"
#import "GlobalUtilities.h"
#import "ExpandedUILabel.h"
#import "NSDate+Helper.h"


#define REFRESH_HEADER_HEIGHT 44


@implementation PullRefreshTableViewController
//@synthesize refreshHeaderView;
@synthesize refreshLabel;
@synthesize refreshArrow;
@synthesize refreshSpinner;
@synthesize isDragging;
@synthesize isLoading;
@synthesize textPull;
@synthesize textRelease;
@synthesize textLoading;
@synthesize tableView;
@synthesize updateLabel;



- (void)viewDidLoad {
	
	self.textPull = @"Pull down to refresh...";
	self.textRelease = @"Release to refresh...";
	self.textLoading = @"Loading...";
	
    [super viewDidLoad];
    [self addPullToRefreshHeader];
}


- (void)addPullToRefreshHeader {
	
	UIView		*refreshHeaderView=[[UIView alloc]initWithFrame:CGRectMake(0, 0 - REFRESH_HEADER_HEIGHT, SCREENWIDTH, REFRESH_HEADER_HEIGHT)];
	refreshHeaderView.backgroundColor=[UIColor clearColor];
	
    self.refreshLabel=[[ExpandedUILabel alloc] initWithFrame:CGRectMake(50, 5, 240, 10)];
	refreshLabel.textColor=UIColorFromRGB(0x666666);
    refreshLabel.font = [UIFont boldSystemFontOfSize:12.0];
	
	self.updateLabel=[[ExpandedUILabel alloc] initWithFrame:CGRectMake(50, 20, 240, 10)];
	updateLabel.textColor=UIColorFromRGB(0x999999);
    updateLabel.font = [UIFont boldSystemFontOfSize:10.0];
	updateLabel.text=[NSDate stringFromDate:[NSDate date] withFormat:[NSDate shortFormatString]];

    UIImageView *iview=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BUPTR_arrow.png"]];
    self.refreshArrow = iview;
	refreshArrow.alpha=0.5;
    refreshArrow.frame = CGRectMake((REFRESH_HEADER_HEIGHT - 18) / 2,
                                    (REFRESH_HEADER_HEIGHT - 30) / 2,
                                    18, 30);

    UIActivityIndicatorView *acview=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.refreshSpinner = acview;
    refreshSpinner.frame = CGRectMake((REFRESH_HEADER_HEIGHT - 20) / 2, (REFRESH_HEADER_HEIGHT - 20) / 2, 20, 20);
    refreshSpinner.hidesWhenStopped = YES;

    [refreshHeaderView addSubview:refreshLabel];
	[refreshHeaderView addSubview:updateLabel];
    [refreshHeaderView addSubview:refreshArrow];
    [refreshHeaderView addSubview:refreshSpinner];
    [self.tableView addSubview:refreshHeaderView];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	
    if (isLoading) return;
    isDragging = YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scview {
	
    if (isLoading) {
        // Update the content inset, good for section headers
        if (scview.contentOffset.y > 0)
            self.tableView.contentInset = UIEdgeInsetsZero;
        else if (scview.contentOffset.y >= -REFRESH_HEADER_HEIGHT)
            self.tableView.contentInset = UIEdgeInsetsMake(-scview.contentOffset.y, 0, 0, 0);
    } else if (isDragging && scview.contentOffset.y < 0) {
        // Update the arrow direction and label
        [UIView beginAnimations:nil context:NULL];
        if (scview.contentOffset.y < -REFRESH_HEADER_HEIGHT) {
            // User is scrolling above the header
            refreshLabel.text = self.textRelease;
            [refreshArrow layer].transform = CATransform3DMakeRotation(M_PI, 0, 0, 1);
        } else { // User is scrolling somewhere within the header
            refreshLabel.text = self.textPull;
            [refreshArrow layer].transform = CATransform3DMakeRotation(M_PI * 2, 0, 0, 1);
        }
        [UIView commitAnimations];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scview willDecelerate:(BOOL)decelerate {
    if (isLoading) return;
    isDragging = NO;
    if (scview.contentOffset.y <= -REFRESH_HEADER_HEIGHT) {
        // Released above the header
        [self startPTRLoadingAnimation];
    }
}

- (void)startPTRLoadingAnimation {
    isLoading = YES;

    // Show the header
	//NOTE: not currently compatible with ShadowedTableView
	/*
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:3];
	[UIView setAnimationBeginsFromCurrentState:YES];
    self.tableView.contentInset = UIEdgeInsetsMake(REFRESH_HEADER_HEIGHT, 0, 0, 0);
    [UIView commitAnimations];
	*/
	
	refreshLabel.text = self.textLoading;
    refreshArrow.hidden = YES;
    [refreshSpinner startAnimating];

    // Refresh action!
    [self didRequestRefresh];
}

- (void)stopPTRLoadingAnimation {
    isLoading = NO;
	
	
	[UIView animateWithDuration:0.3f 
						  delay:0 
						options:UIViewAnimationCurveEaseOut 
					 animations:^{ 
						 self.tableView.contentInset = UIEdgeInsetsZero;
						 [refreshArrow layer].transform = CATransform3DMakeRotation(M_PI * 2, 0, 0, 1);
					 }
					 completion:^(BOOL finished){
						 
						 refreshLabel.text = self.textPull;
						 refreshArrow.hidden = NO;
						 [refreshSpinner stopAnimating];
						 
					 }];

}



-(void)updateDataDateValue:(NSDate*)date withSource:(NSString*)source{
	
	NSString *dateString=[NSDate stringFromDate:date withFormat:[NSDate shortHumanFormatStringWithTime]];
	
	if (dateString!=nil) {
		if(source==nil){
			self.updateLabel.text=[NSString stringWithFormat:@"Last Updated: %@",dateString];
		}else{
			self.updateLabel.text=[NSString stringWithFormat:@"Last Updated from %@: %@",source,dateString];
		}
	}
}


-(void)didRequestRefresh {
    // This is just a demo. Override this method with your custom reload action.
    // Don't forget to call stopLoading at the end.
    [self performSelector:@selector(stopPTRLoadingAnimation) withObject:nil afterDelay:2.0];
}


@end
