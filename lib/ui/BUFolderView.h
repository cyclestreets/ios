//
//  BUFolderView.h
//  Buffer
//
//  Created by Neil Edwards on 15/03/2011.
//  Copyright 2011 Buffer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BUFolderViewHeader.h"
#import "LayoutBox.h"

enum{
	BUFolderContentTypeImage,
	BUFolderContentTypeTextView
};
typedef int BUFolderContentType;

@interface BUFolderView : UIView {
	
	// button target
	int							targetPoint;
	
	// content
	NSString					*imageURL;
	NSString					*textContent;
	
	// internal views
	UIImageView					*imageView;
	UITextView					*textView;
	
	
	BUFolderViewHeader			*headerView;
	UIView						*footerView;
	UIView						*contentView;
	
	// animation targets
	NSArray						*lowerViews;
	LayoutBox					*parentContainer;
	UIScrollView				*parentScrollView;
	
	BOOL						collapsed;
	BUFolderContentType			contentType;
	int							contentHeight;

}
@property (nonatomic)		int		 targetPoint;
@property (nonatomic, strong)		NSString		* imageURL;
@property (nonatomic, strong)		NSString		* textContent;
@property (nonatomic, strong)		IBOutlet UIImageView		* imageView;
@property (nonatomic, strong)		IBOutlet UITextView		* textView;
@property (nonatomic, strong)		BUFolderViewHeader		* headerView;
@property (nonatomic, strong)		IBOutlet UIView		* footerView;
@property (nonatomic, strong)		IBOutlet UIView		* contentView;
@property (nonatomic, strong)		NSArray		* lowerViews;
@property (nonatomic, strong)		LayoutBox		* parentContainer;
@property (nonatomic, strong)		IBOutlet UIScrollView		* parentScrollView;
@property (nonatomic)		BOOL		 collapsed;
@property (nonatomic)		BUFolderContentType		 contentType;
@property (nonatomic)		int		 contentHeight;

-(void)initialise;
-(void)toggleVisibility;

@end
