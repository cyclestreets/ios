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

@interface PhotoMapImageLocationViewController()


@property (nonatomic, strong)	PhotoMapVO		*dataProvider;
@property (nonatomic, strong)	UINavigationBar		*navigationBar;
@property (nonatomic, strong)	UIScrollView		*scrollView;
@property (nonatomic, strong)	LayoutBox		*viewContainer;
@property (nonatomic, strong)	AsyncImageView		*imageView;
@property (nonatomic, strong)	ExpandedUILabel		*imageLabel;
@property (nonatomic, strong)	CopyLabel		*titleLabel;

-(void)updateContentSize;
-(void)createPersistentUI;
-(void)createNavigationBarUI;
-(void)createNonPersistentUI;
-(IBAction)backButtonSelected:(id)sender;

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
	
	[(GradientView*)self.view setColoursWithCGColors:UIColorFromRGB(0xFFFFFF).CGColor :UIColorFromRGB(0xDDDDDD).CGColor];
	
	self.viewContainer=[[LayoutBox alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 10)];
	_viewContainer.layoutMode=BUVerticalLayoutMode;
	_viewContainer.alignMode=BUCenterAlignMode;
	_viewContainer.fixedWidth=YES;
	_viewContainer.paddingTop=20;
	_viewContainer.itemPadding=20;
		
	self.imageView=[[AsyncImageView alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 240)];
	_imageView.delegate=self;
	_imageView.cacheImage=NO;
	[_viewContainer addSubview:_imageView];
	
	self.imageLabel=[[ExpandedUILabel alloc] initWithFrame:CGRectMake(0, 0, UIWIDTH, 10)];
	_imageLabel.font=[UIFont systemFontOfSize:13];
	_imageLabel.textColor=UIColorFromRGB(0x666666);
	_imageLabel.hasShadow=YES;
	_imageLabel.multiline=YES;
	[_viewContainer addSubview:_imageLabel];
	
	[_scrollView addSubview:_viewContainer];
	
	[self updateContentSize];
	
	[self createNavigationBarUI];
}


-(void)createNavigationBarUI{
	
	UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithTitle:@"Done"
															  style:UIBarButtonItemStyleBordered
															 target:self
															 action:@selector(backButtonSelected:)];
	
	self.titleLabel=[[CopyLabel alloc]initWithFrame:CGRectMake(0, 0, 150, 30)];
	_titleLabel.textAlignment=UITextAlignmentCenter;
	_titleLabel.font=[UIFont boldSystemFontOfSize:20];
	_titleLabel.textColor=[UIColor whiteColor];
	_titleLabel.shadowOffset=CGSizeMake(0, -1);
	_titleLabel.shadowColor=[UIColor grayColor];
	
	[self.navigationBar.topItem setTitleView:_titleLabel];
	
	[self.navigationBar.topItem setRightBarButtonItem:back];
	
	
}


-(void)viewWillAppear:(BOOL)animated{
	
	[super viewWillAppear:animated];
	
	[self createNonPersistentUI];
	
}

-(void)createNonPersistentUI{
	
	_imageView.frame=CGRectMake(0, 0, SCREENWIDTH, 240);
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
	
	//self.navigationBar.topItem.title = [NSString stringWithFormat:@"Photo #%@", [dataProvider csid]];
	
	_titleLabel.text = [NSString stringWithFormat:@"Photo #%@", [_dataProvider csid]];
	
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


//
/***********************************************
 * @description			GENERIC METHODS
 ***********************************************/
//


-(void)updateContentSize{
	
	[_scrollView setContentSize:CGSizeMake(SCREENWIDTH, _viewContainer.height)];
	
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
	
	if (self.isViewLoaded && !self.view.window) {
        self.view = nil;
    }
	
	self.dataProvider=nil;
	self.navigationBar=nil;
	self.scrollView=nil;
	self.viewContainer=nil;
	self.imageView=nil;
	self.imageLabel=nil;
	self.titleLabel=nil;
}


@end
