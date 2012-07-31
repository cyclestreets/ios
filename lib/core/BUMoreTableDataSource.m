//
//  MoreTableDataSource.m
//
//
//  Created by Neil Edwards on 23/03/2010.
//  Copyright 2010 Buffer. All rights reserved.
//

#import "BUMoreTableDataSource.h"


@implementation BUMoreTableDataSource
@synthesize originalDataSource;


/***********************************************************/
// dealloc
/***********************************************************/




-(BUMoreTableDataSource *) initWithDataSource:(id<UITableViewDataSource>) dataSource
{
	
	if (self = [super init]) {
	
		self.originalDataSource = dataSource;
	}
	
    return self;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
    return [originalDataSource tableView:table numberOfRowsInSection:section];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [originalDataSource tableView:tableView cellForRowAtIndexPath:indexPath];
    cell.selectionStyle=UITableViewCellSelectionStyleGray;
    return cell;
}



@end
