//
//  ExpandedUILabel.h
// CycleStreets
//
//  Created by Neil Edwards on 25/11/2010.
//  Copyright 2010 buffer. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ExpandedUILabel : UILabel

@property (nonatomic, assign) IBInspectable	BOOL	multiline;
@property (nonatomic, assign) IBInspectable	int		insetValue;
@property (nonatomic, unsafe_unretained)	UIColor	*labelColor;

@property (nonatomic)  UIEdgeInsets textInsets;


@end
