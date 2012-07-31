//
//  MultiLabelLine.h
//
//
//  Created by neil on 05/01/2010.
//  Copyright 2010 Buffer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LayoutBox.h"

@interface MultiLabelLine : LayoutBox {
	
	NSMutableArray			*labels; // array of strings, these are created in order
	NSMutableArray			*fonts; // array of fonts for each label
	NSMutableArray			*colors; // array of colors for each label
	NSMutableArray			*textAligns; // optional: array fo UITextAlignments (default if LEFT)
	BOOL					showShadow; // draw shadows on labels
	
	// used to provide fixed width column layouts
	// and multiline support
	int						labelWidth;
	BOOL					labelisFixedWidth;
	int						valueWidth;
	BOOL					valueisFixedWidth;
	BOOL					containerisFixedWidth;
	
	BOOL					ignoreEmptyStrings; // do not draw lable if string is null
	BOOL					labelsAreColumns; // used in conjucntion with column layouts, forces alignment to Top rather than Center
	BOOL					useInitialFrameHeight; // used for multiline column support
	CGFloat					initWidth; // creation width
    CGRect                  initFrame; // creation frame
	
}
@property (nonatomic, strong) NSMutableArray		* labels;
@property (nonatomic, strong) NSMutableArray		* fonts;
@property (nonatomic, strong) NSMutableArray		* colors;
@property (nonatomic, strong) NSMutableArray		* textAligns;
@property (nonatomic) BOOL		 showShadow;
@property (nonatomic) int		 labelWidth;
@property (nonatomic) BOOL		 labelisFixedWidth;
@property (nonatomic) int		 valueWidth;
@property (nonatomic) BOOL		 valueisFixedWidth;
@property (nonatomic) BOOL		 containerisFixedWidth;
@property (nonatomic) BOOL		 ignoreEmptyStrings;
@property (nonatomic) BOOL		 labelsAreColumns;
@property (nonatomic) BOOL		 useInitialFrameHeight;
@property (nonatomic) CGFloat		 initWidth;
@property (nonatomic) CGRect		 initFrame;


-(void)drawUI;
-(void)initialise;
@end
