//
//  SaveLocationCreateViewController.m
//  CycleStreets
//
//  Created by Neil Edwards on 16/10/2014.
//  Copyright (c) 2014 CycleStreets Ltd. All rights reserved.
//

#import "SaveLocationCreateViewController.h"
#import "GenericConstants.h"
#import "BUHorizontalMenuView.h"
#import "AppConstants.h"
#import "UIView+Additions.h"
#import "SavedLocationVO.h"
#import "SavedLocationsManager.h"
#import "UIColor+AppColors.h"
#import "UIImage+Additions.h"
#import "GlobalUtilities.h"

@interface SaveLocationMenuView : UIView<BUHorizontalMenuItem>

@property (nonatomic,strong)  UIImageView						*iconView;
@property (nonatomic,strong)  UILabel							*iconLabel;

@property (nonatomic,strong)  NSDictionary                      *dataProvider;

@property (nonatomic,copy)  GenericEventBlock                   touchBlock;

@property (nonatomic,strong)   UIView							*touchView;


@end

@implementation SaveLocationMenuView

- (instancetype)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		[self create];
	}
	return self;
}


-(void)setDataProvider:(NSDictionary*)data{
	
	if(_dataProvider!=data){
		_dataProvider=data;
		
		[self populate];
		
	}
	
}

-(void)layoutSubviews{
	
	[super layoutSubviews];
	
}


-(void)create{
	
	self.iconView=[[UIImageView alloc]initWithFrame:CGRectMake(10, 0, 50, 45)];
	_iconView.contentMode=UIViewContentModeCenter;
	[self addSubview:_iconView];
	self.iconLabel=[[UILabel alloc]initWithFrame:CGRectMake(_iconView.x, _iconView.bottom+3, _iconView.width, 17)];
	_iconLabel.font=[UIFont systemFontOfSize:11];
	_iconLabel.textAlignment=NSTextAlignmentCenter;
	[self addSubview:_iconLabel];
	
	self.touchView=[[UIView alloc]initWithFrame:self.frame];
	[self addSubview:_touchView];
	UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapItem:)];
	tapGesture.numberOfTapsRequired=1;
	[_touchView addGestureRecognizer:tapGesture];
	
}


-(void)populate{
	
	_iconLabel.text=_dataProvider[@"title"];
	
	SavedLocationType locationType=(SavedLocationType)[_dataProvider[@"type"] integerValue];
	NSString *imageName=[SavedLocationVO imageForLocationType:locationType];
	_iconView.image=[UIImage imageNamed:imageName tintColor:[UIColor appTintColor] style:UIImageTintedStyleKeepingAlpha];
	
}




-(void)setSelected:(BOOL)selected{
	
	if(selected){
		self.backgroundColor=UIColorFromRGB(0xDAD8D3);
	}else{
		self.backgroundColor=[UIColor clearColor];
	}
	
}


-(void)didTapItem:(UITapGestureRecognizer*)gesture{
	
	if(_touchBlock)
		_touchBlock(@"",_dataProvider);
	
}


@end


@interface SaveLocationCreateViewController()<BUHorizontalMenuDataSource,BUHorizontalMenuDelegate,UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField			*nameField;
@property (weak, nonatomic) IBOutlet UIButton				*cancelButton;
@property (weak, nonatomic) IBOutlet UIButton				*saveButton;

@property (weak, nonatomic) IBOutlet BUHorizontalMenuView	*iconMenuView;

@property (nonatomic,strong)  NSArray						*savedLocationDataProvider;


@property (nonatomic,strong)  UITextField					*activeField;
@property (nonatomic,assign)  int							fieldOffset;

@end

@implementation SaveLocationCreateViewController


-(void)dealloc{
	[self removeObservers];
}


//
/***********************************************
 * @description		NOTIFICATIONS
 ***********************************************/
//

-(void)listNotificationInterests{
	
	[self initialise];
	
	[self.notifications addObject: UIKeyboardWillShowNotification];
	[self.notifications addObject: UIKeyboardWillHideNotification];
	
	
	[super listNotificationInterests];
	
}

-(void)didReceiveNotification:(NSNotification*)notification{
	
	NSString *name=notification.name;
	
	if([name isEqualToString:UIKeyboardWillShowNotification]){
		[self keyboardWillShow:notification];
	}else if ([name isEqualToString:UIKeyboardWillHideNotification]) {
		[self keyboardWillHide:notification];
	}
	
}

-(void)removeObservers{
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}


//
/***********************************************
 * @description			VIEW METHODS
 ***********************************************/
//

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.savedLocationDataProvider=[SavedLocationVO locationTypeDataProvider];
	
	_iconMenuView.shouldScrollToSelectedItem=NO;
	
	_nameField.delegate=self;
	
	_saveButton.enabled=NO;
	
	[self createPersistentUI];
}


-(void)viewWillAppear:(BOOL)animated{
	
	[self createNonPersistentUI];
	
	[super viewWillAppear:animated];
}


-(void)createPersistentUI{
	
}

-(void)createNonPersistentUI{
	
	[_iconMenuView reloadData];
	
}


#pragma mark - CSOverlayTransitionProtocol

-(void)didDismissWithTouch:(UIGestureRecognizer*)gestureRecogniser{
	
	[self dismissView];
	
}

-(CGSize)preferredContentSize{
	
	return CGSizeMake(280,260);
}


#pragma mark - BUHorizontalMenuView

- (NSInteger) numberOfItemsForMenu:(BUHorizontalMenuView*) menuView{
	return _savedLocationDataProvider.count;
}


- (NSDictionary*) horizMenu:(BUHorizontalMenuView*) menuView itemAtIndex:(NSInteger) index{
	
	return _savedLocationDataProvider[index];
	
}


- (UIView<BUHorizontalMenuItem>*)menuViewItemForIndex:(NSInteger) index{
	
	SaveLocationMenuView *itemView=[[SaveLocationMenuView alloc]initWithFrame:CGRectMake(0, 0, 70, 70)];
	
	[itemView setDataProvider:_savedLocationDataProvider[index]];
	
	return itemView;
	
}



- (void)horizMenu:(BUHorizontalMenuView*) menuView itemSelectedAtIndex:(NSInteger) index{
	
	NSDictionary *itemData=_savedLocationDataProvider[index];
	
	_dataProvider.locationType=(SavedLocationType)[itemData[@"type"] integerValue];
	_dataProvider.title=itemData[@"title"];
	
	[self autoUpdateNameFieldForItem:itemData[@"title"]];
	
	[self validate];
	
}


-(void)autoUpdateNameFieldForItem:(NSString*)titleString{
	
	BOOL titleIsGenericType =[SavedLocationVO titleIsGenericType:_nameField.text];
	if(titleIsGenericType || [_nameField.text isEqualToString:EMPTYSTRING]){
		_nameField.text=titleString;
		[self fieldChanged:nil];
	}
	
}


#pragma mark - UITextField delegate

-(void)textFieldDidBeginEditing:(UITextField *)textField{
	self.activeField=textField;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
	
	[textField resignFirstResponder];
	
	return NO;
}


- (IBAction)fieldChanged:(id)sender {
	
	_dataProvider.title=_nameField.text;
	
	[self validate];
	
}


#pragma mark - validation

-(BOOL)isValid{
	
	BOOL valid=YES;
	
	if(_nameField.text.length<2)
		valid=NO;
	
	if(!_dataProvider.isValid)
		valid=NO;
	   
	return valid;
	
}

-(void)validate{
	
	BOOL isValid=[self isValid];
	
	_saveButton.enabled=isValid;
	
}


#pragma mark - UI Events

//
/***********************************************
 * @description			UI EVENTS
 ***********************************************/
//

-(IBAction)didSelectCancelButton:(id)sender{
	
	[self dismissView];
}

-(IBAction)didSelectSaveButton:(id)sender{
	
	[[SavedLocationsManager sharedInstance] addSavedLocation:_dataProvider];
	
	[self dismissView];
	
}


-(void)dismissView{
	
	[self dismissViewControllerAnimated:YES completion:nil];
	
}






#pragma mark - Keyboard view sizing
//
/***********************************************
 * @description			SCROLLVIEW RESIZING SUPPORT
 ***********************************************/
//

-(void)keyboardWillShow:(NSNotification*)notification{
		
	NSDictionary* userInfo = [notification userInfo];
	NSValue* boundsValue= [userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey];
	float duration=[[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
	
	CGRect boundsRect=[boundsValue CGRectValue];
	
	CGRect textFieldRect = _activeField.frame;
	CGRect newRect=[self.view convertRect:textFieldRect toView:nil];
	
	int avaialableh=boundsRect.origin.y-boundsRect.size.height;
	self.fieldOffset=MAX(0,newRect.origin.y-avaialableh+(_activeField.height+10));
	
	[UIView animateWithDuration:duration animations:^{
		self.view.y-=_fieldOffset;
	}];
	
}


- (void)keyboardWillHide:(NSNotification*)notification{
	
	NSDictionary* userInfo = [notification userInfo];
	
	float duration=[[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
	
	[UIView animateWithDuration:duration animations:^{
		self.view.y+=_fieldOffset;
	}];
	
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
