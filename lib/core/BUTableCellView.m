//
//  BUTableCellView.m
//
//
//  Created by Neil Edwards on 12/08/2011.
//  Copyright 2011 Buffer. All rights reserved.
//

#import "BUTableCellView.h"

@implementation BUTableCellView



//
/***********************************************
 * @description			if this is called, the tableview will automatically create a new nib instance if required
 ***********************************************/
//
+(void)cacheCellForTableView:(UITableView*)tableView fromNib:(UINib *)nib{
	
	NSString *cellID = [self cellIdentifier];
	
	[tableView registerNib:nib forCellReuseIdentifier:cellID];
	
}


+ (id)cellForTableView:(UITableView *)tableView fromNib:(UINib *)nib {
    NSString *cellID = [self cellIdentifier];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
	
    if (cell == nil) {
        NSArray *nibObjects = [nib instantiateWithOwner:nil options:nil];
		
        NSAssert2(([nibObjects count] > 0) && 
                  [[nibObjects objectAtIndex:0] isKindOfClass:[self class]],
                  @"Nib '%@' does not appear to contain a valid %@", 
                  [self nibName], NSStringFromClass([self class]));
        
        cell = [nibObjects objectAtIndex:0];
    }
    
    return cell;    
}



- (void)awakeFromNib {
    
    [super awakeFromNib];
    [self initialise];
    
}


-(void)initialise{}

-(void)populate{}



-(IBAction)cellButtonWasSelected:(id)sender{}


-(void)sendCellButtonNotification:(NSDictionary*)dict{
	
	if(dict!=nil)
		[[NSNotificationCenter defaultCenter] postNotificationName:BUCELLNOTIFICATION object:nil userInfo:
		 [NSDictionary dictionaryWithObjectsAndKeys:[self className],@"type",dict,EVENTDICT,nil]];
		
}



+ (NSString *)cellIdentifier {
    return [NSString stringWithFormat:@"%@Identifier",[self nibName]];
}


#pragma row Heights
+(int)rowHeight{
	return STANDARDCELLHEIGHT;
}
+(NSNumber*)heightForCellWithDataProvider:(id)data{
    return [NSNumber numberWithInt:[self rowHeight]];
}


#pragma mark UINib support

+ (NSString *)className{
    return NSStringFromClass([self class]);
}
- (NSString *)className{
    return NSStringFromClass([self class]);
}

+ (UINib *)nib {
    NSBundle *classBundle = [NSBundle bundleForClass:[self class]];
    return [UINib nibWithNibName:[self nibName] bundle:classBundle];
}

+ (NSString *)nibName {
    return [[self className] stringByReplacingOccurrencesOfString:@"View" withString:@""];
}

@end
