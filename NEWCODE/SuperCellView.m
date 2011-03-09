//
//  SuperCellView.m
//  NagMe
//
//  Created by Neil Edwards on 09/12/2010.
//  Copyright 2010 buffer. All rights reserved.
//

#import "SuperCellView.h"
#import "AppConstants.h"

@implementation SuperCellView

/***********************************************************/
// dealloc
/***********************************************************/
- (void)dealloc
{
    [super dealloc];
}


-(void)initialise{}

-(void)populate{}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}


+(int)rowHeight{
	return STANDARDCELLHEIGHT;
}

+(NSString*)cellIdentifier{
	NSLog(@"[DEBUG] [ERROR] SuperCellViewIdentifer has not been overridden");
	return @"SuperCellViewIdentifer";
}

@end
