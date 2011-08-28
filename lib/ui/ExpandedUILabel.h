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
	BOOL			hasShadow;
}
@property (nonatomic)		BOOL		 multiline;
@property (nonatomic)		BOOL		 hasShadow;

@end
