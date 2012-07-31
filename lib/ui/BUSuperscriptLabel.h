//
//  SuperscriptLabel.h
//
//
//  Created by Neil Edwards on 06/01/2010.
//  Copyright 2010 Buffer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LayoutBox.h"
#import	"ExpandedUILabel.h"

@interface BUSuperscriptLabel : LayoutBox {
	
	//public
	NSString		*labelText;
	NSString		*superscriptText;
	NSString		*labeltextColor;
	NSString		*superscripttextColor;
	UIFont			*labelFont;
	UIColor			*shadowColor;
	
	// private
	ExpandedUILabel			*mainLabel;
	ExpandedUILabel			*superscriptLabel;
	CGSize			shadowOffset;
	
	BOOL			centerValueLabel;
	
}
@property(nonatomic,strong)NSString *labelText;
@property(nonatomic,strong)NSString *superscriptText;
@property(nonatomic,strong)NSString *labeltextColor;
@property(nonatomic,strong)NSString *superscripttextColor;
@property(nonatomic,strong)UIFont *labelFont;
@property(nonatomic,strong)UIColor *shadowColor;
@property(nonatomic,strong)ExpandedUILabel *mainLabel;
@property(nonatomic,strong)ExpandedUILabel *superscriptLabel;
@property(nonatomic,assign)CGSize shadowOffset;
@property(nonatomic,assign)BOOL centerValueLabel;



-(void)setup;
-(void)populate;
@end
