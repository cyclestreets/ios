//
//  CSGraphView.h
//  CycleStreets
//
//  Created by Neil Edwards on 17/12/2012.
//  Copyright (c) 2012 CycleStreets Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol CSGraphViewDelegate <NSObject>

-(void)handleTouchInGraph:(CGPoint)point;
-(void)cancelTouchInGraph;

@end

@interface CSGraphView : UIView

@property (nonatomic, unsafe_unretained) id<CSGraphViewDelegate>		 delegate;

@end
