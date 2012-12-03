//
//  BUIconActionSheet.h
//  CycleStreets
//
//  Created by Neil Edwards on 01/12/2012.
//  Copyright (c) 2012 CycleStreets Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BUIconActionSheetDelegate <NSObject>

@optional
- (void)actionSheetClickedButtonAtIndex:(NSInteger)buttonIndex;
- (void)actionSheetClickedButtonWithSelector:(SEL)selector;


@end

@interface BUIconActionSheet : UIView

@property(nonatomic,assign) id<BUIconActionSheetDelegate> delegate;    // weak reference
@property(nonatomic,assign)  BOOL         isVisible;


- (id)initWithButtons:(NSMutableArray*)buttons;

-(void)show:(BOOL)show;

@end
