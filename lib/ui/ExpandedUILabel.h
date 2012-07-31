//
//  ExpandedUILabel.h
// CycleStreets
//
//  Created by Neil Edwards on 25/11/2010.
//  Copyright 2010 buffer. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ExpandedUILabel : UILabel {
	BOOL			multiline;		
	BOOL			fixedWidth;
	int				insetValue;
	UIColor			*__unsafe_unretained labelColor;
    BOOL			hasShadow;
}
@property (nonatomic, assign)	BOOL	multiline;
@property (nonatomic, assign)	BOOL	fixedWidth;
@property (nonatomic, assign)	int	insetValue;
@property (nonatomic, unsafe_unretained)	UIColor	*labelColor;
@property (nonatomic)		BOOL		 hasShadow;

@end
