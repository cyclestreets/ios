//
//  BUActionSheet.h
//  CycleStreets
//
//  Created by Neil Edwards on 12/12/2012.
//  Copyright (c) 2012 CycleStreets Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>




@protocol BUActionSheetDelegate <NSObject>

@optional
- (void)actionSheetClickedButtonAtIndex:(NSInteger)buttonIndex;


@end

@interface BUActionSheet : UIView

@property(nonatomic,assign) id<BUActionSheetDelegate>		delegate;
@property(nonatomic,assign)  BOOL							isVisible;
@property(nonatomic,assign)  BOOL							showsCancelButton;


- (id)initWithButtons:(NSArray*)buttons andTitle:(NSString*)str;

-(void)show:(BOOL)animated;

@end
