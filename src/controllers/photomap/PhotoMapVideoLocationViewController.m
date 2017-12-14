//
//  PhotoMapVideoLocationViewController.m
//  CycleStreets
//
//  Created by Neil Edwards on 18/10/2014.
//  Copyright (c) 2014 CycleStreets Ltd. All rights reserved.
//

#import "PhotoMapVideoLocationViewController.h"
#import "PhotoMapVO.h"
#import "LayoutBox.h"
#import "ExpandedUILabel.h"

#import <MediaPlayer/MediaPlayer.h>

@interface PhotoMapVideoLocationViewController ()

@property (nonatomic, weak) IBOutlet	UINavigationBar							*navigationBar;
@property (nonatomic,strong) IBOutlet UIView									*videoPlayerTargetView;
@property (nonatomic, strong) IBOutlet	UIScrollView							*scrollView;
@property (nonatomic, strong)	LayoutBox										*viewContainer;
@property (nonatomic, strong)	ExpandedUILabel									*imageLabel;

@property (nonatomic,assign)  BOOL												initialised;

// mp properties
@property (nonatomic,assign)  BOOL												fullScreenActive;

@property (nonatomic,strong)  MPMoviePlayerController							*videoPlayer;

@end

@implementation PhotoMapVideoLocationViewController

//
/***********************************************
 * @description		NOTIFICATIONS
 ***********************************************/
//

-(void)listNotificationInterests{
	
	[self initialise];
	
	[self.notifications addObject:MPMoviePlayerLoadStateDidChangeNotification];
	[self.notifications addObject:MPMoviePlayerPlaybackDidFinishNotification];
	[self.notifications addObject:MPMediaPlaybackIsPreparedToPlayDidChangeNotification];
	
	[super listNotificationInterests];
	
}

-(void)didReceiveNotification:(NSNotification*)notification{
	
	if([notification.name isEqualToString:MPMoviePlayerPlaybackDidFinishNotification]){
		BetterLog(@"");
	}
	
	if([notification.name isEqualToString:MPMoviePlayerLoadStateDidChangeNotification]){
		BetterLog(@"");
	}
	
	if([notification.name isEqualToString:MPMoviePlayerDidEnterFullscreenNotification]){
		BetterLog(@"");
	}
	
	if([notification.name isEqualToString:MPMoviePlayerLoadStateDidChangeNotification]){
		BetterLog(@"");
	}
}


//
/***********************************************
 * @description			VIEW METHODS
 ***********************************************/
//

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	[self createPersistentUI];
}


-(void)viewWillAppear:(BOOL)animated{
	
	[self createNonPersistentUI];
	
	[super viewWillAppear:animated];
}


-(void)createPersistentUI{
	
	_viewContainer=[[LayoutBox alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 10)];
	_viewContainer.layoutMode=BUVerticalLayoutMode;
	_viewContainer.alignMode=BUCenterAlignMode;
	_viewContainer.fixedWidth=YES;
	_viewContainer.paddingTop=20;
	_viewContainer.paddingBottom=20;
	_viewContainer.itemPadding=20;
	
	self.videoPlayer = [[MPMoviePlayerController alloc] init];
	_videoPlayer.scalingMode = MPMovieScalingModeAspectFit;
	_videoPlayer.controlStyle = MPMovieControlStyleDefault;
	_videoPlayer.movieSourceType=MPMovieSourceTypeFile;
	
	[_videoPlayer prepareToPlay];
	[_videoPlayer.view setFrame: _videoPlayerTargetView.bounds];
	[_videoPlayerTargetView addSubview: _videoPlayer.view];
	[_viewContainer addSubview:_videoPlayerTargetView];
	
	self.imageLabel=[[ExpandedUILabel alloc] initWithFrame:CGRectMake(0, 0, UIWIDTH, 10)];
	_imageLabel.font=[UIFont systemFontOfSize:13];
	_imageLabel.textColor=UIColorFromRGB(0x666666);
	_imageLabel.multiline=YES;
	[_viewContainer addSubview:_imageLabel];
	
	[_scrollView addSubview:_viewContainer];
	
	[self updateContentSize];
	
	
	
	
}

-(void)createNonPersistentUI{
	
	if(!_initialised){
		
		[self loadContentForEntry:_dataProvider];
	
		[_viewContainer refresh];
		[self updateContentSize];
		
		_initialised=YES;
		
	}
	
}



//
/***********************************************
 * @description			Content Loading
 ***********************************************/
//

- (void) loadContentForEntry:(PhotoMapVO *)photoEntry{
	
	self.dataProvider=photoEntry;
	
	self.navigationBar.topItem.title = [NSString stringWithFormat:@"Video #%@", [_dataProvider csidString]];
	
	_imageLabel.text=[_dataProvider caption];
	
	// tests
	//	[_videoPlayer setContentURL:[NSURL URLWithString:@"http://techslides.com/demos/sample-videos/small.mp4"]];
	//  [_videoPlayer setContentURL:[NSURL URLWithString:@"http://buffer.uk.com/iphone/cyclestreets/cyclestreets63066.mp4"]];
	
	[_videoPlayer setContentURL:[NSURL URLWithString:_dataProvider.csVideoURLString]];
	[_videoPlayer play];
	
}



-(void)getMovieLog{
	
	BetterLog(@"");
	
	MPMovieErrorLog *movielog=_videoPlayer.errorLog;
	MPMovieAccessLog *accessLog=_videoPlayer.accessLog;
	
	if(movielog!=nil)
		BetterLog(@"movielog=%@",movielog);
	
	if(accessLog!=nil)
		BetterLog(@"accessLog=%@",accessLog);
}


#pragma mark - MPMoviePlayerController methods



//
/***********************************************
 * @description			UI EVENTS
 ***********************************************/
//


-(IBAction)backButtonSelected:(id)sender{
	
	[_videoPlayer stop];
	[self dismissModalViewControllerAnimated:YES];
	
}



-(void)updateContentSize{
	
	[_scrollView setContentSize:CGSizeMake(SCREENWIDTH, _viewContainer.viewHeight)];
	
}


//
/***********************************************
 * @description			MEMORY
 ***********************************************/
//
- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	
}

@end
