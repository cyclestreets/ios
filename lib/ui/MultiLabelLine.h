//
//  RKMultiLabelLine.h
//  RacingUK
//
//  Created by neil on 05/01/2010.
//  Copyright 2010 Chroma. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LayoutBox.h"

@interface MultiLabelLine : LayoutBox {
	
	NSMutableArray			*labels;
	NSMutableArray			*fonts;
	NSMutableArray			*colors;
	BOOL					showShadow;
	
}
@property (nonatomic, retain) NSMutableArray *labels;
@property (nonatomic, retain) NSMutableArray *fonts;
@property (nonatomic, retain) NSMutableArray *colors;
@property (nonatomic) BOOL showShadow;

-(void)drawUI;

@end
