//
//  BUTableCellView.h
//
//
//  Created by Neil Edwards on 12/08/2011.
//  Copyright 2011 CycleStreets.. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BUTableCellView : UITableViewCell


// cell dequeue initialiser
-(void)initialise;

// data provider refresh
-(void)populate;

// generic embedded cell button support
-(IBAction)cellButtonWasSelected:(id)sender;

// generic cell instantiation
+ (id)cellForTableView:(UITableView *)tableView fromNib:(UINib *)nib;


// static row height value for not variable height rows
+(int)rowHeight;

// variable height row support
+(NSNumber*)heightForCellWithDataProvider:(id)data;

// deQueue identifier
+ (NSString *)cellIdentifier;

// embdeed UINib support
+ (UINib *)nib;
+ (NSString *)nibName;
+ (NSString *)className;
- (NSString *)className;
@end
