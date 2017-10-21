    //
//  PhotoMapImageLocationViewController.m
//  CycleStreets
//
//  Created by Neil Edwards on 20/04/2011.
//  Copyright 2011 CycleStreets Ltd. All rights reserved.
//

#import "PhotoMapImageLocationViewController.h"
#import "AppConstants.h"
#import "CopyLabel.h"
#import "GenericConstants.h"
#import "BUIconActionSheet.h"
#import <MessageUI/MessageUI.h>
#import <Twitter/Twitter.h>
#import "ExpandedUILabel.h"
#import "AsyncImageView.h"
#import "LayoutBox.h"
#import "PhotoMapVO.h"
#import "PhotoManager.h"


@interface PhotoMapImageLocationViewController()<AsyncImageViewDelegate,BUIconActionSheetDelegate,MFMailComposeViewControllerDelegate,MFMessageComposeViewControllerDelegate>

@property (nonatomic, strong) IBOutlet	UINavigationBar				*navigationBar;
@property (nonatomic, strong) IBOutlet	UIScrollView				*scrollView;
@property (nonatomic, strong)	LayoutBox					*viewContainer;
@property (nonatomic, strong)	AsyncImageView				*imageView;
@property (nonatomic, strong)	ExpandedUILabel				*imageLabel;
@property (nonatomic, strong)	CopyLabel					*titleLabel;

-(void)updateContentSize;
-(void)createPersistentUI;
-(void)createNavigationBarUI;
-(void)createNonPersistentUI;
-(IBAction)backButtonSelected:(id)sender;
-(IBAction)shareButtonSelected:(id)sender;

@end


@implementation PhotoMapImageLocationViewController


//
/***********************************************
 * @description			DATA UPDATING
 ***********************************************/
//

-(void)refreshUIFromDataProvider{
	
	
}

-(void)ImageDidLoadWithImage:(UIImage*)image{
	
	[_viewContainer refresh];
	[self updateContentSize];
	
}




//
/***********************************************
 * @description			UI CREATION
 ***********************************************/
//

- (void)viewDidLoad {
	
	[super viewDidLoad];
	
	[self createPersistentUI];
}


-(void)createPersistentUI{
	
	
	_viewContainer=[[LayoutBox alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 10)];
	_viewContainer.layoutMode=BUVerticalLayoutMode;
	_viewContainer.alignMode=BUCenterAlignMode;
	_viewContainer.fixedWidth=YES;
	_viewContainer.paddingTop=20;
	_viewContainer.paddingBottom=20;
	_viewContainer.itemPadding=20;
		
	_imageView=[[AsyncImageView alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 240)];
	_imageView.delegate=self;
	_imageView.cacheImage=NO;
	[_viewContainer addSubview:_imageView];
	
	_imageLabel=[[ExpandedUILabel alloc] initWithFrame:CGRectMake(0, 0, UIWIDTH, 10)];
	_imageLabel.font=[UIFont systemFontOfSize:13];
	_imageLabel.textColor=UIColorFromRGB(0x666666);
	_imageLabel.hasShadow=NO;
	_imageLabel.multiline=YES;
	[_viewContainer addSubview:_imageLabel];
	
	[_scrollView addSubview:_viewContainer];
	
	[self updateContentSize];
	
	
}


-(void)createNavigationBarUI{
	
	
	self.titleLabel=[[CopyLabel alloc]initWithFrame:CGRectMake(0, 0, 150, 30)];
	_titleLabel.textAlignment=UITextAlignmentCenter;
	_titleLabel.font=[UIFont boldSystemFontOfSize:20];
	_titleLabel.textColor=[UIColor whiteColor];
	_titleLabel.shadowOffset=CGSizeMake(0, -1);
	_titleLabel.shadowColor=[UIColor grayColor];
	
	[self.navigationBar.topItem setTitleView:_titleLabel];
	
	
}


-(void)viewWillAppear:(BOOL)animated{
	
	[super viewWillAppear:animated];
	
	[self createNonPersistentUI];
	
}

-(void)createNonPersistentUI{
	
	_imageView.frame=CGRectMake(0, 0, SCREENWIDTH, 240);
	
	[self loadContentForEntry:_dataProvider];
	
	[_viewContainer refresh];
	[self updateContentSize];
	
}



//
/***********************************************
 * @description			Content Loading
 ***********************************************/
//

- (void) loadContentForEntry:(PhotoMapVO *)photoEntry{
	
	
	self.dataProvider=photoEntry;
	
	self.navigationBar.topItem.title = [NSString stringWithFormat:@"Photo #%@", [_dataProvider csidString]];
	
	_imageLabel.text=[_dataProvider caption];
	
	[_imageView loadImageFromString:[_dataProvider bigImageURL]];
	
}


//
/***********************************************
 * @description		UI EVENTS
 ***********************************************/
//

-(IBAction)backButtonSelected:(id)sender{
	
	[_imageView cancel];
	
	[self dismissModalViewControllerAnimated:YES];
	
}



-(IBAction)shareButtonSelected:(id)sender{
	
	NSArray *activitites;
	
	
	
	if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
		
		UIActivityViewController *activity=[[UIActivityViewController alloc] initWithActivityItems:@[[NSURL URLWithString:_dataProvider.csImageUrlString],_imageView.image] applicationActivities:nil];
		activity.excludedActivityTypes = @[UIActivityTypeSaveToCameraRoll, UIActivityTypePrint, UIActivityTypePostToWeibo];
		
		[self presentViewController:activity animated:YES completion:nil];
		[activity setCompletionHandler:^(NSString *activityType, BOOL completed){
			
			if(completed==YES){
				
				
				
			}
			
		}];
		
		
		
	}else{
	
		
		activitites=@[@(BUIconActionSheetIconTypeTwitter),@(BUIconActionSheetIconTypeMail),@(BUIconActionSheetIconTypeSMS),@(BUIconActionSheetIconTypeCopy)];
		
		BUIconActionSheet *iconSheet=[[BUIconActionSheet alloc] initWithButtons:activitites andTitle:@"Share this CycleStreets photo"];
		iconSheet.delegate=self;
		
		[iconSheet show:YES];
	
		
	}
	
	
}

// BUIconActionSheet delegate callback
-(void)actionSheetClickedButtonWithType:(BUIconActionSheetIconType)type{
	
	
	switch (type) {
		case BUIconActionSheetIconTypeTwitter:
			
			if ([TWTweetComposeViewController canSendTweet]) {
				
				TWTweetComposeViewController *tweetViewController = [[TWTweetComposeViewController alloc] init];
				[tweetViewController setInitialText:[NSString stringWithFormat:@"Great cycling photo on the @CycleStreets Photomap: %@",_dataProvider.csImageUrlString]];
				
				[tweetViewController addImage:_imageView.image];
				
				
				[self presentViewController:tweetViewController animated:YES completion:nil];
				[tweetViewController setCompletionHandler:^(SLComposeViewControllerResult result){
					
					[self dismissModalViewControllerAnimated:YES];
					
				}];
				
			} else {
				
				UIAlertView *alertView = [[UIAlertView alloc]
										  initWithTitle:@"Sorry"
										  message:@"You can't send a tweet right now, make sure your device has an internet connection and you have at least one Twitter account set up"
										  delegate:self
										  cancelButtonTitle:@"OK"
										  otherButtonTitles:nil];
				[alertView show];
				
				
				
				
			}
			
			
			break;
			
		case BUIconActionSheetIconTypeMail:
		{
			MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
			picker.mailComposeDelegate = self;
			[picker setSubject:[NSString stringWithFormat:@"CycleStreets photo %@",_dataProvider.csidString]];
			[picker setMessageBody:[NSString stringWithFormat:@"<a href=%@>CycleStreets photo %@</a>",_dataProvider.csImageUrlString,_dataProvider.csidString] isHTML:YES];
			[picker addAttachmentData:UIImageJPEGRepresentation(_imageView.image, 1) mimeType:@"image/jpeg" fileName:@"CSPhoto.jpeg"];
			
			if(picker!=nil)
				[self presentModalViewController:picker animated:YES];
		}
			break;
			
		case BUIconActionSheetIconTypeSMS:
		{
			
			MFMessageComposeViewController *picker=[[MFMessageComposeViewController alloc]init];
			picker.messageComposeDelegate=self;
			[picker setBody:_dataProvider.csImageUrlString];
			
			if(picker!=nil)
				[self presentModalViewController:picker animated:YES];
			
			
		}
			
			break;
			
		case BUIconActionSheetIconTypeCopy:
		{
			[[UIPasteboard generalPasteboard] setString:_dataProvider.csImageUrlString];
		}
			
			break;
			
		default:
			break;
	}
	
}


// The mail compose view controller delegate method
- (void)mailComposeController:(MFMailComposeViewController *)controller  didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
	
	[self dismissModalViewControllerAnimated:YES];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result{
	
	[self dismissModalViewControllerAnimated:YES];
}


//
/***********************************************
 * @description			GENERIC METHODS
 ***********************************************/
//


-(void)updateContentSize{
	
	[_scrollView setContentSize:CGSizeMake(SCREENWIDTH, _viewContainer.viewHeight)];
	
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

@end
