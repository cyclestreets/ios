//
//  BUUIFolderView.h
//  Buffer
//
//  Created by Neil Edwards on 10/03/2011.
//  Copyright 2011 Buffer. All rights reserved.
//

#import <UIKit/UIKit.h>

#define  kBUFOLDERAROWWIDTH 30.0f
#define  kBUFOLDERAROWHEIGHT 15.0f


@interface BUFolderViewHeader : UIView {
	
	int						targetPoint;
    
}
@property (nonatomic)		int		 targetPoint;

@end
