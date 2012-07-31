//
//  UITextViewWrapperView.h
//
//
//  Created by Neil Edwards on 10/12/2010.
//  Copyright 2010 buffer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EditableTextView.h"


@protocol UITextViewWrapperViewDelegate <NSObject> 

@optional
-(void)textViewWrapperViewContentWasUpdated;
@end



@interface UITextViewWrapperView : UIView <UITextViewDelegate,UIScrollViewDelegate>{
	
	EditableTextView							*textView;
	
	BOOL		keyboardIsShown;
	CGPoint		viewOffSet;
	
	int			addtionalOffset;
	
	CGRect		initalFrame;
	
	BOOL		hasTabBar;
	
	BOOL		isNewContent;
	
	// prompt label
	NSString	*prompt;
	UILabel		*promptLabel;
	
	
	BOOL		dataRequiresSaving;
	id<UITextViewWrapperViewDelegate>		__unsafe_unretained delegate;
	
}
@property (nonatomic, strong) EditableTextView *textView;
@property (nonatomic, strong) NSString *prompt;
@property (nonatomic, strong) UILabel *promptLabel;
@property (nonatomic) BOOL keyboardIsShown;
@property (nonatomic) CGPoint viewOffSet;
@property (nonatomic) int addtionalOffset;
@property (nonatomic) CGRect initalFrame;
@property (nonatomic) BOOL hasTabBar;
@property (nonatomic) BOOL dataRequiresSaving;
@property (nonatomic) BOOL isNewContent;
@property (nonatomic, unsafe_unretained) id<UITextViewWrapperViewDelegate> delegate;

-(void)updatePromptLabel;
@end
