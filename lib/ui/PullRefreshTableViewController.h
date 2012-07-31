//
//  PullRefreshTableViewController.h
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

#import <UIKit/UIKit.h>
#import "BUViewController.h"
#import "GradiantRectView.h"
#import "ExpandedUILabel.h"

@interface PullRefreshTableViewController : BUViewController {
   // UIView *refreshHeaderView;
    ExpandedUILabel *refreshLabel;
	 ExpandedUILabel *updateLabel;
    UIImageView *refreshArrow;
    UIActivityIndicatorView *refreshSpinner;
    BOOL isDragging;
    BOOL isLoading;
    NSString *textPull;
    NSString *textRelease;
    NSString *textLoading;
	
	IBOutlet		UITableView			*tableView;
}

//@property (nonatomic, retain) IBOutlet GradiantRectView *refreshHeaderView;
@property (nonatomic, strong) IBOutlet ExpandedUILabel *refreshLabel;
@property (nonatomic, strong) IBOutlet ExpandedUILabel *updateLabel;
@property (nonatomic, strong) IBOutlet UIImageView *refreshArrow;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *refreshSpinner;
@property (nonatomic) BOOL isDragging;
@property (nonatomic) BOOL isLoading;
@property (nonatomic, strong) NSString *textPull;
@property (nonatomic, strong) NSString *textRelease;
@property (nonatomic, strong) NSString *textLoading;
@property (nonatomic, strong) IBOutlet UITableView *tableView;


- (void)addPullToRefreshHeader;
- (void)startPTRLoadingAnimation;
- (void)stopPTRLoadingAnimation;
-(void)didRequestRefresh;

// explict UIScrollView delegate support, allows subclass that override this method to still call super
- (void)scrollViewDidScroll:(UIScrollView *)tableScrollView;

-(void)updateDataDateValue:(NSDate*)date withSource:(NSString*)source;

@end
