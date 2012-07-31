//
//  KBContainerView.h
//  RacingUK
//
//  Created by Neil Edwards on 17/10/2011.
//  Copyright (c) 2011 Chroma. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KBContainerView : UIView{
   id __unsafe_unretained key;
   int state;
}
@property(readonly, unsafe_unretained, nonatomic) id key;
@property(readonly, assign, nonatomic) int state;
@end
