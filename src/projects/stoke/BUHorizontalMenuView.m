//
//  BUHorizontalMenuView.m
//  Flotsm
//
//  Created by Neil Edwards on 23/09/2014.
//  Copyright (c) 2014 mohawk. All rights reserved.
//

#import "BUHorizontalMenuView.h"

#import "LayoutBox.h"
#import "UIView+Additions.h"
#import "UIButton+Additions.h"
#import "GenericConstants.h"
#import "GlobalUtilities.h"
#import "UIColor+AppColors.h"

#import <UIControl+BlocksKit.h>

@interface BUHorizontalMenuView()<UIScrollViewDelegate>

@property (nonatomic,strong)  LayoutBox									*itemContainer;
@property (nonatomic,strong)  UIScrollView								*scrollView;



@end


@implementation BUHorizontalMenuView


-(instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        [self createUI];
    }
    return self;
    
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self createUI];
    }
    return self;
    
}

-(void)createUI{
    
    _selectedIndex=-1;
    
    self.scrollView=[[UIScrollView alloc]initWithFrame:self.bounds];
    _scrollView.bounces = YES;
    _scrollView.scrollEnabled = YES;
    _scrollView.alwaysBounceHorizontal = YES;
    _scrollView.alwaysBounceVertical = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    //_scrollView.pagingEnabled=YES;
    _scrollView.contentInset=UIEdgeInsetsMake(0, 0,0,0);
    
    self.itemContainer=[[LayoutBox alloc]initWithFrame:self.bounds];
    _itemContainer.alignMode=BUCenterAlignMode;
    _itemContainer.fixedHeight=YES;
    _itemContainer.paddingLeft=0;
    _itemContainer.paddingRight=0;
    _itemContainer.itemPadding=10;
    
    [_scrollView addSubview:_itemContainer];
    
    [self addSubview:_scrollView];
    
	
}



#pragma mark - public methods


-(void)reloadData{
    
    [_itemContainer removeAllSubViews];
    
    self.itemCount = [_menuDataSource numberOfItemsForMenu:self];
    
    __weak __typeof(&*self)weakSelf = self;
    for(NSInteger i=0;i<_itemCount;i++){
        
        NSDictionary *itemData = [_menuDataSource horizMenu:self itemAtIndex:i];
        
		 __weak UIView<BUHorizontalMenuItem> *itemView=(UIView<BUHorizontalMenuItem>*)[_menuDataSource menuViewItemForIndex:i];
		
		[itemView setTouchBlock:^(NSString *eventType, id dataProvider) {
			[weakSelf didSelectItem:itemView atIndex:i];
		}];
		
		[itemView setDataProvider:itemData];
		
        [_itemContainer addSubview:itemView];
        
    }
    
    
    
    [self refreshContentSize];
    
}

-(void)refreshContentSize{
    
    [_scrollView setContentSize:_itemContainer.size];
    
}

-(void)setSelectedIndex:(NSInteger)selectedIndex{
   
    _selectedIndex=selectedIndex;
	
}


-(void) setSelectedIndex:(NSInteger)index animated:(BOOL)animated{
    
    if(index==_selectedIndex)
        return;
    
	[self updateUIForSelectedIndex:index];
	
	[self setSelectedIndex:index];
	
}


-(void)updateUIForSelectedIndex:(NSInteger)index{
	
	if(index==_selectedIndex)
		return;
	
	UIView<BUHorizontalMenuItem> *itemView=(UIView<BUHorizontalMenuItem>*) [_itemContainer viewAtIndex:index];
	UIView<BUHorizontalMenuItem> *oldItem=(UIView<BUHorizontalMenuItem>*) [_itemContainer viewAtIndex:_selectedIndex];
	
	[itemView setSelected:YES];
	[oldItem setSelected:NO];
	
	[_scrollView setContentOffset:CGPointMake(itemView.x , 0) animated:YES];
	
	
}

// temp only; Pixate is not updating the font size when  :selected is set
-(void)updateFontSizeForButton:(UIButton*)button{
    
    if(button.selected){
        [button.titleLabel setFont:[button.titleLabel.font fontWithSize:15]];
    }else{
        [button.titleLabel setFont:[button.titleLabel.font fontWithSize:11]];
    }
    
}


#pragma mark - UI Events

-(void) didSelectItem:( UIView<BUHorizontalMenuItem>*)itemView atIndex:(NSInteger)index{
	
	BetterLog(@"");
	
	[self updateUIForSelectedIndex:index];
    
	[self setSelectedIndex:index];
	
    [self.menuDelegate horizMenu:self itemSelectedAtIndex:index];
}

-(void) didSelectButton:(UIButton*)button atIndex:(NSInteger)index{
	
	[self setSelectedIndex:index];
	
	[self.menuDelegate horizMenu:self itemSelectedAtIndex:index];
}





@end
