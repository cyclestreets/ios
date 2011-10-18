//
//  MoreTableDataSource.m
//
//
//  Created by Neil Edwards on 23/03/2010.
//  Copyright 2010 Chroma. All rights reserved.
//

#import "BUMoreTableDataSource.h"


@implementation BUMoreTableDataSource
@synthesize originalDataSource;


/***********************************************************/
// dealloc
/***********************************************************/
- (void)dealloc
{
    [originalDataSource release], originalDataSource = nil;
	
    [super dealloc];
}




-(BUMoreTableDataSource *) initWithDataSource:(id<UITableViewDataSource>) dataSource
{
    originalDataSource = dataSource;
    [super init];
	
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
