//
//  SuperCellView.h
//  NagMe
//
//  Created by Neil Edwards on 09/12/2010.
//  Copyright 2010 buffer. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SuperCellView : UITableViewCell {
	
	
}


-(void)initialise;
-(void)populate;

+(int)rowHeight;
+(NSString*)cellIdentifier;
@end
