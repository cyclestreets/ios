//
//  BUDataGridView.m
//  RacingUK
//
//  Created by Neil Edwards on 14/11/2011.
//  Copyright (c) 2011 Chroma. All rights reserved.
//

#import "BUDataGridView.h"

#import	"StyleManager.h"
#import "GlobalUtilities.h"
#import "ViewUtilities.h"
#import "LayoutBox.h"
#import "AppConstants.h"
#import "StringUtilities.h"

@interface BUDataGridView(Private)


-(void)createHeaders;
-(void)createLineItems;
-(void)determineColumnWidths;


@end


@implementation BUDataGridView
@synthesize dataProvider;
@synthesize alternateColors;
@synthesize framewidth;
@synthesize headerColor;
@synthesize headerTextColor;
@synthesize headerHeight;
@synthesize columnWidths;
@synthesize headers;
@synthesize headerLabels;
@synthesize lineFormatters;
@synthesize itemColor;
@synthesize itemTextColor;
@synthesize itemHeight;




- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
		
		layoutMode=BUVerticalLayoutMode;
		
		headerHeight=24;
		headerColor=@"racinggreen";
		headerTextColor=@"white";
		itemTextColor=@"black";
		itemColor=@"grey";
		itemHeight=20;
		fixedWidth=NO;
		
		framewidth=self.frame.size.width;
		
    }
    return self;
}


//
/***********************************************
 * @description			getters/setters
 ***********************************************/
//



-(void)setDataProviders:(NSDictionary*)dict{
	
	self.dataProvider=[dict objectForKey:@"data"];
	self.headers=[dict objectForKey:@"headers"];
	self.headerLabels=[dict objectForKey:@"labels"];
	self.lineFormatters=[dict objectForKey:@"formatters"];
	
}



-(void)createUI{
	
	[self removeAllSubViews];
	
	[self createHeaders];
	[self createLineItems];
	
}



-(void)createHeaders{
	
	if([dataProvider count]>0){
		
		LayoutBox *headerContainer=[[LayoutBox alloc]initWithFrame:CGRectMake(0, 0, framewidth, headerHeight)];
		headerContainer.backgroundColor=[[StyleManager sharedInstance] colorForType:headerColor];
		headerContainer.paddingLeft=0;
		headerContainer.paddingRight=0;
		headerContainer.itemPadding=0;
		headerContainer.alignMode=BUCenterAlignMode;
		
		
		// if using node based headers
		if(headers==nil){
			
			self.headerLabels=[[NSMutableArray alloc]init];
			
			NSMutableDictionary *keydicttemplate=[dataProvider objectAtIndex:0];
			
			for(NSString *key in keydicttemplate){
				[headerLabels addObject:key];
			}
			self.headers=headerLabels;
		}
		
		[self determineColumnWidths];
		for (int i=0; i<[headerLabels count]; i++) {
			UILabel *headerlabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, [[columnWidths objectAtIndex:i] floatValue], headerHeight)];
			headerlabel.backgroundColor=[UIColor clearColor];
			headerlabel.textAlignment=UITextAlignmentCenter;
			headerlabel.font=[UIFont boldSystemFontOfSize:11];
			headerlabel.textColor=[[StyleManager sharedInstance] colorForType:headerTextColor];
			headerlabel.text=[headerLabels objectAtIndex:i];
			[headerContainer addSubview:headerlabel];
		}
		
		[self addSubview:headerContainer];
		
	}
	
	
}


-(void)createLineItems{
	
	
	LayoutBox *lineContainer=[[LayoutBox alloc]initWithFrame:CGRectMake(0, 0, framewidth, headerHeight)];
	lineContainer.layoutMode=BUVerticalLayoutMode;
	lineContainer.itemPadding=0;
	
	
	for(int i=0;i<[dataProvider count];i++){
		
		NSMutableDictionary	*dict=[dataProvider objectAtIndex:i];
		
		// filter out rows with empty Type data
		NSString *typeString=[dict objectForKey:@"Type"];
		if([typeString isEqualToString:EMPTYSTRING]){
			break;
		}
		
		LayoutBox *itemContainer=[[LayoutBox alloc]initWithFrame:CGRectMake(0, 0, framewidth, headerHeight)];
		itemContainer.itemPadding=0;
		itemContainer.paddingLeft=0;
		itemContainer.paddingRight=0;
		itemContainer.alignMode=BUCenterAlignMode;
		
		if(alternateColors==YES){
			
			if (i%2==1) {
				itemContainer.backgroundColor=UIColorFromRGB(0xFFFFFF );
			}else {
				itemContainer.backgroundColor=UIColorFromRGB(0xe7e7e7);
			}
			
			
		}else {
			itemContainer.backgroundColor=UIColorFromRGB(0xe7e7e7);
		}
		
		for(int c=0;c<[headers count];c++){
			
			NSString *key=[headers objectAtIndex:c];
			NSString *linecontent=[dict objectForKey:key];
			
			UILabel *itemLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, [[columnWidths objectAtIndex:c] floatValue], headerHeight)];
			itemLabel.textAlignment=UITextAlignmentCenter;
			itemLabel.backgroundColor=[UIColor clearColor];
			itemLabel.font=[UIFont systemFontOfSize:11];
			itemLabel.textColor=[[StyleManager sharedInstance] colorForType:itemTextColor];
			if ([linecontent isEqualToString:EMPTYSTRING]) {
				itemLabel.text=@"-";
			}else {
				
				if ([[lineFormatters objectAtIndex:c] isEqualToString:CURRENCY]) {
					linecontent=[StringUtilities currencyFromCommaSeparatedString:linecontent];
				}
				
				itemLabel.text=linecontent;
			}
			
			
			[itemContainer addSubview:itemLabel];
			
		}
		
		[lineContainer addSubview:itemContainer];
		
		
	}
	
	[self addSubview:lineContainer];
	
}


-(void)determineColumnWidths{
	
	if(columnWidths==nil){
		
		self.columnWidths=[[NSMutableArray alloc]init];
		
		UIFont *headerfont=[UIFont boldSystemFontOfSize:12];
		CGFloat headerwidths=0;
		
		if(fixedWidth==NO){
			
			for(int i=0;i<[headerLabels count];i++){
				
				CGFloat columnwidth=[GlobalUtilities calculateWidthOfText:[headerLabels objectAtIndex:i] :headerfont];
				columnwidth+=10;
				headerwidths+=columnwidth;
				[columnWidths addObject:[NSNumber numberWithFloat:columnwidth]];
				
			}
			
			// check for now but should handle this exception
			if(headerwidths>framewidth){
				//NSLog(@"[ERROR]  RKDataGridViewController.determineColumnWidths: calculated column widths exceed frame width!");
			}
			
		}else {
			
			for(int i=0;i<[headerLabels count];i++){
				CGFloat columnwidth=[GlobalUtilities calculateWidthOfText:[headerLabels objectAtIndex:i] :headerfont];
				headerwidths+=columnwidth;
				[columnWidths addObject:[NSNumber numberWithFloat:columnwidth]];
			}
			
			if(headerwidths<framewidth){
				int spacing=(framewidth-headerwidths)/([headerLabels count]);
				for(int i=0;i<[headerLabels count];i++){
					int cwidth=[[columnWidths objectAtIndex:i] intValue];
					cwidth+=spacing;
					[columnWidths replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:cwidth]];
				}
			}
			
		}
		
		
	}
	
}



@end
