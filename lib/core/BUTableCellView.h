//
//  BUTableCellView.h
//
//
//  Created by Neil Edwards on 12/08/2011.
//  Copyright 2011 Buffer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BUTableCellView : UITableViewCell

@property (nonatomic)	BOOL		shouldRemainSelected;


// cell dequeue initialiser
-(void)initialise;

// data provider refresh
-(void)populate;

// generic embedded cell button support
-(IBAction)cellButtonWasSelected:(id)sender;

// wrapper for cell button notifications
-(void)sendCellButtonNotification:(NSDictionary*)dict;


// will allow tableview to create new cells from dequeueReusableCellWithIdentifier
+(void)cacheCellForTableView:(UITableView*)tableView fromNib:(UINib *)nib;


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
