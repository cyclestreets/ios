//
//  A2StoryboardSegueContext.h
//
//  Created by Alexsander Akers on 10/31/11.
//  Copyright (c) 2011 Pandamonia LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIStoryboardSegue (A2StoryboardSegueContext)

@property (nonatomic, readonly) id context;

@end

@interface UIViewController (A2StoryboardSegueContext)

- (void) performSegueWithIdentifier: (NSString *) identifier sender: (id) sender context: (id) context;

@end
