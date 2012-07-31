//
//  ExpandableTextView.h
//  RacingUK
//
//  Created by neil on 31/01/2012.
//  Copyright (c) 2012 Chroma. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ExpandableTextView : UITextView{
	BOOL			fixedWidth;
}
@property (nonatomic, assign)	BOOL	fixedWidth;
@end
