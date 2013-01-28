    //
//  PhotoMapImageLocationViewController.m
//  CycleStreets
//
//  Created by Neil Edwards on 20/04/2011.
//  Copyright 2011 CycleStreets Ltd. All rights reserved.
//

#import "PhotoMapImageLocationViewController.h"
#import "AppConstants.h"
#import "GradientView.h"
#import "CopyLabel.h"



@interface PhotoMapImageLocationViewController(Private) 

-(void)updateContentSize;
-(void)updateImageSize;
-(void)createPersistentUI;
-(void)createNavigationBarUI;
-(void)createNonPersistentUI;
-(IBAction)backButtonSelected:(id)sender;
-(IBAction)shareButtonSelected:(id)sender;

@end


@implementation PhotoMapImageLocationViewController
@synthesize dataProvider;
@synthesize navigationBar;
@synthesize scrollView;
@synthesize viewContainer;
@synthesize imageView;
@synthesize imageLabel;
@synthesize titleLabel;


//
/***********************************************
 * @description			DATA UPDATING
 ***********************************************/
//

-(void)refreshUIFromDataProvider{
	
	
}

-(void)ImageDidLoadWithImage:(UIImage*)image{
	
	[viewContainer refresh];
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
	
	[(GradientView*)self.view setColoursWithCGColors:UIColorFromRGB(0xFFFFFF).CGColor :UIColorFromRGB(0xDDDDDD).CGColor];
	
	viewContainer=[[LayoutBox alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 10)];
	viewContainer.layoutMode=BUVerticalLayoutMode;
	viewContainer.alignMode=BUCenterAlignMode;
	viewContainer.fixedWidth=YES;
	viewContainer.paddingTop=20;
	viewContainer.itemPadding=20;
		
	imageView=[[AsyncImageView alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 240)];
	imageView.delegate=self;
	imageView.cacheImage=NO;
	[viewContainer addSubview:imageView];
	
	imageLabel=[[ExpandedUILabel alloc] initWithFrame:CGRectMake(0, 0, UIWIDTH, 10)];
	imageLabel.font=[UIFont systemFontOfSize:13];
	imageLabel.textColor=UIColorFromRGB(0x666666);
	imageLabel.hasShadow=YES;
	imageLabel.multiline=YES;
	[viewContainer addSubview:imageLabel];
	
	[scrollView addSubview:viewContainer];
	
	[self updateContentSize];
	
	[self createNavigationBarUI];
}


-(void)createNavigationBarUI{
	

	
	self.titleLabel=[[CopyLabel alloc]initWithFrame:CGRectMake(0, 0, 150, 30)];
	titleLabel.textAlignment=UITextAlignmentCenter;
	titleLabel.font=[UIFont boldSystemFontOfSize:20];
	titleLabel.textColor=[UIColor whiteColor];
	titleLabel.shadowOffset=CGSizeMake(0, -1);
	titleLabel.shadowColor=[UIColor grayColor];
	
	[self.navigationBar.topItem setTitleView:titleLabel];
	
	
}


-(void)viewWillAppear:(BOOL)animated{
	
	[super viewWillAppear:animated];
	
	[self createNonPersistentUI];
	
}

-(void)createNonPersistentUI{
	
	imageView.frame=CGRectMake(0, 0, SCREENWIDTH, 240);
	[viewContainer refresh];
	[self updateContentSize];
	
}



//
/***********************************************
 * @description			Content Loading
 ***********************************************/
//

- (void) loadContentForEntry:(PhotoMapVO *)photoEntry{
	
	
	self.dataProvider=photoEntry;
	
	titleLabel.text = [NSString stringWithFormat:@"Photo #%@", [dataProvider csid]];
	
	imageLabel.text=[dataProvider caption];
	
	[imageView loadImageFromString:[dataProvider bigImageURL]];
	
}


//
/***********************************************
 * @description		UI EVENTS
 ***********************************************/
//

-(IBAction)backButtonSelected:(id)sender{
	
	[imageView cancel];
	[self dismissModalViewControllerAnimated:YES];
	
}



-(IBAction)shareButtonSelected:(id)sender{
	
	NSArray *activitites;
	
	
	#if ENABLEOS6ACTIVITYMODE
	
	if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0")) {
		
		UIActivityViewController *activity=[[UIActivityViewController alloc] initWithActivityItems:@[[NSURL URLWithString:dataProvider.csImageUrlString],imageView.image] applicationActivities:nil];
		activity.excludedActivityTypes = @[UIActivityTypeSaveToCameraRoll, UIActivityTypePrint, UIActivityTypePostToWeibo];
		
		[self presentViewController:activity animated:YES completion:nil];
		[activity setCompletionHandler:^(NSString *activityType, BOOL completed){
			
			if(completed==YES){
				
				
				
			}
			
		}];
		
		
		
	}else{
	
	#endif
		
		activitites=@[@(BUIconActionSheetIconTypeTwitter),@(BUIconActionSheetIconTypeMail),@(BUIconActionSheetIconTypeSMS),@(BUIconActionSheetIconTypeCopy)];
		
		BUIconActionSheet *iconSheet=[[BUIconActionSheet alloc] initWithButtons:activitites andTitle:@"Share this CycleStreets photo"];
		iconSheet.delegate=self;
		
		[iconSheet show:YES];
	
	
	#if ENABLEOS6MODE	
	}
	#endif
	
	
}

// BUIconActionSheet delegate callback
-(void)actionSheetClickedButtonWithType:(BUIconActionSheetIconType)type{
	
	
	switch (type) {
		case BUIconActionSheetIconTypeTwitter:
			
			if ([TWTweetComposeViewController canSendTweet]) {
				
				TWTweetComposeViewController *tweetViewController = [[TWTweetComposeViewController alloc] init];
				[tweetViewController setInitialText:[NSString stringWithFormat:@"Great cycling photo on the @CycleStreets Photomap: %@",dataProvider.csImageUrlString]];
				
				[tweetViewController addImage:imageView.image];
				
				
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
			[picker setSubject:[NSString stringWithFormat:@"CycleStreets photo %@",dataProvider.csid]];
			[picker setMessageBody:[NSString stringWithFormat:@"<a href=%@>CycleStreets photo %@</a>",dataProvider.csImageUrlString,dataProvider.csid] isHTML:YES];
			[picker addAttachmentData:UIImageJPEGRepresentation(imageView.image, 1) mimeType:@"image/jpeg" fileName:@"CSPhoto.jpeg"];
			
			if(picker!=nil)
				[self presentModalViewController:picker animated:YES];
		}
			break;
			
		case BUIconActionSheetIconTypeSMS:
		{
			
			MFMessageComposeViewController *picker=[[MFMessageComposeViewController alloc]init];
			picker.messageComposeDelegate=self;
			[picker setBody:dataProvider.csImageUrlString];
			
			if(picker!=nil)
				[self presentModalViewController:picker animated:YES];
			
			
		}
			
			break;
			
		case BUIconActionSheetIconTypeCopy:
		{
			[[UIPasteboard generalPasteboard] setString:dataProvider.csImageUrlString];
		}
			
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
	
	[scrollView setContentSize:CGSizeMake(SCREENWIDTH, viewContainer.height)];
	
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

@end
