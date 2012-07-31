//
//  BUIconGridViewController.m
//  RacingUK
//
//  Created by Neil Edwards on 09/12/2011.
//  Copyright (c) 2011 Chroma. All rights reserved.
//

#import "BUIconGridViewController.h"
#import "LayoutBox.h"
#import "ViewUtilities.h"


@interface BUIconGridViewController(Private) 

-(void)createPageContentForPage:(int)index withData:(NSArray*)arr;

-(void)itemSelected:(int)index;
-(void)selectItemUI:(BOOL)state;

@end



@implementation BUIconGridViewController
@synthesize dataProvider;
@synthesize itemArray;
@synthesize selectedItem;
@synthesize selectedViewData;
@synthesize selectedItemIndex;
@synthesize rowCount;
@synthesize columnCount;
@synthesize itemsPerPage;
@synthesize pageCount;
@synthesize viewDoesPaging;
@synthesize pageControl;
@synthesize activePage;
@synthesize fillEmptySlots;
@synthesize startColor;
@synthesize endColor;
@synthesize buttonBackgroundImage;
@synthesize buttonIconTextColor;
@synthesize buttonIconLabelFont;


- (void)viewDidLoad{
	
    [super viewDidLoad];
	
	fillEmptySlots=YES;
	activePage=0;
	columnCount=3;
	rowCount=3;
	
}

-(void)createPersistentUI{
	
	// create scroll view
	self.scrollView=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHTWITHNAVANDTAB)];
	[self.view addSubview:scrollView];
	
	self.pageControl=[[UIPageControl alloc]init];
	pageControl.hidesForSinglePage=YES;
	[pageControl addTarget:self action:@selector(pageControlValueChanged:) forControlEvents:UIControlEventValueChanged];
	[self.view addSubview:pageControl];
	[ViewUtilities alignView:pageControl withView:self.view :BUBottomAlignMode :BUCenterAlignMode];
		
}



-(void)refreshUIFromDataProvider{
	
	BetterLog(@"");
	
	itemsPerPage=rowCount*columnCount;
	int totalPages=ceil([dataProvider count]/itemsPerPage);
	
	if(itemsPerPage>[dataProvider count])
		itemsPerPage=[dataProvider count];
	
	viewDoesPaging=totalPages>1;
	
	scrollView.pagingEnabled=viewDoesPaging;
	
	self.itemArray=[NSMutableArray array];
	
	int itemCount=[dataProvider count];
	
	for (int i=0; i<totalPages; i++) {
		
		itemCount-=itemsPerPage;
		int pageLength;
		if(itemCount>=0){
			pageLength=itemsPerPage;
		}else{
			pageLength=itemCount;
		}
		
		int pageStart=i*itemsPerPage;
		
		NSArray *pageArr=[dataProvider subarrayWithRange:NSMakeRange(pageStart, pageLength)];
		[self createPageContentForPage:i withData:pageArr];
	}
	
	activePage=0;
	selectedItemIndex=-1;
	pageControl.numberOfPages=totalPages;
	pageControl.currentPage=activePage;
}


-(void)createPageContentForPage:(int)index withData:(NSArray*)arr{
	
	BetterLog(@"");
	
	LayoutBox *pageContainer=[[LayoutBox alloc] initWithFrame:CGRectMake(0, index*SCREENWIDTH, SCREENWIDTH, NAVTABLEHEIGHT)];
	pageContainer.fixedWidth=YES;
	pageContainer.fixedHeight=YES;
	pageContainer.layoutMode=BUVerticalLayoutMode;
	pageContainer.alignMode=BUCenterAlignMode;
	pageContainer.paddingTop=20;
	pageContainer.paddingBottom=20;
	pageContainer.itemPadding=20;
	pageContainer.startColor=startColor;
	pageContainer.endColor=endColor;
	[scrollView addSubview:pageContainer];
	
	// create rows
	LayoutBox	*rowContainer;
	
	for(int i=0;i<[arr count];i++){
		
		NSDictionary *itemDataProvider=[arr objectAtIndex:i];
		
		if(i%rowCount==0){
			
			rowContainer=[[LayoutBox alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 10)];
			rowContainer.paddingLeft=10;
			rowContainer.paddingRight=10;
			rowContainer.itemPadding=40;
			[pageContainer addSubview:rowContainer];
		}
		
		BUIconButton *itemButton=[[BUIconButton alloc]initWithFrame:CGRectMake(0, 0, 100, 10)];
		itemButton.index=index+i;
		itemButton.buttonIconImage=[itemDataProvider objectForKey:@"icon"];  // tababr icon
		itemButton.buttonBackgroundImage=buttonBackgroundImage;
		itemButton.textColor=buttonIconTextColor;
		itemButton.labelFont=buttonIconLabelFont;
		itemButton.text=[itemDataProvider objectForKey:@"title"];
		[itemButton drawUI];
		
		// TODO: this is only temp implementation
		itemButton.button.tag=i;
		[itemButton.button addTarget:self action:@selector(gridButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
		
		[rowContainer addSubview:itemButton];
		[itemArray addObject:itemButton];
		
	}
	
		
	[pageContainer refresh];
	
	[scrollView setContentSize:CGSizeMake(SCREENWIDTH*index, pageContainer.height)];
	
}


- (void)viewWillAppear:(BOOL)animated {
	
	[self createNonPersistentUI];
	
    [super viewWillAppear:animated];
}



-(void)createNonPersistentUI{
	
	
	// fade de select selected item button
	if(selectedItem!=nil){
		
		selectedItemIndex=-1;
		selectedItem=nil;
	}
	
	
}



//
/***********************************************
 * @description			USER EVENTS
 ***********************************************/
//


-(IBAction)gridButtonSelected:(id)sender{
	
	UIButton *button=(UIButton*)sender;
	[self itemSelected:button.tag];
	
}

-(IBAction)pageControlValueChanged:(id)sender{
	
	UIPageControl *pc=(UIPageControl*)sender;
	CGPoint offset=CGPointMake(pc.currentPage*SCREENWIDTH, 0);
	[scrollView setContentOffset:offset animated:YES];
	
}



//
/***********************************************
 * @description			GRID ITEM METHODS
 ***********************************************/
//

-(void)itemSelected:(int)index{
	
	BetterLog(@"");
	
	if(index!=selectedItemIndex){
		
		if(selectedItem!=nil)
			[self selectItemUI:NO];
		
		selectedItemIndex=index;
		self.selectedItem=[itemArray objectAtIndex:selectedItemIndex];
		self.selectedViewData=[dataProvider objectAtIndex:selectedItemIndex];
		
		[self selectItemUI:YES];
		
		[self loadSubViewControllerForSelectedItem]; 
		
	}
}

// subclasses override this
-(void)loadSubViewControllerForSelectedItem{
	
	BetterLog(@"[WARNING] THIS METHOD SHOULD HAVE BEEN OVERRIDDEN");

} 


-(void)selectItemByIndex:(int)index{
	
	if(index<[dataProvider count]){
		
		if([dataProvider objectAtIndex:index]!=nil){
			
			int pageIndex=ceil(index/itemsPerPage);
			
			if(pageCount>1){
				[pageControl setCurrentPage:pageIndex];
			}
			
			[self itemSelected:index];
		}
	}
	
}

-(void)selectItemByID:(NSString*)idstring{
	
	int index=-1;
	
	for(NSDictionary *dict in dataProvider){
		
		NSString *name=[dict objectForKey:@"id"];
		if([name isEqualToString:idstring]){
			index=[dataProvider indexOfObject:dict];
		}
		
	}
	
	// TODO: for multipage support this should then call selectItemByIndex:
	if(index!=-1){
		[self itemSelected:index];
	}
	
}


-(void)selectItemUI:(BOOL)state{
	
	if(state==YES){
		
		
		
		
	}else{
		
		
		
		
	}
	
	
}


//
/***********************************************
 * @description			generic methods
 ***********************************************/
//
- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
