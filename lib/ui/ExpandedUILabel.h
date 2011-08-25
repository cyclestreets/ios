//
//  ExpandedUILabel.h
//  NagMe
//
//  Created by Neil Edwards on 25/11/2010.
//  Copyright 2010 buffer. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ExpandedUILabel : UILabel {
	BOOL			multiline;		
	BOOL			fixedWidth;
	int				insetValue;
	UIColor			*labelColor;
	BOOL			hasShadow;
}
@property (nonatomic)	BOOL		multiline;
@property (nonatomic)	BOOL		fixedWidth;
@property (nonatomic)	int		insetValue;
@property (nonatomic, retain)	UIColor		*labelColor;
@property (nonatomic)	BOOL		hasShadow;
@end
