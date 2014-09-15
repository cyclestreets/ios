//
//  BUIconActionSheet.h
//  CycleStreets
//
//  Created by Neil Edwards on 01/12/2012.
//  Copyright (c) 2012 CycleStreets Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSUInteger, BUIconActionSheetIconType) {
	BUIconActionSheetIconTypeTwitter	= 999,
	BUIconActionSheetIconTypeFacebook	= 998,
	BUIconActionSheetIconTypeMail		= 997,
	BUIconActionSheetIconTypeSMS		= 996,
	BUIconActionSheetIconTypeCopy		= 995,
};



@protocol BUIconActionSheetDelegate <NSObject>

@optional
- (void)actionSheetClickedButtonAtIndex:(NSInteger)buttonIndex;
- (void)actionSheetClickedButtonWithType:(BUIconActionSheetIconType)type;


@end

@interface BUIconActionSheet : UIView

@property(nonatomic,assign) id<BUIconActionSheetDelegate>	delegate;    
@property(nonatomic,assign)  BOOL							isVisible;


- (id)initWithButtons:(NSArray*)buttons andTitle:(NSString*)str;

-(void)show:(BOOL)animated;

@end
