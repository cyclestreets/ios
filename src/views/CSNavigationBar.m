//
//  CSNavigationBar.m
//  NagMe
//
//  Created by Neil Edwards on 01/11/2011.
//  Copyright (c) 2011 buffer. All rights reserved.
//

#import "CSNavigationBar.h"
#import "GlobalUtilities.h"

@implementation CSNavigationBar


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
	
	UIImage *img  = [UIImage imageNamed: @"UINavigationBar_background.png"];
	[img drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
}


@end
