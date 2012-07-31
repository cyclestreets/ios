//
//  ParamUIButton.h
//  Sun NagMe
//
//  Created by Neil Edwards on 05/03/2012.
//  Copyright (c) 2012 Chroma. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ParamUIButton : UIButton{
	
	NSString				*parameter;
	
}
@property (nonatomic, strong) NSString		* parameter;
@end
